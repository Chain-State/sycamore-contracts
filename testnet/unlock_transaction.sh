cardano-cli transaction build \
    --babbage-era \
    --testnet-magic 1097911063 \
    --tx-in cf5d67209bdddfca82bd99d417ff980aab489e9c073f7ed247271c0267880f0c#1 \
    --tx-in-script-file "basic.plutus" \
    --tx-in-datum-file "unit.json" \
    --tx-in-redeemer-file redeemer.json \
    --tx-in-collateral 50acc5814d428158f321cd259aa4c9b5b72c31d1dfdfb638ca5669af9db5d23d#0 \
    --change-address $(cat ~/Projects/de_afyarekod/sycamore-plutus/dev-wallets/wallet2/w2.addr) \
    --protocol-params-file "protocol-params.json" \
    --out-file unlock_script.tx

cardano-cli transaction sign \
    --tx-body-file unlock_script.tx \
    --signing-key-file ~/Projects/de_afyarekod/sycamore-plutus/dev-wallets/wallet2/w2.skey \
    --testnet-magic 1097911063 \
    --out-file unlock_script_tx.signed

cardano-cli transaction submit \
    --testnet-magic 1097911063 \
   --tx-file unlock_script_tx.signed

