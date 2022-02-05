module Main where

import Prelude

import Control.Monad.Except.Trans (ExceptT, runExceptT, throwError)
import Control.Monad.State.Trans (StateT, get, put, runStateT)
import Control.Monad.Writer.Trans (WriterT, class MonadTell, runWriterT, tell)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Console as Console

type AppStack e w s a = ExceptT e (WriterT w (StateT s Effect)) a
type App = AppStack String (Array String) Int Unit
type StackResult = Tuple (Tuple (Either String Unit) (Array String)) Int
type AppResult = Tuple (Maybe String) AppEffects

type AppEffects =
  { log :: (Array String)
  , state :: Int
  }

results :: StackResult -> AppResult
results (Tuple (Tuple (Left err) l) s) = Tuple (Just err) { log: l, state: s }
results (Tuple (Tuple (Right _) l) s) = Tuple Nothing { log: l, state: s }

log :: ∀ m. MonadTell (Array String) m => String -> m Unit
log s = tell $ [s <> "\n"]

runApp :: Int -> App -> Effect AppResult
runApp s = map results <<< flip runStateT s <<< runWriterT <<< runExceptT

app :: App
app = do
  log "Starting App ..."
  n <- get
  when (n == 0) $ void $ throwError "WE CANNOT HAVE A 0 STATE!"
  put $ n + 1
  log "Incremented State"
  pure unit

main :: Effect Unit
main = do
  result1 <- runApp 0 app
  Console.log $ show result1
  result2 <- runApp 99 app
  Console.log $ show result2
