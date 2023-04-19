module Main (main) where
    import           Data.String        (IsString (..))
    import           Sycamore.Utils     (unsafeTokenNameToHex)
    import Sycamore.Asset.DeployAssetPurchase (writeAssetPurchaseValidator)
    import           System.Environment (getArgs)
    import Control.Exception (throwIO)

--convert pbkhs in args to list
    main :: IO ()
    main = do
        [assetName, publisherKey, beneficiariesKeys ] <- getArgs

        let file = "testnet/upp/lock-script/" ++ assetName ++ ".plutus"
        --convert space separated string to array of keys
        let beneficiaryKeysList = words beneficiariesKeys
        e <- writeAssetPurchaseValidator file assetName publisherKey beneficiaryKeysList
        case e of 
            Left err -> throwIO $ userError $ show err
            Right () -> return () 