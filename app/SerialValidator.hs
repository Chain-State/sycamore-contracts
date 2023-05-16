module Main (main) where
    import Sycamore.Asset.DeployAssetPurchase (writeAssetPurchaseValidator)
    import System.Environment (getArgs)
    import Control.Exception (throwIO)

    main :: IO ()
    main = do
        [assetName ] <- getArgs

        let file = "testnet/upp/lock-script/" ++ assetName ++ ".plutus"
        --convert space separated string to array of keys
        -- let beneficiaryKeysList = words beneficiariesKeys
        writeAssetPurchaseValidator file assetName