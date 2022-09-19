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

module Sycamore.AssetPurchase where 

import           Control.Monad        hiding (fmap)
import           Data.List.NonEmpty   (NonEmpty (..))
import           Data.Map             as Map
import           Data.Text            (pack, Text)
import           Data.Void 
import           Prelude              (IO, Semigroup (..), String, undefined) 
import           Ledger               hiding (singleton)
import           Ledger.Constraints   as Constraints
import qualified Ledger.Typed.Scripts as    Scripts
import           Ledger.Ada           as Ada
import           Plutus.Contract      
import           PlutusTx             (Data (..))
import qualified PlutusTx
import           PlutusTx.Prelude     hiding (Semigroup(..),unless)
import           Schema               (ToSchema)
import           Text.Printf          (printf)


data AssetPurchaseDatum = AssetPurchaseDatum {

    address1 :: Address
   ,address2 :: Address
}

PlutusTx.makeIsDataIndexed ''AssetPurchaseDatum [('AssetPurchaseDatum, 0)]

--this pragma allows the compiler to inline the definition of `mkValidator` inside the `||` brackets
--Any function that is to be used for on-chain code will need this validator.
{-# INLINABLE mkValidator #-}
--this function will be supplied to `mkValidator` which will compile it into Plutus Core to lockToContract a Validator.
purchaseValidator :: () -> AssetPurchaseDatum -> ScriptContext -> Bool 
purchaseValidator _ (DataAccessRedeemer r) _ = traceIfFalse "Wrong Redeemer" $ r == 42

--wtih typed data more boiler-plate code is required
data Typed
instance Scripts.ValidatorTypes Typed where
    type instance DatumType Typed = ()
    type instance RedeemerType Typed = DataAccessRedeemer 

typedValidator :: Scripts.TypedValidator Typed
typedValidator = Scripts.mkTypedValidator @Typed
    $$(PlutusTx.compile [|| mkValidator ||])
    $$(PlutusTx.compile [|| wrap ||])
  where
    wrap = Scripts.wrapValidator @() @DataAccessRedeemer

validator :: Validator
validator = Scripts.validatorScript typedValidator

--generate hash of the validator
valHash :: Ledger.ValidatorHash
valHash = Scripts.validatorHash typedValidator

--generate address from the validator
scrAddress :: Ledger.Address
scrAddress = scriptAddress validator

