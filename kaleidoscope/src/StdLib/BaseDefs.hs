{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -Wno-incomplete-record-updates #-}

module StdLib.BaseDefs where

import Data.String (fromString)
import LLVM.AST
  ( Definition (..),
    FloatingPointType (..),
    Name (..),
    Named (Do, (:=)),
    Operand (..),
    Parameter (..),
    Terminator (Ret),
    Type (..),
    mkName,
    operand0,
    returnOperand,
  )
import LLVM.AST.Attribute (FunctionAttribute (OptimizeNone))
import LLVM.AST.Global (BasicBlock (..), Global (..), functionDefaults)
import qualified LLVM.AST.Instruction as I (Instruction (FPToSI, SIToFP, metadata, type'), Terminator (metadata'))
import LLVM.AST.Linkage (Linkage (External))
import LLVM.AST.Type (i32, i8, ptr)

baseDefinitions :: [Definition]
baseDefinitions =
  [ GlobalDefinition
      functionDefaults
        { name = mkName "printf",
          linkage = External,
          parameters = ([Parameter ty (mkName "fmtStr") [] | ty <- [ptr i8]], True),
          returnType = i32,
          functionAttributes = [Right OptimizeNone]
        },
    -- math functions
    GlobalDefinition
      functionDefaults
        { name = Name (fromString "sin"),
          parameters = ([Parameter (FloatingPointType DoubleFP) (Name (fromString "x")) []], False),
          returnType = FloatingPointType DoubleFP,
          basicBlocks = []
        },
    GlobalDefinition
      functionDefaults
        { name = Name (fromString "cos"),
          parameters = ([Parameter (FloatingPointType DoubleFP) (Name (fromString "x")) []], False),
          returnType = FloatingPointType DoubleFP,
          basicBlocks = []
        },
    GlobalDefinition
      functionDefaults
        { name = Name (fromString "tan"),
          parameters = ([Parameter (FloatingPointType DoubleFP) (Name (fromString "x")) []], False),
          returnType = FloatingPointType DoubleFP,
          basicBlocks = []
        },
    GlobalDefinition
      functionDefaults
        { name = Name (fromString "log"),
          parameters = ([Parameter (FloatingPointType DoubleFP) (Name (fromString "x")) []], False),
          returnType = FloatingPointType DoubleFP,
          basicBlocks = []
        },
    GlobalDefinition
      functionDefaults
        { name = Name (fromString "fabs"),
          parameters = ([Parameter (FloatingPointType DoubleFP) (Name (fromString "x")) []], False),
          returnType = FloatingPointType DoubleFP,
          basicBlocks = []
        },
    GlobalDefinition
      functionDefaults
        { name = Name (fromString "rand"),
          parameters = ([], False),
          returnType = IntegerType 32,
          basicBlocks = []
        },
    GlobalDefinition
      functionDefaults
        { name = Name (fromString "srand"),
          parameters = ([Parameter (IntegerType 32) (Name (fromString "seed")) []], False),
          returnType = IntegerType 32,
          basicBlocks = []
        },
    -- misc functions
    GlobalDefinition
      functionDefaults
        { name = Name (fromString "exit"),
          parameters = ([Parameter (IntegerType 32) (Name (fromString "status")) []], False),
          returnType = IntegerType 32,
          basicBlocks = []
        },

    -- type casting functions
    GlobalDefinition
      functionDefaults
        { name = Name (fromString "int_to_double"),
          parameters = ([Parameter (IntegerType {typeBits = 32}) (Name "x_0") []], False),
          returnType = FloatingPointType DoubleFP,
          basicBlocks =
            [ BasicBlock
                (UnName 0)
                [ UnName 1
                    := I.SIToFP
                      { operand0 = LocalReference (IntegerType {typeBits = 32}) (Name "x_0"),
                        I.type' = FloatingPointType {floatingPointType = DoubleFP},
                        I.metadata = []
                      }
                ]
                (Do (Ret {returnOperand = Just (LocalReference (FloatingPointType {floatingPointType = DoubleFP}) (UnName 1)), I.metadata' = []}))
            ]
        },
    GlobalDefinition
      functionDefaults
        { name = Name (fromString "double_to_int"),
          parameters = ([Parameter (FloatingPointType {floatingPointType = DoubleFP}) (Name "x_0") []], False),
          returnType = IntegerType {typeBits = 32},
          basicBlocks =
            [ BasicBlock
                (UnName 0)
                [ UnName 1
                    := I.FPToSI
                      { operand0 = LocalReference (FloatingPointType {floatingPointType = DoubleFP}) (Name "x_0"),
                        I.type' = IntegerType {typeBits = 32},
                        I.metadata = []
                      }
                ]
                (Do (Ret {returnOperand = Just (LocalReference (IntegerType {typeBits = 32}) (UnName 1)), I.metadata' = []}))
            ]
        }
  ]
