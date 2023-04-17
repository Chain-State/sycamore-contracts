module Main (main) where
    import           Data.String        (IsString (..))
    import           Sycamore.Utils     (unsafeTokenNameToHex)
    import Sycamore.Asset.DeployAssetPurchase (writeAssetPurchaseValidator)
    import           System.Environment (getArgs)
    import Control.Exception (throwIO)

--convert pbkhs in args to list
    main :: IO ()
    main = do
        [assetName, publisherPkhs ] <- getArgs

        let file = "testnet/upp/lock-script/" ++ title ++ ".plutus"
        e <- writeAssetPurchaseValidator file title publisherPkhs
        case e of 
            Left err -> throwIO $ userError $ show err
            Right () -> return () 