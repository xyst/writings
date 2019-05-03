sum :: Int -> Int -> Integer -> Integer
sum i j s
  | i > j = s
  | otherwise = Main.sum (i + 1) j (fromIntegral i + s)
begin = 444333222111
main = print (Main.sum begin (begin + 1234567890) 0)
