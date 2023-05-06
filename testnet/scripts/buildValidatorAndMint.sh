#!/bin/bash

ASSET_TITLE=$1
PUBLISHER_PHK=$2
BENEFACTOR_PHKS=$3
WORK_DIR=/home/prometheus/projects/afyarekod-upp/sycamore-contracts
APP_DIR=/home/prometheus/projects/plutus-apps

UTXO=4b9d7ca47e5b222832515373034be4b58d4af4f0634d8dc04f7be458bc9f9a14#1
SCRIPT_ADDR_FILE=${WORK_DIR}/testnet/upp/lock-script/${ASSET_TITLE}.addr
MINT_SIGN_KEY=${WORK_DIR}/testnet/wallets/minter/minter.skey


echo "Asset Title " ${ASSET_TITLE}
echo "PUBLISHER_PHK" ${PUBLISHER_PHK}
echo "BENEFACTOR_PHKS" "${BENEFACTOR_PHKS}"
echo "VALIDATOR_ADDRESS" ${VALIDATOR_ADDRESS}

#Drop into nix shell
export LD_LIBRARY_PATH=''
cd $APP_DIR && 
nix-shell --command "cd ${WORK_DIR} && cabal exec serialise-validator -- ${ASSET_TITLE} ${PUBLISHER_PHK} "${BENEFACTOR_PHKS}" && cd ${WORK_DIR}/testnet/scripts && ./generateScriptAddress ${ASSET_TITLE} && ./mintTokenToAddress.sh ${UTXO} 1  ${ASSET_TITLE} ${SCRIPT_ADDR_FILE} ${MINT_SIGN_KEY}"