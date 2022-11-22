cardano-cli transaction build \
     --babbage-era \
    --tx-in d61e501309fac859758bb257aa80b775fddc6b1582f95369636b8334bc1853b2#0 \
    --tx-in-datum-file "../af/unlock-script/unit.json" \
    --tx-in-redeemer-file "../af/unlock-script/unit.json" \
    --tx-in-script-file "../af/lock-script/dynbaya-purchase.plutus" \
    --tx-out $(cat ../wallets/buyer/buyer.addr)+"2000000 lovelace + 1 2240d8bde3a426f8b714d277fc614df2545bc9e026d9863cf03d69c9.44594e415354592d42415941"\
    --tx-out $(cat ../wallets/contributor/contributor.addr)+2000000 \
    --tx-out $(cat ../wallets/minter/minter.addr)+2000000 \
    --tx-in-collateral "c4a497329631e1a17b174667b4eb073eb665d5fa3149244a9b4a1ddc7a91869d#0" \
    --change-address $(cat ../wallets/minter/minter.addr) \
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

