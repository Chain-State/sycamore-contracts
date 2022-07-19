## Sycamore-Contracts

A collection of Plutus smart contracts providing implementation for blockchain focussed requirements on the AfyaRekod platform.

**SetUp**
---
1. Setup [`Nix`](https://nixos.org/download.html) on your machine. 
2. Clone this repository to your local environment.
3. Clone the `plutus-apps` repository [here](https://github.com/input-output-hk/plutus-apps.git)
4. In the `plutus-apps` repository, checkout the tag: 41149926c108c71831cfe8d244c83b0ee4bf5c8a
5. From the `plutus-apps` directory, run `nix-shell`. From within the nix-shell navigate back to the `sycamore-contracts` repository and do `cabal-build`.
