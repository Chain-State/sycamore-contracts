#!/bin/bash

ASSET_TITLE=$1
WORK_DIR=/home/prometheus/projects/afyarekod-upp/sycamore-contracts
APP_DIR=/home/prometheus/projects/plutus-apps

#Drop into nix shell
export LD_LIBRARY_PATH=''
cd $APP_DIR
nix-shell --command "cd ${WORK_DIR} && echo $PWD && cabal exec serialise-validator ${ASSET_TITLE}"

