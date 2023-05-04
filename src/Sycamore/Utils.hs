{-# LANGUAGE GADTs            #-}
{-# LANGUAGE TypeApplications #-}

module Sycamore.Utils
    ( unsafeReadTxOutRef
    -- , writeJSON, writeUnit
    , writeMintingPolicy
    , unsafeTokenNameToHex
    , wrapValidator
    ) where

import           Cardano.Api                (AsType (AsAssetName), FileError,
                                             PlutusScript, PlutusScriptV2,
                                             deserialiseFromRawBytes,
                                             serialiseToRawBytesHex,
                                             writeFileTextEnvelope)
import           Cardano.Api.Shelley        (PlutusScript (..),
                                             ScriptDataJsonSchema (ScriptDataJsonDetailedSchema),
                                             fromPlutusData, scriptDataToJson)
import           Codec.Serialise            (serialise)
import qualified Data.ByteString.Char8      as BS8
import qualified Data.ByteString.Lazy       as LBS
import qualified Data.ByteString.Short      as SBS
import           Data.Maybe                 (fromJust, fromMaybe)
import           Data.String                (IsString (..))
import           Plutus.V2.Ledger.Api       (ScriptContext, UnsafeFromData,
                                             unsafeFromBuiltinData)
import qualified Plutus.V2.Ledger.Api       as PlutusV2
import           PlutusTx                   (Data (..))
import           PlutusTx.Builtins.Internal (BuiltinByteString (..))
import           PlutusTx.Prelude           (Bool, BuiltinData, check, ($))

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

{-# INLINABLE wrapValidator #-}
wrapValidator :: ( UnsafeFromData a
                 , UnsafeFromData b
                 )
              => (a -> b -> ScriptContext -> Bool)
              -> (BuiltinData -> BuiltinData -> BuiltinData -> ())
wrapValidator f a b ctx =
  check PlutusTx.Prelude.$ f
      (unsafeFromBuiltinData a)
      (unsafeFromBuiltinData b)
      (unsafeFromBuiltinData ctx)