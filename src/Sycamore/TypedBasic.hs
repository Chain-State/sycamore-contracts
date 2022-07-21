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

module Sycamore.TypedBasic where 

import           Control.Monad        hiding (fmap)
import           Data.Aeson           (ToJSON, FromJSON)
import           Data.List.NonEmpty   (NonEmpty (..))
import           Data.Map             as Map
import           Data.Text            (pack, Text)
import           Data.Void 
import           GHC.Generics         (Generic)
import           Prelude              (IO, Semigroup (..), String, undefined) 
import           Ledger               hiding (singleton)
import           Ledger.Constraints   as Constraints
import qualified Ledger.Typed.Scripts as    Scripts
import           Ledger.Value         as Value
import           Ledger.Ada           as Ada
import           Playground.Contract  (IO, ensureKnownCurrencies, printSchemas, stage, printJson)
import           Playground.TH        (mkKnownCurrencies, mkSchemaDefinitions)
import           Playground.Types     (KnownCurrency (..))
import           Plutus.Contract      
import qualified PlutusTx
import qualified PlutusTx.Builtins    as BuiltIns
import           PlutusTx.Prelude     hiding (Semigroup(..),unless)
import           Schema               (ToSchema)
import           Text.Printf          (printf)

--this pragma allows the compiler to inline the definition of `mkValidator` inside the `||` brackets
--Any function that is to be used for on-chain code will need this validator.
{-# INLINABLE mkValidator #-}
--this function will be supplied to `mkValidator` which will compile it into Plutus Core to lockToContract a Validator.
mkValidator :: () -> Integer -> ScriptContext -> Bool 
mkValidator _ r _ = traceIfFalse "Wrong Redeemer" (r == 42)


--wtih typed data more boiler-plate code is required
data Typed
instance Scripts.ValidatorTypes Typed where
    type instance DatumType Typed = ()
    type instance RedeemerType Typed = Integer

typedValidator :: Scripts.TypedValidator Typed
typedValidator = Scripts.mkTypedValidator @Typed
    $$(PlutusTx.compile [|| mkValidator ||])
    $$(PlutusTx.compile [|| wrap ||])
  where
    wrap = Scripts.wrapValidator @() @Integer

validator :: Validator
validator = Scripts.validatorScript typedValidator

--generate hash of the validator
valHash :: Ledger.ValidatorHash
valHash = Scripts.validatorHash typedValidator

--generate address from the validator
scrAddress :: Ledger.Address
scrAddress = scriptAddress validator


--Define endpoints (Functions that will allow users to enter data and trigger actions on the validators)

type BasicSchema = Endpoint "lockToContract" Integer
            .\/    Endpoint "unlockFromContract" Integer 

lockToContract :: AsContractError e => Integer -> Contract w s e ()
lockToContract amount = do
    let tx = mustPayToOtherScript valHash (Datum $ BuiltIns.mkI 0) $ Ada.lovelaceValueOf amount
    ledgerTx <- submitTx tx
    void $ awaitTxConfirmed $ getCardanoTxId ledgerTx
    logInfo @String $ printf "Sent %d Ada to contract" amount


unlockFromContract :: forall w s e. AsContractError e => Integer -> Contract w s e ()
unlockFromContract n = do
    utxos <- utxosAt scrAddress
    let orefs = fst <$> Map.toList utxos 
        lookups = Constraints.unspentOutputs utxos <>
                  Constraints.otherScript validator
        tx :: Constraints.TxConstraints Void Void
        tx = mconcat [mustSpendScriptOutput oref $ Redeemer $ BuiltIns.mkI n | oref <- orefs]
    ledgerTx <- submitTxConstraintsWith @Void lookups tx
    void $ awaitTxConfirmed $ getCardanoTxId ledgerTx
    logInfo @String $ "Ada amount collected"

endpoints :: Contract () BasicSchema Text ()
endpoints = awaitPromise (lockToContract' `select` unlockFromContract') >> endpoints
  where 
    lockToContract' = endpoint @"lockToContract" lockToContract
    unlockFromContract' = endpoint @"unlockFromContract" unlockFromContract

mkSchemaDefinitions ''BasicSchema

mkKnownCurrencies []
