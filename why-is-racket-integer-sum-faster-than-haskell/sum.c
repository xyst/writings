#include <stdio.h>
#include <gmp.h>

int main(void) {
  mpz_t s;
  mpz_init(s);
  for (unsigned long i = 1; i <= 1234567890; ++i)
    mpz_add_ui(s, s, i);
  gmp_printf("%Zd\n", s);
  return 0;
}
