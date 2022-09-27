cardano-cli transaction build-raw \
    --babbage-era \
    --tx-in 6ed67a796063eb7587b74516a861cb111ad8715d36e4a74e018e1d08f74fee5b#1  \
    --tx-out-datum-hash-file "../afia-validation/unit.json" \
    --tx-out $(cat ../afia-validation/ap-script.addr)+97822003+" 1 bcf896fe5c1dbb10dcce8d2ec557492d407450c44e8bdbcdb9db7812.41666961233031" \
    --tx-out  $(cat ../preview-wallets/wallet2/payment.addr)+2000000 \
    --out-file "lock.raw" \
    --fee 177997 

cardano-cli transaction sign \
--signing-key-file "../preview-wallets/wallet2/payment.skey" \
--tx-body-file  "lock.raw" \
--out-file "lock.signed"  \
--$TS 

cardano-cli transaction submit --tx-file "lock.signed" --$TS 


# cardano-cli transaction calculate-min-fee \
# --tx-body-file  "lock.raw" \
# --tx-in-count 1 \
# --tx-out-count 2 \
# --witness-count 1 \
# --$TS \
# --protocol-params-file "../nft-mint/protocol-parameters.json"

