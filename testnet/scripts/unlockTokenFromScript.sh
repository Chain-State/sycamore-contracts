#!/bin/bash

cardano-cli transaction build \
     --babbage-era \
    --tx-in 5d05759fa2f517cbd3729bb97e1920716f3bef35c0486723e17794eece705c10#0 \
    --tx-in-datum-file "../upp/unlock-script/unit.json" \
    --tx-in-redeemer-file "../upp/unlock-script/unit.json" \
    --tx-in-script-file "../upp/lock-script/AR#8193.plutus" \
    --tx-out $(cat ../wallets/buyer/buyer.addr)+"2000000 lovelace + 1 4a4e1d84b102c7b67873a98c0801124ad5680e443d84666973bfa4d2.41522338313933" \
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

