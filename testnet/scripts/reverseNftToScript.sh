cardano-cli transaction build-raw \
    --babbage-era \
    --tx-in c719b25f91ec01938236fad081ad4590d5d1b7eaef78fff3c4f09294f7e61082#0  \
    --tx-out-datum-hash-file "../af/lock-script/unit.json" \
    --tx-out $(cat ../wallets/scripts/test06.addr)+12000000+" 1 a1e1afeb55ce2fc39b66e3ff87594333393a634ed2d15660d9fdfd81.54455354233032" \
    --tx-out $(cat ../wallets/buyer/buyer.addr)+1822135 \
    --out-file "../af/lock-script/txs/tx.raw" \
    --fee 177865

cardano-cli transaction sign \
--signing-key-file "../wallets/buyer/buyer.skey" \
--tx-body-file  "../af/lock-script/txs/tx.raw" \
--out-file "../af/lock-script/txs/tx.signed"  \
--$TS 

cardano-cli transaction submit --tx-file "../af/lock-script/txs/tx.signed" --$TS 
