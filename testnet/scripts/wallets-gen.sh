#!/bin/bash

dir=$1
rootDir=../wallets
walletDir=$rootDir/$dir

if [ ! -d "$walletDir" ] 
then 
    mkdir $walletDir
    cd $walletDir
else 
    echo "wallet directory exists"
    exit 1
fi

cardano-cli address key-gen --verification-key-file $dir.vkey --signing-key-file $dir.skey && \
cardano-cli address build --payment-verification-key-file $dir.vkey --out-file $dir.addr --$TS 
