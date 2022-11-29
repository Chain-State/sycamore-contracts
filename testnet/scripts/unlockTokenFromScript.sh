cardano-cli transaction build \
     --babbage-era \
    --tx-in 35b7c6b7ca0cef72895f7cc514106e3a3fd4ebb7de17d05e2deb88badac2c71b#0 \
    --tx-in-datum-file "../af/unlock-script/unit.json" \
    --tx-in-redeemer-file "../af/unlock-script/unit.json" \
    --tx-in-script-file "../af/lock-script/test06.plutus" \
    --tx-out $(cat ../wallets/buyer/buyer.addr)+"4000000 lovelace + 1 a1e1afeb55ce2fc39b66e3ff87594333393a634ed2d15660d9fdfd81.54455354233032" \
    --tx-out $(cat ../wallets/beneficiary/beneficiary.addr)+2000000 \
    --tx-out $(cat ../wallets/minter/minter.addr)+2000000 \
    --tx-in-collateral "c4a497329631e1a17b174667b4eb073eb665d5fa3149244a9b4a1ddc7a91869d#0" \
    --change-address $(cat ../wallets/buyer/buyer.addr) \
    --protocol-params-file "../af/unlock-script/protocol-params.json" \
    --out-file "../af/unlock-script/txs/tx.body" \
    --$TS

cardano-cli transaction sign \
    --tx-body-file "../af/unlock-script/txs/tx.body" \
    --signing-key-file "../wallets/buyer/buyer.skey" \
    --$TS \
    --out-file "../af/unlock-script/txs/tx.signed"

cardano-cli transaction submit \
    --$TS \
   --tx-file "../af/unlock-script/txs/tx.signed"

