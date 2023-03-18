{-# LANGUAGE OverloadedStrings #-}

module Emit where

import LLVM.Module
import LLVM.Context

import qualified LLVM.AST as AST
import qualified LLVM.AST.Constant as C
import qualified LLVM.AST.Float as F
import qualified LLVM.AST.FloatingPointPredicate as FP

import Data.Word
import Data.Int
import Control.Monad.Except
import Control.Applicative
import qualified Data.Map as Map

import Codegen
import qualified Syntax as S
import qualified StringUtils as StringUtils

import qualified Data.ByteString.Short as B (ShortByteString, unpack)

import Debug.Trace


toSig :: [B.ShortByteString] -> [(AST.Type, AST.Name)]
toSig = map (\x -> (double, AST.Name x))

-- def foo(x) x; 
codegenTop :: S.Expr -> LLVM ()
codegenTop (S.Function name args body) = do
  trace ("define double. name=" ++ show name ++ " args=" ++ show args ++ " bls=" ++ show bls ++ "\n\n") $ define double (StringUtils.stringToShortByteString name) fnargs bls
  where
    fnargs = toSig (map StringUtils.stringToShortByteString args)
    bls = createBlocks $ execCodegen $ do
      entry <- addBlock entryBlockName
      trace ("fnargs=" ++ show fnargs) $ setBlock entry
      -- FIXME: we probably need to use GetElementPtr here instad of alloca.
      -- defId from Example.hs has a working version of a function call.
      forM_ args $ \a -> do

        var <- getElementPtr (local (AST.Name $ StringUtils.stringToShortByteString a))
        -- loaded <- load var -- load is done automatically somehow, this is not necessary
        assign a var -- add "a" to the symtab, this not an llvm instruction

        -- var <- alloca double
        -- store var (local (AST.Name $ StringUtils.stringToShortByteString a))
        -- assign a var
      trace ("body=" ++ show body) $ cgen body >>= ret

codegenTop (S.Extern name args) = do
  external double (StringUtils.stringToShortByteString name) fnargs
  where fnargs = toSig $ map StringUtils.stringToShortByteString args

codegenTop exp = do
  define double "main" [] blks
  where
    blks = createBlocks $ execCodegen $ do
      entry <- addBlock entryBlockName
      setBlock entry
      cgen exp >>= ret

-------------------------------------------------------------------------------
-- Operations
-------------------------------------------------------------------------------

lt :: AST.Operand -> AST.Operand -> Codegen AST.Operand
lt a b = do
  test <- fcmp FP.ULT a b
  uitofp double test

binops = Map.fromList [
      ("+", fadd)
    , ("-", fsub)
    , ("*", fmul)
    , ("/", fdiv)
    , ("<", lt)
  ]

cgen :: S.Expr -> Codegen AST.Operand
cgen (S.UnaryOp op a) = do
  cgen $ S.Call ("unary" ++ op) [a]
cgen (S.BinOp "=" (S.Var var) val) = do
  a <- getvar var
  cval <- cgen val
  store a cval
  return cval
cgen (S.BinOp op a b) = do
  case Map.lookup op binops of
    Just f  -> do
      ca <- cgen a
      cb <- cgen b
      f ca cb
    Nothing -> error "No such operator"
cgen (S.Var x) = getvar x >>= load
cgen (S.Float n) = return $ cons $ C.Float (F.Double n)
cgen (S.Call fn args) = do
  largs <- mapM cgen args
  -- call (externf (AST.Name $ StringUtils.stringToShortByteString fn)) largs
  call2 (AST.Name $ StringUtils.stringToShortByteString fn) largs

-------------------------------------------------------------------------------
-- Compilation
-------------------------------------------------------------------------------

liftError :: ExceptT String IO a -> IO a
liftError = runExceptT >=> either fail return

codegen :: AST.Module -> [S.Expr] -> IO AST.Module
codegen mod fns = withContext $ \context ->
  -- liftError $ withModuleFromAST context newast $ \m -> do
  withModuleFromAST context newast $ \m -> do
    llstr <- moduleLLVMAssembly m
    putStrLn $ StringUtils.byteStringToString llstr
    return newast
  where
    modn    = trace ("modn. fns= " ++ show fns) (mapM codegenTop fns)
    newast  = runLLVM mod modn