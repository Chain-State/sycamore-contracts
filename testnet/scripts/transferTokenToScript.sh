cardano-cli transaction build-raw \
    --babbage-era \
    --tx-in 8dc0a944cfd73091e97d9b173c7b498c31fa62e1d9c0a3a6761c86438f3a2b59#0  \
    --tx-out-datum-hash-file "../af/mint/unit.json" \
    --tx-out $(cat ../wallets/scripts/dynbaya.addr)+50000000+" 1 2240d8bde3a426f8b714d277fc614df2545bc9e026d9863cf03d69c9.44594e415354592d42415941" \
    --tx-out  $(cat ../wallets/minter/minter.addr)+49822135 \
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

