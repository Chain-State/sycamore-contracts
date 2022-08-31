#address2 unlocks FaberCastell#01 NFT from script1
cardano-cli transaction build \
    --babbage-era \
    --tx-in 1a48fc943bfe2a75cb07158ab8a9bc0a6f23ff6f59c73ecfba63bb34574ed325#1 \
    --tx-in-datum-file "../basic-validator/unit.json" \
    --tx-in-redeemer-file "../basic-validator/redeemer.json" \
    --tx-in-script-file "../basic-validator/basic.plutus" \
    --tx-in-collateral "549080510208254fb59400a9d1abbb483e9bcea3e5e2a12862a82b774c490740#1" \
    --tx-out addr_test1vqxskgegtf0py3rxkjdux4st4dsk4mw6mtvnll9katfzsnqxrexsq+10+"1 9aa487c26c03221ad9a58f20d65f982fddffa59ab250f75551a1a590.466162657243617374656c6c233031" \
    --tx-out addr_test1wqk4mq6a52y92ys9ckyypx96lr37ddyypd3gwcf8l40t0zqvjxzwv+3290 \
    --change-address  addr_test1wqk4mq6a52y92ys9ckyypx96lr37ddyypd3gwcf8l40t0zqvjxzwv \
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

