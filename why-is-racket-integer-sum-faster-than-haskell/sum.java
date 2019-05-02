import java.math.BigInteger;

class Sum {
  public static void main(String[] args) {
    var s = BigInteger.valueOf(0);
    for (int i = 1; i <= 1234567890; ++i)
      s = s.add(BigInteger.valueOf(i));
    System.out.println(s);
  }
}
