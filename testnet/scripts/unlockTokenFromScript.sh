#!/bin/bash

cardano-cli transaction build \
    --babbage-era \
    --tx-in "95a47bd5f1b18e89cd2c45edbe16c46fa8dacdb9e660ce1e35efffb3256120a2#0" \
    --tx-in-inline-datum-present \
    --tx-in-redeemer-file "../upp/unlock-script/unit.json" \
    --tx-in-script-file "../upp/lock-script/8820.plutus" \
    --tx-out $(cat ../wallets/buyer/buyer.addr)+"3000000 lovelace + 1 e530fab7c51a58961879def3365371e0b16b29510fdbddcbb0caa291.38383230" \
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

