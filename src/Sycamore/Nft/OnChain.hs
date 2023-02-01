{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE DeriveAnyClass      #-}
{-# LANGUAGE DeriveGeneric       #-}
{-# LANGUAGE FlexibleContexts    #-}
{-# LANGUAGE ImportQualifiedPost #-}
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

import           Ledger.Typed.Scripts           as Scripts
import           Ledger.Value                   as Value
import qualified Plutus.Script.Utils.V2.Scripts as PSU.V2
import qualified Plutus.V2.Ledger.Api           as PlutusV2
import           Plutus.V2.Ledger.Contexts      as V2
import qualified PlutusTx
import           PlutusTx.Builtins
import           PlutusTx.Prelude               hiding (Semigroup (..), unless)

--This policy script defines the constraints under which the tokens can be minted.
--In this case:
    -- the specified UTXO (oref) is part of the selected spending inputs for this tx
    -- the minting info for previous mint operations matches the current inputs on   token name and amount.
{-# INLINABLE mkTokenPolicy #-}
mkTokenPolicy :: PlutusV2.TxOutRef -> PlutusV2.TokenName -> Integer -> () -> PlutusV2.ScriptContext -> Bool
mkTokenPolicy oref tn amt () ctx =
    traceIfFalse "UTxO not consumed"   hasUTxO
    &&  traceIfFalse "can only mint 1 token" checkMintedAmount
  where
    info :: PlutusV2.TxInfo
    info = PlutusV2.scriptContextTxInfo ctx

    hasUTxO :: Bool
    hasUTxO = any (\i -> PlutusV2.txInInfoOutRef i == oref) $ PlutusV2.txInfoInputs info

    checkMintedAmount :: Bool
    checkMintedAmount = case Value.flattenValue (PlutusV2.txInfoMint info) of
        [(_, tn', amt')] -> tn' == tn && amt' == amt
        _                -> False

tokenPolicy :: PlutusV2.TxOutRef -> PlutusV2.TokenName -> Integer -> Scripts.MintingPolicy
tokenPolicy oref tn amt = PlutusV2.mkMintingPolicyScript $
    $$(PlutusTx.compile [|| \oref' tn' amt' -> Scripts.mkUntypedMintingPolicy $ mkTokenPolicy oref' tn' amt' ||])
    `PlutusTx.applyCode`
    PlutusTx.liftCode oref
    `PlutusTx.applyCode`
    PlutusTx.liftCode tn
    `PlutusTx.applyCode`
    PlutusTx.liftCode amt

tokenCurSymbol :: PlutusV2.TxOutRef -> PlutusV2.TokenName -> Integer -> PlutusV2.CurrencySymbol
tokenCurSymbol oref tn = PSU.V2.scriptCurrencySymbol . tokenPolicy oref tn