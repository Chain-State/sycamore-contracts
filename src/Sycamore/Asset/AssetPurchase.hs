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

-- import Cardano.Api.Shelley (PlutusScript (..), PlutusScriptV1)
import           Data.Aeson                           (FromJSON, ToJSON)
import           GHC.Generics                         (Generic)

import           Ledger.Typed.Scripts                 as Scripts
import           Ledger.Value                         as Value
import           Plutus.Script.Utils.V2.Contexts      hiding (valuePaidTo)
import qualified Plutus.Script.Utils.V2.Typed.Scripts as V2
import           Plutus.V2.Ledger.Api                 as PlutusV2
import           Plutus.V2.Ledger.Contexts            as PlutusV2
import qualified PlutusTx
import           PlutusTx.Prelude                     hiding (Semigroup (..))

import           Ledger                               hiding (ScriptContext,
                                                       TxOut,
                                                       scriptContextTxInfo,
                                                       singleton,
                                                       txInInfoResolved,
                                                       txInfoInputs,
                                                       txInfoOutputs,
                                                       txInfoValidRange,
                                                       txOutAddress, txOutValue,
                                                       valuePaidTo)

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
} deriving (Generic, FromJSON, ToJSON)


PlutusTx.makeLift ''AssetPurchase
-- PlutusTx.makeIsDataIndexed ''AssetPurchaseDatum [('AssetPurchaseDatum, 0)]

--pragma {# INLINABLE func #}: allows the compiler to inline the definition of `purchaseValidator` inside the `||` brackets
--Any function that is to be used for on-chain code will need this validator.
{-# INLINABLE purchaseValidator #-}

--this function will be supplied to `mkTypedValidator` which will compile it into Plutus Core.
purchaseValidator :: AssetPurchase -> () -> () -> PlutusV2.ScriptContext -> Bool
purchaseValidator p () () ctx  = validate
    where
        validate ::  Bool
        validate =    txHasOneScInputOnly
                      && validateTxOuts
                      && all (==True) (paysBeneficiaries (beneficiary p))
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

        paysBeneficiaries :: [PubKeyHash] -> [Bool]
        paysBeneficiaries [] = [True]
        paysBeneficiaries (x:xs) = beneficiaryIsPaid x : paysBeneficiaries xs

        minterIsPaid :: Bool
        minterIsPaid = assetClassValueOf (valuePaidTo (scriptContextTxInfo ctx) (minter p)) (minterCurrency p) == minterAmount p

        --tx should be valid before 36 hours or only if the tx is a refund* tx
        saleValid :: Bool
        saleValid = traceIfFalse "Time Interval Failed" $ member (saleExpiresOn p) $ txInfoValidRange (scriptContextTxInfo ctx)

        -- saleValid = traceIfFalse "Time Interval Failed" before (saleExpiresOn p) (txInfoValidRange (scriptContextTxInfo ctx))

        --a refund tx should have the NFT as input and the minter address as the output.


        -- signedByBuyer :: Bool
        -- signedByBuyer = txSignedBy (scriptContextTxInfo ctx) (buyer p)



--for typed validators, we need to inform the Plutus compiler by creating a new type that encodes
--the information about the datum and redeemer that plutus core expects.
data Typed
instance Scripts.ValidatorTypes Typed where
    type instance DatumType Typed = ()
    type instance RedeemerType Typed = ()

typedValidator :: AssetPurchase -> V2.TypedValidator Typed
typedValidator p = V2.mkTypedValidator @Typed
    ($$(PlutusTx.compile [|| purchaseValidator ||]) `PlutusTx.applyCode` PlutusTx.liftCode p) $$(PlutusTx.compile [|| wrap ||])
  where
    wrap = Scripts.mkUntypedValidator

validator :: AssetPurchase -> Validator
validator = Scripts.validatorScript . typedValidator

--generate hash of the validator
valHash :: AssetPurchase -> Ledger.ValidatorHash
valHash = Scripts.validatorHash . typedValidator

--generate address from the validator
scrAddress ::  AssetPurchase -> Ledger.Address
scrAddress = scriptHashAddress . valHash