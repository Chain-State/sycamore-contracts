cardano-cli transaction build \
     --babbage-era \
    --tx-in d1f7940100e222720ffaddd3e51e9ae51a2bf47b60b1137cd7385ee82edff372#0 \
    --tx-in-datum-file "../af/unlock-script/unit.json" \
    --tx-in-redeemer-file "../af/unlock-script/unit.json" \
    --tx-in-script-file "../af/lock-script/gravity.plutus" \
    --tx-out $(cat ../wallets/buyer/buyer.addr)+"2000000 lovelace + 1 28c105de12784e5d26fa32c83184e7e89235fe85c7843ffeda2fda01.47524156495459233032"\
    --tx-out $(cat ../wallets/beneficiary/beneficiary.addr)+2000000 \
    --tx-out $(cat ../wallets/minter/minter.addr)+2000000 \
    --tx-in-collateral "c4a497329631e1a17b174667b4eb073eb665d5fa3149244a9b4a1ddc7a91869d#0" \
    --change-address $(cat ../wallets/scripts/gravity.addr) \
    --protocol-params-file "../af/unlock-script/protocol-params.json" \
    --out-file "../af/unlock-script/tx.body" \
    --$TS

cardano-cli transaction sign \
    --tx-body-file "../af/unlock-script/tx.body" \
    --signing-key-file "../wallets/buyer/buyer.skey" \
    --$TS \
    --out-file "../af/unlock-script/tx.signed"

cardano-cli transaction submit \
    --$TS \
   --tx-file "../af/unlock-script/tx.signed"

