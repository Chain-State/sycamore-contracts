#!/bin/bash

cardano-cli transaction build \
     --babbage-era \
    --tx-in 8cf50142a6be9eb1ef5c4ba3a8cc3276fd922baeba00316012f5fc9ec4053a46#0 \
    --tx-in-datum-file "../upp/unlock-script/unit.json" \
    --tx-in-redeemer-file "../upp/unlock-script/unit.json" \
    --tx-in-script-file "../upp/lock-script/AR#3444.plutus" \
    --tx-out $(cat ../wallets/buyer/buyer.addr)+"2000000 lovelace + 1 9990c8ac2bb155d18789b1230c0208692b0f86e7537defd24e0cf38d.41522333343434" \
    --tx-out $(cat ../wallets/minter/minter.addr)+2000000 \
    --tx-out $(cat ../wallets/beneficiary/beneficiary.addr)+2000000 \
    --tx-in-collateral 48e4403bc4fb285a4232be59c79136555731ee231402ae38a379c8e1501bc6c7#1 \
    --change-address $(cat ../wallets/minter/minter.addr) \
    --protocol-params-file "../upp/mint/protocol-params.json" \
    --out-file "../upp/unlock-script/txs/tx.body" \
    --$TS

cardano-cli transaction sign \
    --tx-body-file "../upp/unlock-script/txs/tx.body" \
    --signing-key-file "../wallets/minter/minter.skey" \
    --$TS \
    --out-file "../upp/unlock-script/txs/tx.signed"

cardano-cli transaction submit \
    --$TS \
   --tx-file "../upp/unlock-script/txs/tx.signed"

