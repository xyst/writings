import java.math.BigInteger;

class Sum {
  public static void main(String[] args) {
    var s = BigInteger.valueOf(0);
    long begin = 444333222111L;
    for (long i = begin; i <= begin + 1234567890; ++i)
      s = s.add(BigInteger.valueOf(i));
    System.out.println(s);
  }
}
