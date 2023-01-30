#! /bin/bash

cd .. && \
cd wallets && \
mkdir $1 && \
cd $1 &&  \
cardano-cli address key-gen --verification-key-file $1.vkey --signing-key-file $1.skey && \
cardano-cli address build --payment-verification-key-file $1.vkey --out-file $1.addr --$TS 