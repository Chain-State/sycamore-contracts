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

import           Control.Monad        hiding (fmap)
import           Data.List.NonEmpty   (NonEmpty (..))
import           Data.Map             as Map hiding (filter)
import           Data.Text            (pack, Text)
import           Data.Void 
import           Data.Aeson             (ToJSON, FromJSON)
import           GHC.Generics           (Generic)
import           Text.Printf          (printf)
import           Prelude              (IO, Show, Semigroup (..), String, undefined) 
import           Schema               (ToSchema)

import           Ledger               hiding (singleton)
import           Ledger.Constraints   as Constraints
import qualified Ledger.Typed.Scripts as    Scripts
import           Ledger.Ada           as Ada
import           Plutus.V1.Ledger.Api
import           Plutus.Contract      
import           PlutusTx             (Data (..))
import qualified PlutusTx
import           PlutusTx.Prelude     hiding (Semigroup(..),unless)
import           Plutus.V1.Ledger.Value


data AssetPurchase = AssetPurchase {
    saleNftTn :: TokenName
   ,aggregator   :: Address
   ,aggregatorCurrency :: AssetClass
   ,aggregatorAmount :: Integer
   ,beneficiary :: Address
   ,collateral :: AssetClass
   ,collateralAmnt :: Integer
} deriving (Show, Generic, FromJSON, ToJSON)


PlutusTx.makeLift ''AssetPurchase
-- PlutusTx.makeIsDataIndexed ''AssetPurchaseDatum [('AssetPurchaseDatum, 0)]

--pragma {# INLINABLE func #}: allows the compiler to inline the definition of `purchaseValidator` inside the `||` brackets
--Any function that is to be used for on-chain code will need this validator.
{-# INLINABLE purchaseValidator #-}

--this function will be supplied to `mkTypedValidator` which will compile it into Plutus Core.
purchaseValidator :: AssetPurchase -> () -> () -> ScriptContext -> Bool 
purchaseValidator arg () () ctx  = validate 
    where
        validate ::  Bool
        validate =    txHasOneScInputOnly && validateTxOuts 

        txHasOneScInputOnly :: Bool
        txHasOneScInputOnly =
          length (filter isJust $ toValidatorHash . txOutAddress . txInInfoResolved <$> txInfoInputs (scriptContextTxInfo ctx)) == 1

        validateTxOuts :: Bool
        validateTxOuts = any txOutValidate (txInfoOutputs (scriptContextTxInfo ctx))

        aggregatorIsPaid :: Bool
        aggregatorIsPaid = assetClassValueOf (valuePaidToAddress ctx (aggregator arg)) (aggregatorCurrency arg) == aggregatorAmount arg

        txOutValidate :: TxOut -> Bool
        txOutValidate txo = containsRequiredCollateralAmount txo

        containsRequiredCollateralAmount :: TxOut -> Bool
        containsRequiredCollateralAmount txo =
          collateralAmnt arg <= assetClassValueOf (txOutValue txo) (collateral arg)

        --from all the outputs in the tx, get the total being paid to the specified address
        valuePaidToAddress :: ScriptContext -> Address -> Value
        valuePaidToAddress ctx addr = mconcat (fmap txOutValue (filter (\x -> txOutAddress x == addr) (txInfoOutputs (scriptContextTxInfo ctx))))


--for typed validators, we need to inform the Plutus compiler by creating a new type that encodes 
--the information about the datum and redeemer that plutus core expects.
data TypedValidator
instance Scripts.ValidatorTypes TypedValidator where
    type instance DatumType TypedValidator = ()
    type instance RedeemerType TypedValidator = () 

typedValidator :: AssetPurchase -> Scripts.TypedValidator TypedValidator
typedValidator arg = Scripts.mkTypedValidator @TypedValidator
    ($$(PlutusTx.compile [|| purchaseValidator ||]) `PlutusTx.applyCode` PlutusTx.liftCode arg)
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

-- dat :: AssetPurchaseDatum 
-- dat = AssetPurchaseDatum 
--     TokenName (toBuiltin "bcf896fe5c1dbb10dcce8d2ec557492d407450c44e8bdbcdb9db7812.41666961233031")

