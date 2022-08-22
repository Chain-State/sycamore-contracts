# cardano-cli transaction build-raw \
#     --babbage-era \
#     --tx-in da69b516fa64ea886b73aad3cd3ec7ba9c383756d6379460963dbb941a767408#1 \
#     --tx-out "addr_test1qq99x387hys4qv6tufly4gwe6xyj5trtevxn3wtx4zzy9vx34mmfjq3d0y33yy3lvehy3fgcvy8ae9xgjva0vu8a0casg8m0rl 3000000 lovelace + 2  c5fab58a1049a87f86cc882501bcd6be623587b31bc274d1122e2430.54656e647269 " \
#      --tx-out "addr_test1vpzsedk77nyntqmcf7fz6v6ksam0ahja8nkzepmnzdfn7ls75znzk 1820463 lovelace + 3  c5fab58a1049a87f86cc882501bcd6be623587b31bc274d1122e2430.54656e647269 " \
#     --fee 179537 \
#     --out-file transfer_asset.raw

# cardano-cli transaction calculate-min-fee \
# --tx-body-file transfer_asset.raw \
# --tx-in-count 1 \
# --tx-out-count 2 \
# --witness-count 1 \
# --testnet-magic 1097911063 \
# --protocol-params-file "../nft-mint/protocol-parameters.json"

# cardano-cli transaction sign \
# --signing-key-file "../wallets/wallet2/w2.skey" \
# --testnet-magic 1097911063 \
# --tx-body-file transfer_asset.raw \
# --out-file transfer_asset.signed



cardano-cli transaction submit \
    --testnet-magic 1097911063 \
   --tx-file transfer_asset.signed
