cardano-cli transaction build-raw \
    --babbage-era \
    --tx-in 18e4b24f0ffef55527af458e49541f95b02fe6e1c1283df1c0029b474f6115f1#0  \
    --tx-in 18e4b24f0ffef55527af458e49541f95b02fe6e1c1283df1c0029b474f6115f1#3  \
    --tx-in 35b7c6b7ca0cef72895f7cc514106e3a3fd4ebb7de17d05e2deb88badac2c71b#1  \
    --tx-out-datum-hash-file "../af/lock-script/unit.json" \
    --tx-out $(cat ../wallets/scripts/test08.addr)+7000000+" 1 a1e1afeb55ce2fc39b66e3ff87594333393a634ed2d15660d9fdfd81.54455354233032" \
    --tx-out $(cat ../wallets/buyer/buyer.addr)+2209954 \
    --out-file "../af/lock-script/txs/tx.raw" \
    --fee 177865

cardano-cli transaction sign \
--signing-key-file "../wallets/buyer/buyer.skey" \
--tx-body-file  "../af/lock-script/txs/tx.raw" \
--out-file "../af/lock-script/txs/tx.signed"  \
--$TS 

cardano-cli transaction submit --tx-file "../af/lock-script/txs/tx.signed" --$TS 
