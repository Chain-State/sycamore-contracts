cardano-cli transaction build \
    --babbage-era \
    --testnet-magic 1097911063 \
    --change-address $(cat ~/projects/ar/sycamore-contracts/testnet/wallets/wallet1/w1.addr) \
    --tx-in 5a0ca3bd87f23ed319df33671634f559b46294455813d52efabad902bde97dc7#1 \
    --tx-out "$(cat ../basic-validator/basic-script.addr) 5000000 lovelace + 17 4d874093ef3a3449e33440a4bd8631077458ce125d1963bdfc402c86.42616e6461" \
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

