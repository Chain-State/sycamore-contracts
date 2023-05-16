#!/bin/bash

ASSET_TITLE=$1
PUBLISHER_PHK=$2
BENEFACTOR_PHKS=$3
WORK_DIR=/home/prometheus/projects/afyarekod-upp/sycamore-contracts
APP_DIR=/home/prometheus/projects/plutus-apps

UTXO="6a6239f7862f68f613f6f2a8f615b6f136dc104f8bfcdc6cef15207245c69129#1"
SCRIPT_ADDR_FILE=${WORK_DIR}/testnet/upp/lock-script/${ASSET_TITLE}.addr
MINT_SIGN_KEY=${WORK_DIR}/testnet/wallets/minter/minter.skey


echo "Asset Title " ${ASSET_TITLE}
echo "PUBLISHER_PHK" ${PUBLISHER_PHK}
echo "BENEFACTOR_PHKS" "${BENEFACTOR_PHKS}"
echo "VALIDATOR_ADDRESS" ${VALIDATOR_ADDRESS}

#Drop into nix shell
export LD_LIBRARY_PATH=''
cd $APP_DIR && 
nix-shell --command "cd ${WORK_DIR} && cabal exec serialise-validator -- ${ASSET_TITLE} && cd ${WORK_DIR}/testnet/scripts && ./generateScriptAddress ${ASSET_TITLE} && ./mintTokenToAddress.sh ${UTXO} 1  ${ASSET_TITLE} ${SCRIPT_ADDR_FILE} ${MINT_SIGN_KEY} && exit;"