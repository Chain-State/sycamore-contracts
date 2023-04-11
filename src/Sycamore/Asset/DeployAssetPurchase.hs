{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications  #-}

module Sycamore.Asset.DeployAssetPurchase
    ( writeJSON
    , writeValidator
    , writeAssetPurchaseValidator
    , writeUnit
    , writeRedeemer
    ) where

import           Cardano.Api
import           Cardano.Api.Shelley   (PlutusScript (..))
import           Codec.Serialise       (serialise)
import           Data.Aeson            (encode)
import qualified Data.ByteString.Lazy  as LBS
import qualified Data.ByteString.Short as SBS
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE

import           PlutusTx              (Data (..))
import qualified PlutusTx
import qualified Plutus.V2.Ledger.Api as L
import qualified Data.String as DS
import qualified Ledger.Value

import          Sycamore.Asset.AssetPurchase 

dataToScriptData :: Data -> ScriptData
dataToScriptData (Constr n xs) = ScriptDataConstructor n $ dataToScriptData <$> xs
dataToScriptData (Map xs)      = ScriptDataMap [(dataToScriptData x, dataToScriptData y) | (x, y) <- xs]
dataToScriptData (List xs)     = ScriptDataList $ dataToScriptData <$> xs
dataToScriptData (I n)         = ScriptDataNumber n
dataToScriptData (B bs)        = ScriptDataBytes bs

writeJSON :: PlutusTx.ToData a => FilePath -> a -> IO ()
writeJSON file = LBS.writeFile file . encode . scriptDataToJson ScriptDataJsonDetailedSchema . dataToScriptData . PlutusTx.toData

writeValidator :: FilePath -> L.Validator -> IO (Either (FileError ()) ())
writeValidator file = writeFileTextEnvelope @(PlutusScript PlutusScriptV2) file Nothing . PlutusScriptSerialised . SBS.toShort . LBS.toStrict . serialise . L.unValidatorScript

writeUnit :: IO ()
writeUnit = writeJSON "testnet/upp/lock-script/unit.json" ()

writeRedeemer :: IO () 
writeRedeemer = writeJSON "testnet/upp/lock-script/redeemer.json" ()

writeAssetPurchaseValidator :: IO (Either (FileError ()) ())
writeAssetPurchaseValidator = writeValidator "testnet/upp/lock-script/uppv2_test05.plutus" $ validator $ AssetPurchase 
                                {
                                    saleNftTn = Ledger.Value.tokenName $ TE.encodeUtf8 $ T.pack "AR#22"
                                   ,minter = L.PubKeyHash $ L.getLedgerBytes $ DS.fromString "04c5fe2f355eb590378f98193d4b71c93d9149444e979f7a6b37f4d8"
                                   ,minterCurrency = Ledger.Value.assetClass (Ledger.Value.currencySymbol "") (Ledger.Value.tokenName  $ TE.encodeUtf8 $ T.pack "")
                                   ,minterAmount = 2000000
                                   ,beneficiary = L.PubKeyHash $ L.getLedgerBytes $ DS.fromString  "be50558acab3ad6b869be265e9c22e421a366aac6e61bf8b1c43ee8a"
                                   ,beneficiaryCurrency = Ledger.Value.assetClass (Ledger.Value.currencySymbol "") (Ledger.Value.tokenName  $ TE.encodeUtf8 $ T.pack "")
                                   ,beneficiaryAmount = 2000000
                                   ,collateral = Ledger.Value.assetClass (Ledger.Value.currencySymbol "") (Ledger.Value.tokenName $ TE.encodeUtf8 $ T.pack "")
                                   ,collateralAmnt = 2000000
                                   ,saleExpiresOn = 1680952180000
                                }