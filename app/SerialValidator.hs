module Main (main) where
    import           Data.String        (IsString (..))
    import           Sycamore.Utils     (unsafeTokenNameToHex)
    import Sycamore.Asset.DeployAssetPurchase (writeAssetPurchaseValidator)
    import           System.Environment (getArgs)
    import Control.Exception (throwIO)

--convert pbkhs in args to list
    main :: IO ()
    main = do
        [assetName, ppkh, bpbkh1, bpbkh2, bpbkh3 ] <- getArgs

        let file = "testnet/upp/lock-script/" ++ assetName ++ ".plutus"
        let beneficiaries = [bpbkh1, bpbkh2, bpbkh3]
        e <- writeAssetPurchaseValidator file assetName ppkh beneficiaries
        case e of 
            Left err -> throwIO $ userError $ show err
            Right () -> return () 