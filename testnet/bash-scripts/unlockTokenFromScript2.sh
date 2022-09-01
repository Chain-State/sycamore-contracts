# # #address2 unlocks FaberCastell#02 NFT from script1
cardano-cli transaction build-raw \
    --babbage-era \
    --tx-in 4b881a120af2f59b192cc6d7066750d093bfa85b9112b77d6eef40f87166cace#0 \
    --tx-in-datum-file "../basic-validator/lockTokenScriptHash.json" \
    --tx-in-redeemer-file "../basic-validator/redeemer.json" \
    --tx-in-script-file "../basic-validator/basic.plutus" \
    --tx-in-collateral "8de05286b43b0c6f6b1dc1679406ea52b613442a5a266502fe333bcac091295d#0" \
    --tx-in-execution-units="(10000000000, 10000000)" \
    --tx-out addr_test1qp3zw5qr0tklsqmgu0ql8djan2pxzfdfact5fnsdr6ll5r6tnynargwx95puyctz5f2lnn2qzvyetudse522un5ctf0sa7et9m+30000000+"1 81500d3fc951663734629e185cb8d92d98dc40c6108d67310a516882.466162657243617374656c6c233032" \
    --tx-out addr_test1wqk4mq6a52y92ys9ckyypx96lr37ddyypd3gwcf8l40t0zqvjxzwv+8434859  \
    --protocol-params-file "../basic-validator/protocol-params.json" \
    --fee 1565141  \
    --out-file "../basic-validator/fbc_unlock.body"

cardano-cli transaction sign \
    --tx-body-file "../basic-validator/fbc_unlock.body" \
    --signing-key-file "../preview-wallets/wallet2/payment.skey" \
    --$TS \
    --out-file "../basic-validator/fbc_unlock.signed"

cardano-cli transaction submit \
    --$TS \
   --tx-file "../basic-validator/fbc_unlock.signed"


#    cardano-cli transaction calculate-min-fee \
#     --tx-body-file  "../basic-validator/fbc_unlock.body" \
#     --tx-in-count 5 \
#     --tx-out-count 2 \
#     --witness-count 1 \
#     --$TS \
#     --protocol-params-file "../basic-validator/protocol-params.json"



