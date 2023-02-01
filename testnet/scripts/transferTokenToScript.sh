cardano-cli transaction build-raw \
    --babbage-era \
    --tx-in 1c2852bb9db7e93fe9d2caa55f7a71baa4364f19ebe530e699e2951d36106468#0  \
    --tx-out-datum-hash-file "../upp/lock-script/unit.json" \
    --tx-out $(cat ../upp/lock-script/uppv2_test$1.addr)+8000000+" 1 a43a7d6880b85c60bfe4fac5ddd588ad8ad685ac18c1d8b43528d849.41522d555050233138" \
    --tx-out  $(cat ../wallets/minter/minter.addr)+1822135 \
    --out-file "../upp/lock-script/txs/tx.raw" \
    --fee 177865

cardano-cli transaction sign \
--signing-key-file "../wallets/minter/minter.skey" \
--tx-body-file  "../upp/lock-script/txs/tx.raw" \
--out-file "../upp/lock-script/txs/tx.signed"  \
--$TS 

cardano-cli transaction submit --tx-file "../upp/lock-script/txs/tx.signed" --$TS 
