cardano-cli transaction build-raw \
    --babbage-era \
    --tx-in 8a58469d58c11ed5c3de4d441078b2bf3f8d4cbfa3bc592a2b4ae5b91f2f4706#0  \
    --tx-out-datum-hash-file "../upp/lock-script/unit.json" \
    --tx-out $(cat ../upp/lock-script/uppv2_test$1.addr)+8000000+" 1 1385ae0d83039992e996988c0c3ee64e548a572c0eee209fb1be99d0.4152233231" \
    --tx-out  $(cat ../wallets/minter/minter.addr)+1822135 \
    --out-file "../upp/lock-script/txs/tx.raw" \
    --fee 177865

cardano-cli transaction sign \
--signing-key-file "../wallets/minter/minter.skey" \
--tx-body-file  "../upp/lock-script/txs/tx.raw" \
--out-file "../upp/lock-script/txs/tx.signed"  \
--$TS 

cardano-cli transaction submit --tx-file "../upp/lock-script/txs/tx.signed" --$TS 
