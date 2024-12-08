
import Data.List (sort)
import Data.Maybe (fromMaybe)

-- Function to calculate the total distance between two lists
totalDistance :: [Int] -> [Int] -> Int
totalDistance left right = sum $ zipWith distance sortedLeft sortedRight
  where
    sortedLeft = sort left
    sortedRight = sort right
    distance a b = abs (a - b)

-- Main function to read input and compute the total distance
main :: IO ()
main = do
    -- Read input from the user or a file
    input <- readFile "../input/day1"
    let pairs = map (map read . words) (lines input)
    let (left, right) = unzip pairs
    let totalDist = totalDistance left right
    print totalDist

