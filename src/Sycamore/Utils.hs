{-# LANGUAGE GADTs            #-}
{-# LANGUAGE TypeApplications #-}

module Sycamore.Utils
    ( unsafeReadTxOutRef
    -- , writeJSON, writeUnit
    , writeMintingPolicy
    , unsafeTokenNameToHex
    ) where

import           Cardano.Api                          (PlutusScript,
                                                       PlutusScriptV2, FileError,
                                                       writeFileTextEnvelope, AsType(AsAssetName), deserialiseFromRawBytes, serialiseToRawBytesHex)
import           Cardano.Api.Shelley                  (PlutusScript (..),
                                                       ScriptDataJsonSchema (ScriptDataJsonDetailedSchema),
                                                       fromPlutusData,
                                                       scriptDataToJson)
import           Codec.Serialise (serialise)
-- import           Data.Aeson                           as A
import qualified Data.ByteString.Char8       as BS8
import qualified Data.ByteString.Lazy        as LBS
import qualified Data.ByteString.Short       as SBS
import           Data.Maybe                  (fromJust, fromMaybe)
import           Data.String                 (IsString (..))
import           PlutusTx                    (Data (..))
import qualified PlutusTx
import           PlutusTx.Builtins.Internal  (BuiltinByteString (..))
import qualified Plutus.V2.Ledger.Api                 as PlutusV2

--utility function to get the utxo TxOutRef object from a utxo string
unsafeReadTxOutRef :: String -> PlutusV2.TxOutRef
unsafeReadTxOutRef s =
  let
    (x, _ : y) = span (/= '#') s
  in
    PlutusV2.TxOutRef
        { PlutusV2.txOutRefId  = fromString x
        , PlutusV2.txOutRefIdx = read y
        }

writeMintingPolicy :: FilePath -> PlutusV2.MintingPolicy -> IO (Either (FileError ()) ())
writeMintingPolicy file = writeFileTextEnvelope @(PlutusScript PlutusScriptV2) file Nothing . PlutusScriptSerialised . SBS.toShort . LBS.toStrict . serialise . PlutusV2.unMintingPolicyScript


unsafeTokenNameToHex :: PlutusV2.TokenName -> String
unsafeTokenNameToHex = BS8.unpack . serialiseToRawBytesHex . fromJust . deserialiseFromRawBytes AsAssetName . getByteString . PlutusV2.unTokenName
  where
    getByteString (BuiltinByteString bs) = bs

