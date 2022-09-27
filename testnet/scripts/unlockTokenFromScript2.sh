# # #address2 unlocks FaberCastell#02 NFT from script1
cardano-cli transaction build-raw \
     --babbage-era \
    --tx-in 92ac59a0994b13db845ee45b4e877f4ebdfb66c2e71022f67af9cbe2d6c44c28#0 \
    --tx-in-datum-file "../af/mint/unit.json" \
    --tx-in-redeemer-file "../af/mint/unit.json" \
    --tx-in-script-file "../af/lock-script/af-purchase.plutus" \
    --tx-out $(cat ../wallets/wallet2/payment.addr)+"85044511 lovelace + 1 2276a24f522753b75e8cb19041313b12e56443cac8c96b7704391e10.41463031" \
    --tx-out $(cat ../wallets/beneficiary1/beneficiary.addr)+2000000 \
    --tx-out $(cat ../wallets/aggregator/aggregator.addr)+2000000 \
    --tx-in-collateral "6ed67a796063eb7587b74516a861cb111ad8715d36e4a74e018e1d08f74fee5b#0" \
    --tx-in-execution-units="(1000000000, 10000000)" \
    --protocol-params-file "../af/mint/protocol-params.json" \
    --fee 955489 \
    --out-file "../af/unlock-script/tx.body"

cardano-cli transaction sign \
    --tx-body-file "../af/unlock-script/tx.body" \
    --signing-key-file "../wallets/wallet2/payment.skey" \
    --$TS \
    --out-file "../af/unlock-script/tx.signed"

cardano-cli transaction submit \
    --$TS \
   --tx-file "../af/unlock-script/tx.signed"


#    cardano-cli transaction calculate-min-fee \
#     --tx-body-file  "../af/unlock-script/tx.body" \
#     --tx-in-count 1 \
#     --tx-out-count 3 \
#     --witness-count 1 \
#     --$TS \
#     --protocol-params-file "../af/mint/protocol-params.json"



