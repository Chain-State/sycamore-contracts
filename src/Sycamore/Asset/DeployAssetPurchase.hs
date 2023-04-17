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

makeList :: [String] -> [L.PubKeyHash]
makeList [] = []
makeList (x:xs) =  (L.PubKeyHash $ L.getLedgerBytes $ DS.fromString x) : makeList xs 

writeAssetPurchaseValidator :: String -> String -> String -> [String] -> IO (Either (FileError ()) ())
writeAssetPurchaseValidator file assetName publisherPkhs beneficiaryPbkhs = writeValidator file $ validator $ AssetPurchase 
                                {
                                    saleNftTn = Ledger.Value.tokenName $ TE.encodeUtf8 $ T.pack assetName 
                                   ,minter = L.PubKeyHash $ L.getLedgerBytes $ DS.fromString publisherPkhs  
                                   ,minterCurrency = Ledger.Value.assetClass (Ledger.Value.currencySymbol "") (Ledger.Value.tokenName  $ TE.encodeUtf8 $ T.pack "")
                                   ,minterAmount = 2000000
                                   ,beneficiary = makeList beneficiaryPbkhs 
                                   ,beneficiaryCurrency = Ledger.Value.assetClass (Ledger.Value.currencySymbol "") (Ledger.Value.tokenName  $ TE.encodeUtf8 $ T.pack "")
                                   ,beneficiaryAmount = 2000000
                                   ,collateral = Ledger.Value.assetClass (Ledger.Value.currencySymbol "") (Ledger.Value.tokenName $ TE.encodeUtf8 $ T.pack "")
                                   ,collateralAmnt = 2000000
                                   ,saleExpiresOn = 1680952180000
                                }