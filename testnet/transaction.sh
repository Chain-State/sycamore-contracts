cardano-cli transaction build \
    --babbage-era \
    --testnet-magic 1097911063 \
    --change-address $(cat ~/Projects/de_afyarekod/sycamore-plutus/dev-wallets/wallet1/w1.addr) \
    --tx-in 971c67188141915d8029a4b8fe2a36258d5c6f9a6ab631f885dcad46d2fc0821#0 \
    --tx-out "$(cat basic-script.addr) 20000000 lovelace" \
    --tx-out-datum-hash-file unit.json \
    --out-file tx.body

cardano-cli transaction sign \
    --tx-body-file tx.body \
    --signing-key-file ~/Projects/de_afyarekod/sycamore-plutus/dev-wallets/wallet1/w1.skey \
    --testnet-magic 1097911063 \
    --out-file tx.signed

cardano-cli transaction submit \
    --testnet-magic 1097911063 \
    --tx-file tx.signed

