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

import           Data.Aeson                      (FromJSON, ToJSON)
import           GHC.Generics                    (Generic)

import           Plutus.Script.Utils.Value       as Value
import           Plutus.V2.Ledger.Api            
import           Plutus.V2.Ledger.Contexts            
import          Ledger(toValidatorHash, member)

import qualified PlutusTx
import           PlutusTx.Prelude                hiding (Semigroup (..))

import           Sycamore.Utils                  (wrapValidator)

data AssetPurchase = AssetPurchase {
    saleNftTn           :: TokenName
   ,minter              :: PubKeyHash
   ,minterCurrency      :: AssetClass
   ,minterAmount        :: Integer
   ,beneficiary         :: [PubKeyHash]
   ,beneficiaryAmount   :: Integer
   ,beneficiaryCurrency :: AssetClass
   ,collateral          :: AssetClass
   ,collateralAmnt      :: Integer
   ,saleExpiresOn       :: POSIXTime
} 


PlutusTx.makeLift ''AssetPurchase

{-# INLINABLE purchaseValidator #-}

--this function will be supplied to `mkTypedValidator` which will compile it into Plutus Core.
purchaseValidator :: AssetPurchase -> () -> () -> ScriptContext -> Bool
purchaseValidator p () () ctx  = validate
    where
        validate ::  Bool
        validate =    txHasOneScInputOnly
                      && validateTxOuts
                      -- && paysBeneficiaries
                      && minterIsPaid
                      && saleValid

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

        beneficiaryIsPaid ::  PubKeyHash -> Bool
        beneficiaryIsPaid pbkh= assetClassValueOf (valuePaidTo (scriptContextTxInfo ctx) pbkh) (beneficiaryCurrency p) == beneficiaryAmount p

        paysBeneficiaries :: Bool
        paysBeneficiaries = all (==True) $ map beneficiaryIsPaid (beneficiary p)

        minterIsPaid :: Bool
        minterIsPaid = assetClassValueOf (valuePaidTo (scriptContextTxInfo ctx) (minter p)) (minterCurrency p) == minterAmount p

        --tx should be valid before 36 hours or only if the tx is a refund* tx
        saleValid :: Bool
        saleValid = traceIfFalse "Time Interval Failed" $ member (saleExpiresOn p) $ txInfoValidRange (scriptContextTxInfo ctx)

        -- saleValid = traceIfFalse "Time Interval Failed" before (saleExpiresOn p) (txInfoValidRange (scriptContextTxInfo ctx))

        --a refund tx should have the NFT as input and the minter address as the output.


        -- signedByBuyer :: Bool
        -- signedByBuyer = txSignedBy (scriptContextTxInfo ctx) (buyer p)


{-# INLINABLE  mkWrappedParameterizedValidator #-}
mkWrappedParameterizedValidator :: AssetPurchase -> BuiltinData -> BuiltinData -> BuiltinData -> ()
mkWrappedParameterizedValidator = wrapValidator . purchaseValidator

validator :: AssetPurchase -> Validator
validator p = mkValidatorScript
    ($$(PlutusTx.compile [|| mkWrappedParameterizedValidator ||]) `PlutusTx.applyCode` PlutusTx.liftCode p)