#lock NFT minted on address1 to script1
cardano-cli transaction build-raw \
    --babbage-era \
    --tx-in 8de05286b43b0c6f6b1dc1679406ea52b613442a5a266502fe333bcac091295d#1  \
    --tx-out-datum-hash-file "../basic-validator/unit.json" \
    --tx-out addr_test1wqk4mq6a52y92ys9ckyypx96lr37ddyypd3gwcf8l40t0zqvjxzwv+250000000+"1 81500d3fc951663734629e185cb8d92d98dc40c6108d67310a516882.466162657243617374656c6c233032" \
    --tx-out addr_test1vpafv4w9nxdx0fcun65aw3f66p8p0rmukd5tjwkkthtvcfcm853zl+249828735 \
    --out-file "../basic-validator/fc2_toscript.raw" \
    --fee 178349 \

cardano-cli transaction sign \
--signing-key-file "../preview-wallets/wallet2/payment.skey" \
--tx-body-file  "../basic-validator/fc2_toscript.raw" \
--out-file "../basic-validator/fc2_toscript.signed"  \
--$TS 

cardano-cli transaction submit --tx-file "../basic-validator/fc2_toscript.signed" --$TS 


# cardano-cli transaction calculate-min-fee \
# --tx-body-file  "../basic-validator/fc2_toscript.raw" \
# --tx-in-count 1 \
# --tx-out-count 2 \
# --witness-count 1 \
# --$TS \
# --protocol-params-file "../basic-validator/protocol-params.json"

