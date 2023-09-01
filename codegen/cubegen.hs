-- Why spend 5 minutes looking things up when you could spend many times longer automating it?
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE LambdaCase #-}

module CubeGen where

import Data.Bits (Bits (..))
import Data.Foldable (Foldable (toList))

data Vec3 a = V3 !a !a !a
  deriving (Functor, Foldable, Show)

genCubeVert :: Int -> Vec3 Float
genCubeVert n =
  fromIntegral . (\x -> x * 2 - 1)
    <$> V3 (n .&. 1) (shiftR n 1 .&. 1) (shiftR n 2 .&. 1)

allCubeVerts :: [Vec3 Float]
allCubeVerts = genCubeVert <$> [0 .. 7]

data Dim = X | Y | Z

set :: Dim -> a -> Vec3 a -> Vec3 a
set X x (V3 _ y z) = V3 x y z
set Y y (V3 x _ z) = V3 x y z
set Z z (V3 x y _) = V3 x y z

get :: Dim -> Vec3 a -> a
get X (V3 x _ _) = x
get Y (V3 _ y _) = y
get Z (V3 _ _ z) = z

data Sign = Pos | Neg

signToNum :: Num a => Sign -> a
signToNum = \case
  Pos -> 1
  Neg -> -1

data Face = Face Dim Sign

allFaces :: [Face]
allFaces = [Face dim dir | dim <- [X, Y, Z], dir <- [Pos, Neg]]

getNormal :: Face -> Vec3 Float
getNormal (Face dim dir) = set dim (signToNum dir) (V3 0 0 0)

normals :: [Float]
normals = do
  face <- allFaces
  V3 x y z <- (replicate 4 . getNormal) face
  [x, y, z, 1]

getPositions :: Face -> [Vec3 Float]
getPositions (Face dim dir) = filter (\vert -> get dim vert == signToNum dir) allCubeVerts

positions :: [Float]
positions = do
  face <- allFaces
  V3 x y z <- getPositions face
  [x, y, z, 0]

squareIndices :: [Int]
squareIndices = [0, 1, 2, 1, 2, 3]

indices :: [Int]
indices = do
  faceNum <- [0 .. 5]
  squareIndex <- squareIndices
  return $ faceNum * 4 + squareIndex