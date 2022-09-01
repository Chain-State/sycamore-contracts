#lock NFT minted on address1 to script1
cardano-cli transaction build-raw \
    --babbage-era \
    --tx-in 9d2832e26f5b8e9baa4eaba7d959c009e5e3ed82b79c2675566fda70395bf517#1  \
    --tx-out-datum-hash-file "../basic-validator/lockTokenScriptHash.json" \
    --tx-out addr_test1wqk4mq6a52y92ys9ckyypx96lr37ddyypd3gwcf8l40t0zqvjxzwv+2000000000+"1 588f43942516a04a48b02304bcaa38f1a072fd1dc2cd9af8a2afe71f.466162657243617374656c6c233033" \
    --tx-out addr_test1vpafv4w9nxdx0fcun65aw3f66p8p0rmukd5tjwkkthtvcfcm853zl+1999821651 \
    --out-file "../basic-validator/fc2_toscript.raw" \
    --fee 178349 \

cardano-cli transaction sign \
--signing-key-file "../preview-wallets/wallet1/payment.skey" \
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

