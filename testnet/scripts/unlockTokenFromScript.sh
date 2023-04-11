cardano-cli transaction build \
     --babbage-era \
    --tx-in deefa95c8a926fc0cff2e4da92c5cb01c9ee0c32281985805225a460c78ba425#0 \
    --tx-in-datum-file "../upp/unlock-script/unit.json" \
    --tx-in-redeemer-file "../upp/unlock-script/unit.json" \
    --tx-in-script-file "../upp/lock-script/uppv2_test02.plutus" \
    --tx-out $(cat ../wallets/buyer/buyer.addr)+"1500000 lovelace + 1 d6090a22c2b52c2c5754a9d4a433b13522efda95a72b56287521f8a8.4152233139" \
    --tx-out $(cat ../wallets/beneficiary/beneficiary.addr)+2000000 \
    --tx-out $(cat ../wallets/minter/minter.addr)+2000000 \
    --tx-in-collateral "161be5322f5b0e2ddb5045a99629e23d902b12408bcee6f494f646841f930207#0" \
    --change-address $(cat ../wallets/buyer/buyer.addr) \
    --protocol-params-file "../upp/unlock-script/protocol-params.json" \
    --out-file "../upp/unlock-script/txs/tx.body" \
    --$TS

cardano-cli transaction sign \
    --tx-body-file "../upp/unlock-script/txs/tx.body" \
    --signing-key-file "../wallets/buyer/buyer.skey" \
    --$TS \
    --out-file "../upp/unlock-script/txs/tx.signed"

cardano-cli transaction submit \
    --$TS \
   --tx-file "../upp/unlock-script/txs/tx.signed"

