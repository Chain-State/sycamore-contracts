{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE DeriveAnyClass      #-}
{-# LANGUAGE DeriveGeneric       #-}
{-# LANGUAGE FlexibleContexts    #-}
{-# LANGUAGE NoImplicitPrelude   #-}
{-# LANGUAGE NumericUnderscores  #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell     #-}
{-# LANGUAGE TypeApplications    #-}
{-# LANGUAGE TypeFamilies        #-}
{-# LANGUAGE TypeOperators       #-}

module Sycamore.Nft.OnChain
    ( tokenPolicy
    , tokenCurSymbol
    ) where

import qualified PlutusTx
import PlutusTx.Builtins
import Cardano.Api.Shelley (PlutusScript (..), PlutusScriptV2)
import Codec.Serialise
import PlutusTx.Prelude hiding (Semigroup(..), unless)
import qualified Plutus.Script.Utils.Typed        as Scripts
import Plutus.Script.Utils.V2.Scripts (scriptCurrencySymbol)
import Plutus.V2.Ledger.Api as V2
import Plutus.V2.Ledger.Contexts as V2
import           Ledger.Value                as Value

--This policy script defines the constraints under which the tokens can be minted.
--In this case:
    -- the specified UTXO (oref) is part of the selected spending inputs for this tx
    -- the minting info for previous mint operations matches the current inputs on   token name and amount.
{-# INLINABLE mkTokenPolicy #-}
mkTokenPolicy :: TxOutRef -> TokenName -> Integer -> () -> V2.ScriptContext -> Bool
mkTokenPolicy oref tn amt () ctx = 
    traceIfFalse "UTxO not consumed"   hasUTxO   
    &&  traceIfFalse "can only minted" checkMintedAmount
  where
    info :: TxInfo
    info = scriptContextTxInfo ctx

    hasUTxO :: Bool
    hasUTxO = any (\i -> txInInfoOutRef i == oref) $ txInfoInputs info

    checkMintedAmount :: Bool
    checkMintedAmount = case flattenValue (txInfoMint info) of
        [(_, tn', amt')] -> tn' == tn && amt' == amt
        _                -> False

tokenPolicy :: TxOutRef -> TokenName -> Integer -> V2.MintingPolicy
tokenPolicy oref tn amt = V2.mkMintingPolicyScript $
    $$(PlutusTx.compile [|| \oref' tn' amt' -> Scripts.mkUntypedMintingPolicy $ mkTokenPolicy oref' tn' amt' ||])
    `PlutusTx.applyCode`
    PlutusTx.liftCode oref
    `PlutusTx.applyCode`
    PlutusTx.liftCode tn
    `PlutusTx.applyCode`
    PlutusTx.liftCode amt

tokenCurSymbol :: TxOutRef -> TokenName -> Integer -> CurrencySymbol
tokenCurSymbol oref tn = scriptCurrencySymbol . tokenPolicy oref tn