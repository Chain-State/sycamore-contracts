cardano-cli transaction build-raw \
    --babbage-era \
    --tx-in c652a17335d2841ebb1fe6c1897121a68017d6c9a3998918638b3fe5fa807fb8#1  \
    --tx-out-datum-hash-file "../af/mint/unit.json" \
    --tx-out $(cat ../wallets/scripts/af-purchase-script.addr)+90000000+" 1 2276a24f522753b75e8cb19041313b12e56443cac8c96b7704391e10.41463031" \
    --tx-out  $(cat ../wallets/wallet1/payment.addr)+9822135 \
    --out-file "../af/lock-script/tx.raw" \
    --fee 177865

cardano-cli transaction sign \
--signing-key-file "../wallets/wallet1/payment.skey" \
--tx-body-file  "../af/lock-script/tx.raw" \
--out-file "../af/lock-script/tx.signed"  \
--$TS 

cardano-cli transaction submit --tx-file "../af/lock-script/tx.signed" --$TS 


# cardano-cli transaction calculate-min-fee \
# --tx-body-file  "../af/lock-script/tx.raw" \
# --tx-in-count 1 \
# --tx-out-count 2 \
# --witness-count 1 \
# --$TS \
# --protocol-params-file "../af/mint/protocol-params.json"

