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
import qualified Ledger as L
import qualified Ledger.Value
import PlutusTx.Builtins.Internal

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
writeValidator file = writeFileTextEnvelope @(PlutusScript PlutusScriptV1) file Nothing . PlutusScriptSerialised . SBS.toShort . LBS.toStrict . serialise . L.unValidatorScript

writeUnit :: IO ()
writeUnit = writeJSON "testnet/afia-validation/unit.json" ()

writeRedeemer :: IO () 
writeRedeemer = writeJSON "testnet/afia-validation/redeemer.json" ()

writeAssetPurchaseValidator :: IO (Either (FileError ()) ())
writeAssetPurchaseValidator = writeValidator "testnet/afia-validation/asset-purchase.plutus" $ validator $ AssetPurchase 
                                {
                                    saleNftTn = Ledger.Value.tokenName $ TE.encodeUtf8 $ T.pack "Afia#01"
                                   ,aggregator = L.pubKeyHashAddress (L.PaymentPubKeyHash $  L.PubKeyHash $ BuiltinByteString $  TE.encodeUtf8 $ T.pack "ccd0cf6cb232ad4def96ebe39dfb4b354a529faed336a086b3c13f4a") Nothing 
                                   ,aggregatorCurrency = Ledger.Value.assetClass (Ledger.Value.currencySymbol "lovelace") (Ledger.Value.tokenName  $ TE.encodeUtf8 $ T.pack "Ada")
                                   ,aggregatorAmount = 20000000
                                   ,beneficiary = L.pubKeyHashAddress (L.PaymentPubKeyHash $  L.PubKeyHash $ BuiltinByteString $  TE.encodeUtf8 $ T.pack "7a9655c5999a67a71c9ea9d7453ad04e178f7cb368b93ad65dd6cc27") Nothing
                                   ,collateral = Ledger.Value.assetClass (Ledger.Value.currencySymbol "lovelace") (Ledger.Value.tokenName $ TE.encodeUtf8 $ T.pack "Ada")
                                   ,collateralAmnt = 2000000
                                }