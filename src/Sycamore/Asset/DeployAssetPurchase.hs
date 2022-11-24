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
writeUnit = writeJSON "testnet/af/lock-script/unit.json" ()

writeRedeemer :: IO () 
writeRedeemer = writeJSON "testnet/af/lock-script/redeemer.json" ()

writeAssetPurchaseValidator :: IO (Either (FileError ()) ())
writeAssetPurchaseValidator = writeValidator "testnet/af/lock-script/dynbaya-purchase.plutus" $ validator $ AssetPurchase 
                                {
                                    saleNftTn = Ledger.Value.tokenName $ TE.encodeUtf8 $ T.pack "DYNASTY-BAYA"
                                   ,aggregator = L.pubKeyHashAddress (L.PaymentPubKeyHash $  L.PubKeyHash $ BuiltinByteString $  TE.encodeUtf8 $ T.pack "d3c3cb0b7bbcd93d7e6bd6ac4e222d1e2f68eecf43f84f1e1dc21f62") Nothing 
                                   ,aggregatorCurrency = Ledger.Value.assetClass (Ledger.Value.currencySymbol "") (Ledger.Value.tokenName  $ TE.encodeUtf8 $ T.pack "")
                                   ,aggregatorAmount = 2000000
                                   ,beneficiary = L.pubKeyHashAddress (L.PaymentPubKeyHash $  L.PubKeyHash $ BuiltinByteString $  TE.encodeUtf8 $ T.pack "da23034939ff35e8d65f4280b30c64274ce528df929deb94708727e1") Nothing
                                   ,beneficiaryCurrency = Ledger.Value.assetClass (Ledger.Value.currencySymbol "") (Ledger.Value.tokenName  $ TE.encodeUtf8 $ T.pack "")
                                   ,beneficiaryAmount = 2000000
                                   ,collateral = Ledger.Value.assetClass (Ledger.Value.currencySymbol "") (Ledger.Value.tokenName $ TE.encodeUtf8 $ T.pack "")
                                   ,collateralAmnt = 2000000
                                }