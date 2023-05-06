#!/bin/bash

cardano-cli transaction build \
     --babbage-era \
    --tx-in 4b9d7ca47e5b222832515373034be4b58d4af4f0634d8dc04f7be458bc9f9a14#0 \
    --tx-in-datum-file "../upp/unlock-script/unit.json" \
    --tx-in-redeemer-file "../upp/unlock-script/unit.json" \
    --tx-in-script-file "../upp/lock-script/SYS-66#0004.plutus" \
    --tx-out $(cat ../wallets/buyer/buyer.addr)+"3000000 lovelace + 1 a0ae6907a9ac0e5a2ee059fbd206130396f5f6ec61c7f319c14ee936.5359532d36362330303034" \
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

