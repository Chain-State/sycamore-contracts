{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE DeriveAnyClass             #-}
{-# LANGUAGE DeriveGeneric              #-}
{-# LANGUAGE DerivingStrategies         #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE ImportQualifiedPost        #-}
{-# LANGUAGE LambdaCase                 #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE NoImplicitPrelude          #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE RecordWildCards            #-}
{-# LANGUAGE ScopedTypeVariables        #-}
{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TypeApplications           #-}
{-# LANGUAGE TypeFamilies               #-}
{-# LANGUAGE TypeOperators              #-}

module Sycamore.Asset.AssetPurchase where

import           Data.Aeson                (FromJSON, ToJSON)
import           GHC.Generics              (Generic)

import           Ledger                    (member, toValidatorHash)
import           Plutus.Script.Utils.Value (AssetClass (..), assetClassValueOf)
import           Plutus.V2.Ledger.Api      (BuiltinData, POSIXTime, PubKeyHash,
                                            ScriptContext (scriptContextTxInfo),
                                            TokenName, Value,
                                             TxOut,
                                            Validator, ValidatorHash (..),
                                            adaSymbol, adaToken, from,
                                            mkValidatorScript, singleton,
                                            txInInfoResolved, txInfoInputs,
                                            txInfoOutputs, txOutAddress,
                                            txOutValue)
import           Plutus.V2.Ledger.Contexts (valuePaidTo, TxInfo, TxInfo(txInfoValidRange))

import qualified PlutusTx (compile, unstableMakeIsData, makeLift, applyCode, liftCode)
import PlutusTx.Builtins (BuiltinData, Integer)
import           PlutusTx.Prelude          (Bool (..), (==), (.), ($),(<$>), (&&), traceIfFalse, isJust, length, filter)

import           Sycamore.Utils            (wrapValidator)

data AssetPurchase = AssetPurchase {
    saleNftTn       :: TokenName
   ,minterPkh :: PubKeyHash 
   ,minterValue     :: Value
   ,collateralValue :: Value
   ,saleExpiresOn   :: POSIXTime
}


PlutusTx.makeLift ''AssetPurchase

{-# INLINABLE purchaseValidator #-}

--this function will be supplied to `mkTypedValidator` which will compile it into Plutus Core.
purchaseValidator :: AssetPurchase -> () -> () -> ScriptContext -> Bool
purchaseValidator p () () ctx  = validate
    where
        
        txInfo :: TxInfo
        txInfo = scriptContextTxInfo ctx

        validate ::  Bool
        validate =    txHasOneScInputOnly
                      && saleValid
                      && paysMinter

        txHasOneScInputOnly :: Bool
        txHasOneScInputOnly =
          length (filter isJust $ toValidatorHash . txOutAddress . txInInfoResolved <$> txInfoInputs (scriptContextTxInfo ctx)) == 1

        paysMinter :: Bool
        paysMinter = traceIfFalse "Minter Not Paid" $ valuePaidTo txInfo (minterPkh p) == minterValue p 

        saleValid :: Bool
        saleValid = traceIfFalse "Time Interval Failed" $ member (saleExpiresOn p) $ txInfoValidRange (scriptContextTxInfo ctx)

{-# INLINABLE  mkWrappedParameterizedValidator #-}
mkWrappedParameterizedValidator :: AssetPurchase -> BuiltinData -> BuiltinData -> BuiltinData -> ()
mkWrappedParameterizedValidator = wrapValidator . purchaseValidator

validator :: AssetPurchase -> Validator
validator p = mkValidatorScript
    ($$(PlutusTx.compile [|| mkWrappedParameterizedValidator ||]) `PlutusTx.applyCode` PlutusTx.liftCode p)