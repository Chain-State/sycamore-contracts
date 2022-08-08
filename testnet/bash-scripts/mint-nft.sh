#!/bin/bash

oref=$1
amt=$2
tokenName=$3
addrFile=$4
skeyFile=$5

export CARDANO_NODE_SOCKET_PATH=node.socket

rootDir=../nft-mint
echo "oref: $oref"
echo "amt: $amt"
echo "tokenName: $tokenName"
echo "address file: $addrFile"
echo "signing key file: $skeyFile"

protocolParams=$rootDir/protocol-parameters.json
cardano-cli query protocol-parameters --$TESTNET --out-file $protocolParams

serializedPolicyScriptFile=$rootDir/token.plutus
cabal exec token-policy $serializedPolicyScriptFile $oref $amt $tokenName

unsignedFile=$rootDir/tx.unsigned
signedFile=$rootDir/tx.signed
policyId=$(cardano-cli transaction policyid --script-file $serializedPolicyScriptFile)
tokenNameHex=$(cabal exec token-name-hex -- $tokenName)
address=$(cat $addrFile)
value="$amt $policyId.$tokenNameHex"

echo "currency symbol: $policyId"
echo "token name (hex): $tokenNameHex"
echo "minted value: $value"
echo "address: $address"

cardano-cli transaction build \
    --$TESTNET \
    --tx-in $oref \
    --tx-in-collateral $oref \
    --tx-out "$address + 1500000 lovelace + $value" \
    --mint "$value" \
    --mint-script-file $serializedPolicyScriptFile \
    --mint-redeemer-file $rootDir/unit.json \
    --change-address $address \
    --protocol-params-file $protocolParams\
    --out-file $unsignedFile \

cardano-cli transaction sign \
    --tx-body-file $unsignedFile \
    --signing-key-file $skeyFile \
    --$TESTNET \
    --out-file $signedFile

cardano-cli transaction submit \
    --$TESTNET \
    --tx-file $signedFile