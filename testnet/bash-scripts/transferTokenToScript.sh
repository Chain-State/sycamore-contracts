#lock NFT minted on address1 to script1
cardano-cli transaction build-raw \
    --babbage-era \
    --tx-in 6ed67a796063eb7587b74516a861cb111ad8715d36e4a74e018e1d08f74fee5b#1  \
    --tx-out-datum-hash-file "../afia-validation/datum.json" \
    --tx-out addr_test1wqk4mq6a52y92ys9ckyypx96lr37ddyypd3gwcf8l40t0zqvjxzwv+100000000+"1 bcf896fe5c1dbb10dcce8d2ec557492d407450c44e8bdbcdb9db7812.41666961233031" \
    --tx-out addr_test1vpafv4w9nxdx0fcun65aw3f66p8p0rmukd5tjwkkthtvcfcm853zl+1821651 \
    --out-file "../afia-valiadtion/scriptLock.raw" \
    --fee 0\

# cardano-cli transaction sign \
# --signing-key-file "../preview-wallets/wallet1/payment.skey" \
# --tx-body-file  "../tx-files/fc2_toscript.raw" \
# --out-file "../tx-files/fc2_toscript.signed"  \
# --$TS 

# cardano-cli transaction submit --tx-file "../tx-files/fc2_toscript.signed" --$TS 


# cardano-cli transaction calculate-mi0# # # # # # \
# --tx-body-file  "../tx-files/fc2_toscript.raw" \
# --tx-in-count 1 \
# --tx-out-count 2 \
# --witness-count 1 \
# --$TS \
# --protocol-params-file "../basic-validator/protocol-params.json"

