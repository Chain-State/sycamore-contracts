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

-- import           Data.Aeson             (ToJSON, FromJSON)
-- import           GHC.Generics           (Generic)

-- import qualified PlutusTx
-- import           PlutusTx.Prelude     hiding (Semigroup(..),unless)
-- import           PlutusTx.Builtins.Class

-- import           Ledger
-- import qualified Ledger.Typed.Scripts as Scripts
-- import           Ledger.Ada           as Ada
-- import           Plutus.V1.Ledger.Scripts
-- import           Plutus.V1.Ledger.Api
-- import qualified Plutus.V1.Ledger.Scripts as Plutus
-- import           Plutus.V1.Ledger.Value
-- import qualified Plutus.V1.Ledger.Contexts as PVC


import           Cardano.Api.Shelley (PlutusScript (..), PlutusScriptV1)

import           Codec.Serialise ( serialise )
import           Data.Aeson           (ToJSON, FromJSON)
import qualified Data.ByteString.Lazy as LBS
import qualified Data.ByteString.Short as SBS
import GHC.Generics (Generic)
import           Plutus.V1.Ledger.Value
import           Ledger.Address
import           Plutus.V1.Ledger.Time
import           Plutus.V1.Ledger.Scripts
import qualified Ledger.Typed.Scripts as Scripts

import           Prelude                 (Semigroup (..), Show (..))
import           PlutusTx.Prelude hiding (Semigroup (..))
import qualified PlutusTx
import           Ledger               hiding (singleton)
import qualified Plutus.V1.Ledger.Scripts as Plutus
import Plutus.V1.Ledger.Api


data AssetPurchase = AssetPurchase {
    saleNftTn :: TokenName
   ,minter   :: PubKeyHash 
   ,minterCurrency :: AssetClass
   ,minterAmount :: Integer
   ,beneficiary :: PubKeyHash
   ,beneficiaryAmount :: Integer
   ,beneficiaryCurrency :: AssetClass
   ,collateral :: AssetClass
   ,collateralAmnt :: Integer
   ,saleExpiresOn :: POSIXTime
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
                      && beneficiaryIsPaid 
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

        beneficiaryIsPaid :: Bool
        beneficiaryIsPaid = assetClassValueOf (valuePaidTo (scriptContextTxInfo ctx) (beneficiary p)) (beneficiaryCurrency p) == beneficiaryAmount p

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
