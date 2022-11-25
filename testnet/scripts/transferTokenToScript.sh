cardano-cli transaction build-raw \
    --babbage-era \
    --tx-in c7118dee931b8ac0665fab57f437ff520f095d7bb518444f564ea885d010ce86#0  \
    --tx-out-datum-hash-file "../af/mint/unit.json" \
    --tx-out $(cat ../wallets/scripts/gravity.addr)+30000000+" 1 28c105de12784e5d26fa32c83184e7e89235fe85c7843ffeda2fda01.47524156495459233032" \
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

