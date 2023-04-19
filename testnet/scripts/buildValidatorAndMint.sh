#!/bin/bash

ASSET_TITLE=$1
PUBLISHER_PHK=$2
BENEFACTOR_PHKS=$3
WORK_DIR=/home/prometheus/projects/afyarekod-upp/sycamore-contracts
APP_DIR=/home/prometheus/projects/plutus-apps

#Drop into nix shell
export LD_LIBRARY_PATH=''
cd $APP_DIR
nix-shell --command "cd ${WORK_DIR} && echo $PWD && cabal exec serialise-validator ${ASSET_TITLE} ${PUBLISHER_PHK} ${BENEFACTOR_PKHS} && cd ${WORK_DIR}/testnet/scripts && ./generateScriptAddress ${ASSET_TITLE} && "

