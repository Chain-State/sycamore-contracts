# cardano-cli transaction build-raw \
#     --babbage-era \
#     --tx-in 7a56369fa91f05bd2bec2e4c63e3221191adcb22ad5df598871eda2ef8697ddb#1 \
#     --tx-out addr_test1vpzsedk77nyntqmcf7fz6v6ksam0ahja8nkzepmnzdfn7ls75znzk+10000000+"5 4d874093ef3a3449e33440a4bd8631077458ce125d1963bdfc402c86.42616e6461" \
#     --tx-out addr_test1vzyxwvzueqwz7g9dh2c8wqprmzdpfrndjk2zhu4ew8zv8ss5crjzn+649821783+"17 4d874093ef3a3449e33440a4bd8631077458ce125d1963bdfc402c86.42616e6461" \
#     --fee 178217 \
#     --out-file unlock_nft.raw

# cardano-cli transaction sign \
# --signing-key-file "../wallets/wallet1/w1.skey" \
# --testnet-magic 1097911063 \
# --tx-body-file unlock_nft.raw \
# --out-file unlock_nft.signed

# cardano-cli transaction calculate-min-fee \
# --tx-body-file unlock_nft.raw \
# --tx-in-count 1 \
# --tx-out-count 2 \
# --witness-count 1 \
# --testnet-magic 1097911063 \
# --protocol-params-file "../nft-mint/protocol-parameters.json"

# cardano-cli transaction sign \
#     --tx-body-file unlock_script.tx \
#     --signing-key-file ~/Projects/de_afyarekod/sycamore-plutus/dev-wallets/wallet2/w2.skey \
#     --testnet-magic 1097911063 \
#     --out-file unlock_script_tx.signed

cardano-cli transaction submit \
    --testnet-magic 1097911063 \
   --tx-file unlock_nft.signed

