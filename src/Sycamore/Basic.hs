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

module Basic where 

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
import qualified Ledger.Scripts as    Scripts
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
mkValidator :: BuiltinData -> BuiltinData -> BuiltinData -> ()
mkValidator _ _ _ = ()


--The `$$` will take the syntax tree and splice it into this part of the Haskell code.
--The oxford brackets `||` convert the compiled Plutus Core code into a syntax tree.
validator :: Validator
validator = mkValidatorScript $$(PlutusTx.compile [|| mkValidator ||])

--generate hash of the validator
valHash :: Ledger.ValidatorHash
valHash = Scripts.validatorHash validator

--generate address from the validator
scrAddress :: Ledger.Address
scrAddress = scriptAddress validator


--Define endpoints (Functions that will allow users to enter data and trigger actions on the validators)

type BasicSchema = Endpoint "lockToContract" Integer
            .\/    Endpoint "unlockFromContract" ()

lockToContract :: AsContractError e => Integer -> Contract w s e ()
lockToContract amount = do
    let tx = mustPayToOtherScript valHash (Datum $ BuiltIns.mkI 0) $ Ada.lovelaceValueOf amount
    ledgerTx <- submitTx tx
    void $ awaitTxConfirmed $ getCardanoTxId ledgerTx
    logInfo @String $ printf "Sent %d Ada to contract" amount


unlockFromContract :: forall w s e. AsContractError e => Contract w s e ()
unlockFromContract = do
    utxos <- utxosAt scrAddress
    let orefs = fst <$> Map.toList utxos 
        lookups = Constraints.unspentOutputs utxos <>
                  Constraints.otherScript validator
        tx :: Constraints.TxConstraints Void Void
        tx = mconcat [mustSpendScriptOutput oref $ Redeemer $ BuiltIns.mkI 17 | oref <- orefs]
    ledgerTx <- submitTxConstraintsWith @Void lookups tx
    void $ awaitTxConfirmed $ getCardanoTxId ledgerTx
    logInfo @String $ "Ada amount collected"

endpoints :: Contract () BasicSchema Text ()
endpoints = awaitPromise (lockToContract' `select` unlockFromContract') >> endpoints
  where 
    lockToContract' = endpoint @"lockToContract" lockToContract
    unlockFromContract' = endpoint @"unlockFromContract" $ const unlockFromContract

mkSchemaDefinitions ''BasicSchema

mkKnownCurrencies []
