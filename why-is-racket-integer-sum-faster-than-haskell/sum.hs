sum :: Int -> Integer -> Integer
sum i s
  | i == 0 = s
  | otherwise = Main.sum (i - 1) (fromIntegral i + s)
main = print (Main.sum 1234567890 0)
