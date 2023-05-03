cardano-cli transaction build-raw \
    --babbage-era \
    --tx-in 285ad96cb21bb169fde23c97ba75de040bb2832f3d560e704a3c7edeb0f4bf4e#0  \
    --tx-in 161be5322f5b0e2ddb5045a99629e23d902b12408bcee6f494f646841f930207#0  \
    --tx-out $(cat ../upp/lock-script/uppv2_test02.addr)+20000000+" 1 d6090a22c2b52c2c5754a9d4a433b13522efda95a72b56287521f8a8.4152233139" \
    --tx-out $(cat ../wallets/buyer/buyer.addr)+81322135 \
    --tx-out-datum-hash-file "../upp/lock-script/unit.json" \
    --out-file "../upp/lock-script/txs/tx.raw" \
    --fee 177865

cardano-cli transaction sign \
--signing-key-file "../wallets/buyer/buyer.skey" \
--tx-body-file  "../upp/lock-script/txs/tx.raw" \
--out-file "../upp/lock-script/txs/tx.signed"  \
--$TS 

cardano-cli transaction submit --tx-file "../upp/lock-script/txs/tx.signed" --$TS 
