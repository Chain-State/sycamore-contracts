cardano-cli transaction build-raw \
    --babbage-era \
    --tx-in ddad204d62e67dfc8f915dbbf4880b2d96ada95bfe7bda9bec47e593ae739590#0  \
    --tx-out-datum-hash-file "../af/mint/unit.json" \
    --tx-out $(cat ../wallets/scripts/test02.addr)+30000000+" 1 a1e1afeb55ce2fc39b66e3ff87594333393a634ed2d15660d9fdfd81.54455354233032" \
    --tx-out  $(cat ../wallets/minter/minter.addr)+9822135 \
    --out-file "../af/lock-script/tx.raw" \
    --fee 177865

cardano-cli transaction sign \
--signing-key-file "../wallets/minter/minter.skey" \
--tx-body-file  "../af/lock-script/tx.raw" \
--out-file "../af/unlock-script/tx.signed"  \
--$TS 

cardano-cli transaction submit --tx-file "../af/unlock-script/tx.signed" --$TS 


# cardano-cli transaction calculate-min-fee \
# --tx-body-file  "../af/lock-script/tx.raw" \
# --tx-in-count 1 \
# --tx-out-count 2 \
# --witness-count 1 \
# --$TS \
# --protocol-params-file "../af/mint/protocol-params.json"

