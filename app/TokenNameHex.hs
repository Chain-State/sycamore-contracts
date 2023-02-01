module Main
    ( main)
     where

import           Data.String        (IsString (..))
import           Sycamore.Utils     (unsafeTokenNameToHex)
import           System.Environment (getArgs)

main :: IO ()
main = do
    [tn'] <- getArgs
    let tn = fromString tn'
    putStrLn $ unsafeTokenNameToHex tn