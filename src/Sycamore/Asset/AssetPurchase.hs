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


data AssetPurchaseDatum = AssetPurchaseDatum {
    saleNftTn :: TokenName
   ,buyer     :: Address
   ,beneficiary1   :: Address
   ,beneficiary2 :: Address
   ,collateral :: AssetClass
   ,collateralAmnt :: Integer
} deriving (Show, Generic, FromJSON, ToJSON)

PlutusTx.makeIsDataIndexed ''AssetPurchaseDatum [('AssetPurchaseDatum, 0)]

--pragma {# INLINABLE func #}: allows the compiler to inline the definition of `purchaseValidator` inside the `||` brackets
--Any function that is to be used for on-chain code will need this validator.
{-# INLINABLE purchaseValidator #-}

--this function will be supplied to `mkTypedValidator` which will compile it into Plutus Core.
purchaseValidator :: AssetPurchaseDatum -> TokenName -> ScriptContext -> Bool 
purchaseValidator  dat assetTn context  = validate 
    where
        validate ::  Bool
        validate =    txHasOneScInputOnly 
                   && validateTxOuts 

        txHasOneScInputOnly :: ScriptContext -> Bool
        txHasOneScInputOnly context =
          length (filter isJust $ toValidatorHash . txOutAddress . txInInfoResolved <$> txInfoInputs (scriptContextTxInfo context)) == 1

        validateTxOuts :: Bool
        validateTxOuts = any txOutValidate (txInfoOutputs (scriptContextTxInfo context))

        txOutValidate :: TxOut -> Bool
        txOutValidate txo = containsRequiredCollateralAmount txo

        containsRequiredCollateralAmount :: TxOut -> Bool
        containsRequiredCollateralAmount txo =
          collateralAmnt dat <= assetClassValueOf (txOutValue txo) (collateral dat)

        valuePaidToAddress :: ScriptContext -> Address -> Value
        valuePaidToAddress ctx addr = mconcat (fmap txOutValue (filter (\x -> txOutAddress x == addr) (txInfoOutputs (info ctx))))
--for typed validators, we need to inform the Plutus compiler by creating a new type that encodes 
--the information about the datum and redeemer that plutus core expects.
data TypedValidator
instance Scripts.ValidatorTypes TypedValidator where
    type instance DatumType TypedValidator = AssetPurchaseDatum
    type instance RedeemerType TypedValidator = TokenName 

typedValidator :: Scripts.TypedValidator TypedValidator
typedValidator = Scripts.mkTypedValidator @TypedValidator
    $$(PlutusTx.compile [|| purchaseValidator ||])
    $$(PlutusTx.compile [|| wrap ||])
  where
    wrap = Scripts.wrapValidator @AssetPurchaseDatum @TokenName

validator :: Validator
validator = Scripts.validatorScript typedValidator

--generate hash of the validator
valHash :: Ledger.ValidatorHash
valHash = Scripts.validatorHash typedValidator

--generate address from the validator
scrAddress :: Ledger.Address
scrAddress = scriptAddress validator

