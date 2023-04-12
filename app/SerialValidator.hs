module Main (main) where
    import           Data.String        (IsString (..))
    import           Sycamore.Utils     (unsafeTokenNameToHex)
    import Sycamore.Asset.DeployAssetPurchase (writeAssetPurchaseValidator)
    import           System.Environment (getArgs)
    import Control.Exception (throwIO)

    main :: IO ()
    main = do
        [title] <- getArgs

        putStrLn title
        let file = "testnet/upp/lock-script/" ++ title ++ ".plutus"
        e <- writeAssetPurchaseValidator file title
        case e of 
            Left err -> throwIO $ userError $ show err
            Right () -> return () 