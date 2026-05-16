-- fibonacci.hs: A Haskell implementation of the Fibonacci function.
import System.Environment (getArgs)
import System.Exit
import Data.Function ((&))

fib :: Integer -> Integer
fib 0 = 0
fib 1 = 1
fib n = fib (n-1) + fib (n-2)

main :: IO ()
main = do
    args <- getArgs
    if null args
        then do
            putStrLn "A fibonacci implementation written in Haskell.\n"
            putStrLn "Compute fibonacci(n) for any given n.\n"
            putStrLn "Usage: fibonacci <number>"
            exitSuccess
        else
            args & head & read & fib & putStr . show
