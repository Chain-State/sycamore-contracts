#Use the build-raw tx builder in unlockTokenFromScript2.sh
#address2 unlocks FaberCastell#02 NFT from script1
cardano-cli transaction build \
    --babbage-era \
    --tx-in f1f68c50505e0f7c0142dab674f24fad235c2e4b1938ad3ad0675cc83d50f7e2#0 \
    --tx-in-datum-file "../basic-validator/lockTokenScriptHash.json" \
    --tx-in-redeemer-file "../basic-validator/redeemer.json" \
    --tx-in-script-file "../basic-validator/basic.plutus" \
    --change-address  addr_test1wqk4mq6a52y92ys9ckyypx96lr37ddyypd3gwcf8l40t0zqvjxzwv \
    --tx-out addr_test1vpafv4w9nxdx0fcun65aw3f66p8p0rmukd5tjwkkthtvcfcm853zl+40000000+"1 81500d3fc951663734629e185cb8d92d98dc40c6108d67310a516882.466162657243617374656c6c233032" \
    --tx-out addr_test1wqk4mq6a52y92ys9ckyypx96lr37ddyypd3gwcf8l40t0zqvjxzwv+200000000+"0 81500d3fc951663734629e185cb8d92d98dc40c6108d67310a516882.466162657243617374656c6c233032"  \
    --tx-in-collateral "8de05286b43b0c6f6b1dc1679406ea52b613442a5a266502fe333bcac091295d#0" \
    --protocol-params-file "../basic-validator/protocol-params.json" \
    --$TS \
    --out-file "../basic-validator/fbc_unlock.body"

cardano-cli transaction sign \
    --tx-body-file "../basic-validator/fbc_unlock.body" \
    --signing-key-file "../preview-wallets/wallet2/payment.skey" \
    --$TS \
    --out-file "../basic_validator/fbc_unlock.signed"

cardano-cli transaction submit \
    --$TS \
   --tx-file "../basic_validator/fbc_unlock.signed"


   #DO NOT USE THIS FOR TESTING..USE THE BUILD RAW TX BUILDER

