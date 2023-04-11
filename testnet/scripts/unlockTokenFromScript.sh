cardano-cli transaction build \
     --babbage-era \
    --tx-in e2a472f03a6b59cb43decb00733c3d5ef45537968cfca4c71da90771f7009cf8#0 \
    --tx-in-datum-file "../upp/unlock-script/unit.json" \
    --tx-in-redeemer-file "../upp/unlock-script/unit.json" \
    --tx-in-script-file "../upp/lock-script/uppv2_test05.plutus" \
    --tx-out $(cat ../wallets/buyer/buyer.addr)+"1500000 lovelace + 1 93f0126201070494884c86bb0aca2b5d2823107e55b69dc85344d28b.4152233232" \
    --tx-out $(cat ../wallets/beneficiary/beneficiary.addr)+2000000 \
    --tx-out $(cat ../wallets/minter/minter.addr)+2000000 \
    --tx-in-collateral "285ad96cb21bb169fde23c97ba75de040bb2832f3d560e704a3c7edeb0f4bf4e#3" \
    --change-address $(cat ../wallets/buyer/buyer.addr) \
    --protocol-params-file "../upp/unlock-script/protocol-params.json" \
    --out-file "../upp/unlock-script/txs/tx.body" \
    --$TS

cardano-cli transaction sign \
    --tx-body-file "../upp/unlock-script/txs/tx.body" \
    --signing-key-file "../wallets/buyer/buyer.skey" \
    --$TS \
    --out-file "../upp/unlock-script/txs/tx.signed"

cardano-cli transaction submit \
    --$TS \
   --tx-file "../upp/unlock-script/txs/tx.signed"

