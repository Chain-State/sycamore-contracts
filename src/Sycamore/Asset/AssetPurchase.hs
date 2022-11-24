{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE DeriveAnyClass             #-}
{-# LANGUAGE DeriveGeneric              #-}
{-# LANGUAGE DerivingStrategies         #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
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

import           Data.Aeson             (ToJSON, FromJSON)
import           GHC.Generics           (Generic)

import           Ledger.Ada           as Ada
import qualified PlutusTx
import           PlutusTx.Prelude     hiding (Semigroup(..),unless)

import           Ledger
import qualified Ledger.Typed.Scripts as Scripts
import           Plutus.V1.Ledger.Scripts
import           Plutus.V1.Ledger.Api
import qualified Plutus.V1.Ledger.Scripts as Plutus
import           Plutus.V1.Ledger.Value
import           PlutusTx.Builtins.Class
import qualified Plutus.V1.Ledger.Contexts as PVC


data AssetPurchase = AssetPurchase {
    saleNftTn :: TokenName
   ,aggregator   :: Address 
   ,aggregatorCurrency :: AssetClass
   ,aggregatorAmount :: Integer
   ,beneficiary :: Address
   ,beneficiaryAmount :: Integer
   ,beneficiaryCurrency :: AssetClass
   ,collateral :: AssetClass
   ,collateralAmnt :: Integer
} deriving (Generic, FromJSON, ToJSON)


PlutusTx.makeLift ''AssetPurchase
-- PlutusTx.makeIsDataIndexed ''AssetPurchaseDatum [('AssetPurchaseDatum, 0)]

--pragma {# INLINABLE func #}: allows the compiler to inline the definition of `purchaseValidator` inside the `||` brackets
--Any function that is to be used for on-chain code will need this validator.
{-# INLINABLE purchaseValidator #-}

--this function will be supplied to `mkTypedValidator` which will compile it into Plutus Core.
purchaseValidator :: AssetPurchase -> () -> () -> ScriptContext -> Bool 
purchaseValidator p () () ctx  = validate 
    where
        validate ::  Bool
        validate =    txHasOneScInputOnly 
                      && validateTxOuts 
                      && sellerIsPaid 

        txHasOneScInputOnly :: Bool
        txHasOneScInputOnly =
          length (filter isJust $ toValidatorHash . txOutAddress . txInInfoResolved <$> txInfoInputs (scriptContextTxInfo ctx)) == 1

        validateTxOuts :: Bool
        validateTxOuts = any txOutValidate (txInfoOutputs (scriptContextTxInfo ctx))

        txOutValidate :: TxOut -> Bool
        txOutValidate txo = containsRequiredCollateralAmount txo
        
        -- collateral added is at least 2 Ada 
        containsRequiredCollateralAmount :: TxOut -> Bool
        containsRequiredCollateralAmount txo =
          collateralAmnt p <= assetClassValueOf (txOutValue txo) (collateral p)

--         beneficiaryIsPaid :: Bool
--         beneficiaryIsPaid = assetClassValueOf (valuePaidToAddress ctx (beneficiary p)) (beneficiaryCurrency p) == beneficiaryAmount p

-- --AR address must have 2 Ada deposited.
--         aggregatorIsPaid :: Bool
--         aggregatorIsPaid = assetClassValueOf (valuePaidToAddress ctx (aggregator p)) (aggregatorCurrency p) == aggregatorAmount p


--         valuePaidToAddress :: ScriptContext -> Address -> Value
--         valuePaidToAddress ctx addr = mconcat (fmap txOutValue (filter (\x -> txOutAddress x == addr) (txInfoOutputs (scriptContextTxInfo ctx))))


        txVal :: Value 
        txVal = assetClassValue (assetClass adaSymbol adaToken) 2000000 

        txOut :: PVC.TxOut
        txOut = PVC.TxOut (aggregator p) txVal Nothing

        sellerIsPaid :: Bool
        sellerIsPaid =  txVal `elem` (fmap txOutValue $ filter (\x -> PVC.txOutValue x == txVal) (PVC.txInfoOutputs (PVC.scriptContextTxInfo ctx)))

        
--for typed validators, we need to inform the Plutus compiler by creating a new type that encodes 
--the information about the datum and redeemer that plutus core expects.
data TypedValidator
instance Scripts.ValidatorTypes TypedValidator where
    type instance DatumType TypedValidator = ()
    type instance RedeemerType TypedValidator = () 

typedValidator :: AssetPurchase -> Scripts.TypedValidator TypedValidator
typedValidator p = Scripts.mkTypedValidator @TypedValidator
    ($$(PlutusTx.compile [|| purchaseValidator ||]) `PlutusTx.applyCode` PlutusTx.liftCode p)
    $$(PlutusTx.compile [|| wrap ||])
  where
    wrap = Scripts.wrapValidator @() @()

validator :: AssetPurchase -> Validator
validator = Scripts.validatorScript . typedValidator

--generate hash of the validator
valHash :: AssetPurchase -> Ledger.ValidatorHash
valHash = Scripts.validatorHash . typedValidator

--generate address from the validator
scrAddress :: AssetPurchase -> Ledger.Address
scrAddress = scriptAddress . validator
