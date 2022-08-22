cardano-cli transaction build \
    --babbage-era \
    --testnet-magic 1097911063 \
    --change-address $(cat ~/projects/ar/sycamore-contracts/testnet/wallets/wallet1/w1.addr) \
    --tx-in df5608a75d7098cb5b3f17d33f46ca5ce86ef00ab09744392c8ad20e947f8752#1  \
    --tx-out "$(cat ../basic-validator/basic-script.addr) 99000000 lovelace + 5 fee9e325142b86a58f9a9f1c2cab989305b74bc860774f03482d137b.41526d6473" \
    --tx-out-datum-hash-file ../basic-validator/unit.json \
    --out-file tx.body

cardano-cli transaction sign \
    --tx-body-file tx.body \
    --signing-key-file  ~/projects/ar/sycamore-contracts/testnet/wallets/wallet1/w1.skey \
    --testnet-magic 1097911063 \
    --out-file tx.signed

cardano-cli transaction submit \
    --testnet-magic 1097911063 \
    --tx-file tx.signed

