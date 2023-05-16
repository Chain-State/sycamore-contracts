{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications  #-}
{-# LANGUAGE LambdaCase #-}

module Sycamore.Asset.DeployAssetPurchase
    ( 
        -- writeJSON
     writeAssetPurchaseValidator
    -- , writeUnit
    -- , writeRedeemer
    ) where



import qualified Data.String                  as DS

import           Cardano.Api           (Error (displayError), PlutusScript,
                                        PlutusScriptV2, prettyPrintJSON,
                                        writeFileJSON, writeFileTextEnvelope)
import           Cardano.Api.Shelley   (PlutusScript (..), fromPlutusData,
                                        scriptDataToJsonDetailedSchema)
import           Codec.Serialise       (Serialise, serialise)
import qualified Data.ByteString.Char8 as BS8
import qualified Data.ByteString.Lazy  as BSL
import qualified Data.ByteString.Short as BSS
import Plutus.V2.Ledger.Api (TokenName(..), Validator(..), CurrencySymbol(..), PubKeyHash(..),singleton, getLedgerBytes, adaSymbol, adaToken, fromBytes)

import           Sycamore.Asset.AssetPurchase


-- writeValidator :: FilePath -> L.Validator -> IO (Either (FileError ()) ())
-- writeValidator file = writeFileTextEnvelope @(PlutusScript PlutusScriptV2) file Nothing . PlutusScriptSerialised . SBS.toShort . LBS.toStrict . serialise . L.unValidatorScript

-- writeUnit :: IO ()
-- writeUnit = writeJSON "testnet/upp/lock-script/unit.json" ()

-- writeRedeemer :: IO ()
-- writeRedeemer = writeJSON "testnet/upp/lock-script/redeemer.json" ()

serializableToScript :: Serialise a => a -> PlutusScript PlutusScriptV2
serializableToScript = PlutusScriptSerialised . BSS.toShort . BSL.toStrict . serialise

-- Serialize validator
validatorToScript :: Validator -> PlutusScript PlutusScriptV2
validatorToScript = serializableToScript

-- Create file with Plutus script
writeScriptToFile :: FilePath -> PlutusScript PlutusScriptV2 -> IO ()
writeScriptToFile filePath script =
  writeFileTextEnvelope filePath Nothing script >>= \case
    Left err -> print $ displayError err
    Right () -> putStrLn $ "Serialized script to: " ++ filePath

-- Create file with compiled Plutus validator
writeValidatorToFile :: FilePath -> Validator -> IO ()
writeValidatorToFile filePath = writeScriptToFile filePath . validatorToScript


writeAssetPurchaseValidator :: String -> String -> IO ()
writeAssetPurchaseValidator filePath assetName = writeValidatorToFile filePath $ validator $ AssetPurchase
                                {
                                    saleNftTn = TokenName $  DS.fromString assetName
                                   ,minterPkh = PubKeyHash $ getLedgerBytes $ DS.fromString "04c5fe2f355eb590378f98193d4b71c93d9149444e979f7a6b37f4d8" 
                                   ,minterValue = singleton adaSymbol adaToken 2000000
                                   ,collateralValue = singleton adaSymbol adaToken 2000000                              
                                   ,saleExpiresOn =1735689600 
                                }