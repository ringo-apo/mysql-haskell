{-# LANGUAGE OverloadedStrings #-}

module Main where

import Lib
import Control.Exception
import Database.MySQL.Base
import qualified System.IO.Streams as Streams

transactional :: MySQLConn -> IO a -> IO a
transactional conn procedure = mask $ \restore -> do
  execute_ conn "BEGIN"
  a <- restore procedure `onException` (execute_ conn "ROLLBACK")
  execute_ conn "COMMIT"
  pure a

main :: IO ()
main = do
     someFunc
     conn <- connect
        defaultConnectInfo {ciUser = "root", ciPassword = "password", ciDatabase = "test"}
     stmt <- prepareStmt conn "INSERT INTO memos (name, comment, time) VALUES (?, ?, ?)"
     transactional conn $ do
       executeStmt conn stmt [MySQLText "chris", MySQLText "comment", MySQLDateTime '2020/06/05 09:00:00']
