#wallet #2 unlocks 10 Banda tokens (+3.22Ada) from basic-validator script.
#change Ada and tokens are sent back to the script address 
cardano-cli transaction build \
    --babbage-era \
    --tx-in e6658353ba0e2e9b0e89c715d8b3d5b87057b4073df490c80be094723b2f0bdc#1 \
    --tx-in-script-file "../basic-validator/basic.plutus" \
    --tx-in-datum-file "../basic-validator/unit.json" \
    --tx-in-redeemer-file "../basic-validator/redeemer.json" \
    --tx-in-collateral "0afbb6ba68fa0bd76dd76dcb880e9096c90437f966abd8374872884e85a93136#0" \
    --tx-out "addr_test1vpzsedk77nyntqmcf7fz6v6ksam0ahja8nkzepmnzdfn7ls75znzk 3226505 lovelace + 10 4d874093ef3a3449e33440a4bd8631077458ce125d1963bdfc402c86.42616e6461" \
    --tx-out "addr_test1wrw3ry4yx406uwuya9sf9dyrls26gmkxnly3rlplwujd4hgx228c8 1436748 lovelace + 7 4d874093ef3a3449e33440a4bd8631077458ce125d1963bdfc402c86.42616e6461" \
    --change-address  addr_test1vpzsedk77nyntqmcf7fz6v6ksam0ahja8nkzepmnzdfn7ls75znzk \
    --protocol-params-file "../basic-validator/protocol-params.json" \
    --$TS \
    --out-file unlock_token.tx

cardano-cli transaction sign \
    --tx-body-file unlock_token.tx \
    --signing-key-file "../wallets/wallet2/w2.skey" \
    --$TS \
    --out-file unlock_token.signed

cardano-cli transaction submit \
    --$TS \
   --tx-file unlock_token.signed

