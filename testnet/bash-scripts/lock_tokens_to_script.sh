cardano-cli transaction build \
    --babbage-era \
    --testnet-magic 1097911063 \
    --change-address $(cat ~/projects/ar/sycamore-contracts/testnet/wallets/wallet2/w2.addr) \
    --tx-in 0b32bb11f9a5287db7424eaa5d3702a21bbf3714c23d2aef6ea8abda0e968f2b#0  \
    --tx-out "$(cat ../basic-validator/basic-script.addr) 2000000 lovelace + 10 4d874093ef3a3449e33440a4bd8631077458ce125d1963bdfc402c86.42616e6461" \
    --tx-out-datum-hash-file ../basic-validator/unit.json \
    --out-file tx.body

cardano-cli transaction sign \
    --tx-body-file tx.body \
    --signing-key-file  ~/projects/ar/sycamore-contracts/testnet/wallets/wallet2/w2.skey \
    --testnet-magic 1097911063 \
    --out-file tx.signed

cardano-cli transaction submit \
    --testnet-magic 1097911063 \
    --tx-file tx.signed

