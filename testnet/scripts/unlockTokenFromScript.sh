cardano-cli transaction build \
     --babbage-era \
    --tx-in 097ce2a71a28846272ce5a23fbeb825c253857ef8b2373f2e8d5537f3ece2bed#0 \
    --tx-in-datum-file "../upp/unlock-script/unit.json" \
    --tx-in-redeemer-file "../upp/unlock-script/unit.json" \
    --tx-in-script-file "../upp/lock-script/uppv2_test01.plutus" \
    --tx-out $(cat ../wallets/buyer/buyer.addr)+"1500000 lovelace + 1 a43a7d6880b85c60bfe4fac5ddd588ad8ad685ac18c1d8b43528d849.41522d555050233138" \
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

