# # #address2 unlocks FaberCastell#02 NFT from script1
cardano-cli transaction build-raw \
     --babbage-era \
    --tx-in 75b68c0130d5c9c44d6ef29d1b0ffca83d0aa663bbdd76793821ad4a8e7c507b#0 \
    --tx-in-datum-file "../afia-validation/unit.json" \
    --tx-in-redeemer-file "../afia-validation/unit.json" \
    --tx-in-script-file "../afia-validation/asset-purchase.plutus" \
    --tx-out $(cat ../preview-wallets/wallet1/payment.addr)+94866822+" 1 bcf896fe5c1dbb10dcce8d2ec557492d407450c44e8bdbcdb9db7812.41666961233031" \
    --tx-out $(cat ../afia-validation/ap-script.addr)+2000000 \
    --tx-in-collateral "4d12f0c9885270807a709840a0efff77dd1c282d1e9a1fb2f1409466b9fcca5f#0" \
    --tx-in-execution-units="(1000000000, 10000000)" \
    --protocol-params-file "../afia-validation/protocol-parameters.json" \
    --fee 955181 \
    --out-file "tx.body"

cardano-cli transaction sign \
    --tx-body-file "tx.body" \
    --signing-key-file "../preview-wallets/wallet1/payment.skey" \
    --$TS \
    --out-file "tx.signed"

cardano-cli transaction submit \
    --$TS \
   --tx-file "tx.signed"


#    cardano-cli transaction calculate-min-fee \
#     --tx-body-file  "tx.body" \
#     --tx-in-count 5 \
#     --tx-out-count 2 \
#     --witness-count 1 \
#     --$TS \
#     --protocol-params-file "../afia-validation/protocol-parameters.json"



