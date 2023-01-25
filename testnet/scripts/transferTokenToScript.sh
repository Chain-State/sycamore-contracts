cardano-cli transaction build-raw \
    --babbage-era \
    --tx-in 9947a03001f4d8b403156dc9b67796cc82a9d7d56f025ca6ff042764412337ab#0  \
    --tx-out-datum-hash-file "../af/lock-script/unit.json" \
    --tx-out $(cat ../wallets/scripts/test05.addr)+8000000+" 1 40cf0beda55e58f0fa7d19886074415902e0c4ff4538f2e95256114b.54455354233035" \
    --tx-out  $(cat ../wallets/minter/minter.addr)+1822135 \
    --out-file "../af/lock-script/txs/tx.raw" \
    --fee 177865

cardano-cli transaction sign \
--signing-key-file "../wallets/minter/minter.skey" \
--tx-body-file  "../af/lock-script/txs/tx.raw" \
--out-file "../af/lock-script/txs/tx.signed"  \
--$TS 

cardano-cli transaction submit --tx-file "../af/lock-script/txs/tx.signed" --$TS 
