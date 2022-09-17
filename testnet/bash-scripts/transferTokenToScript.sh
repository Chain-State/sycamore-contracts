#lock NFT minted on address1 to script1
cardano-cli transaction build-raw \
    --babbage-era \
    --tx-in da35e53daba28004e788c470a3cecd920a591bcffd2fc3f3078a31334b96329a#1  \
    --tx-out-datum-hash-file "../basic-validator/lockTokenScriptHash.json" \
    --tx-out addr_test1wqk4mq6a52y92ys9ckyypx96lr37ddyypd3gwcf8l40t0zqvjxzwv+1495000000+"1 b05aa099ddad8fba28e520d00a7072d352119f5c194a8db484f41e75.466162657243617374656c6c233035" \
    --tx-out addr_test1vpafv4w9nxdx0fcun65aw3f66p8p0rmukd5tjwkkthtvcfcm853zl+1821651 \
    --out-file "../tx-files/fc2_toscript.raw" \
    --fee 178349 \

cardano-cli transaction sign \
--signing-key-file "../preview-wallets/wallet1/payment.skey" \
--tx-body-file  "../tx-files/fc2_toscript.raw" \
--out-file "../tx-files/fc2_toscript.signed"  \
--$TS 

cardano-cli transaction submit --tx-file "../tx-files/fc2_toscript.signed" --$TS 


# cardano-cli transaction calculate-mi0# # # # # # \
# --tx-body-file  "../tx-files/fc2_toscript.raw" \
# --tx-in-count 1 \
# --tx-out-count 2 \
# --witness-count 1 \
# --$TS \
# --protocol-params-file "../basic-validator/protocol-params.json"

