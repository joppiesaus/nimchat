# Public Domain Dedication
#
# Written in 2014 by Reimer Behrends <behrends@gmail.com>
#
# To the extent possible under law, the author(s) have dedicated all
# copyright and related and neighboring rights to this software to the
# public domain worldwide. This software is distributed without any
# warranty.
#
# You should have received a copy of the CC0 Public Domain Dedication
# along with this software in the file COPYING. If not, see
# <http://creativecommons.org/publicdomain/zero/1.0/>.

# Thank you Reimer Behrends!

const gmpdll = "-lgmp"

{.passl: gmpdll.}

{.pragma: gmptype, header: "<gmp.h>", importc.}
{.pragma: gmpdef, header: "<gmp.h>", cdecl, importc.}

type
  mpz_t {.gmptype.} = object
  mpq_t {.gmptype.} = object
  bitcount = uint

type
  GmpInt* = ref object
    value: mpz_t
  GmpRat* = ref object
    value: mpq_t

{.hints:off.}

proc mpz_init(x: mpz_t) {.gmpdef.}
proc mpz_init_set(x, y: mpz_t) {.gmpdef.}
proc mpz_init_set_ui(x: mpz_t, y: uint) {.gmpdef.}
proc mpz_init_set_si(x: mpz_t, y: int) {.gmpdef.}
proc mpz_init_set_d(x: mpz_t, y: float64) {.gmpdef.}
proc mpz_init_set_str(x: mpz_t, s: cstring, base: cint) {.gmpdef.}
proc mpz_clear(x: mpz_t) {.gmpdef.}

proc mpz_add(r, op1, op2: mpz_t) {.gmpdef.}
proc mpz_add_ui(r, op1: mpz_t, op2: uint) {.gmpdef.}
proc mpz_sub(r, op1, op2: mpz_t) {.gmpdef.}
proc mpz_sub_ui(r, op1: mpz_t, op2: uint) {.gmpdef.}
proc mpz_ui_sub(r: mpz_t, op1: uint, op2: mpz_t) {.gmpdef.}
proc mpz_mul(r, op1, op2: mpz_t) {.gmpdef.}
proc mpz_mul_si(r, op1: mpz_t, op2: int) {.gmpdef.}
proc mpz_mul_ui(r, op1: mpz_t, op2: uint) {.gmpdef.}
proc mpz_addmul(r, op1, op2: mpz_t) {.gmpdef.}
proc mpz_addmul_ui(r, op1: mpz_t, op2: uint) {.gmpdef.}
proc mpz_submul(r, op1, op2: mpz_t) {.gmpdef.}
proc mpz_submul_ui(r, op1: mpz_t, op2: uint) {.gmpdef.}
proc mpz_neg(r, op: mpz_t) {.gmpdef.}
proc mpz_abs(r, op: mpz_t) {.gmpdef.}

proc mpz_fdiv_q(q, op1, op2: mpz_t) {.gmpdef.}
proc mpz_fdiv_r(r, op1, op2: mpz_t) {.gmpdef.}
proc mpz_fdiv_qr(q, r, op1, op2: mpz_t) {.gmpdef.}
proc mpz_fdiv_q_2exp(q, op1: mpz_t, op2: bitcount) {.gmpdef.}
proc mpz_fdiv_r_2exp(r, op1: mpz_t, op2: bitcount) {.gmpdef.}

proc mpz_powm(r, base, exp, m: mpz_t) {.gmpdef.}
proc mpz_powm_ui(r, base, exp: mpz_t, m: uint) {.gmpdef.}
proc mpz_powm_sec(r, base, exp, m: mpz_t) {.gmpdef.}
proc mpz_pow_ui(r, base: mpz_t, exp: uint) {.gmpdef.}
proc mpz_ui_pow_ui(r: mpz_t, base, exp: uint) {.gmpdef.}

proc mpz_gcd(r, op1, op2: mpz_t) {.gmpdef.}
proc mpz_lcm(r, op1, op2: mpz_t) {.gmpdef.}
proc mpz_fac_ui(r: mpz_t, n: uint) {.gmpdef.}
proc mpz_bin_ui(r, n: mpz_t, k: uint) {.gmpdef.}
proc mpz_bin_uiui(r: mpz_t, n, k: uint) {.gmpdef.}
proc mpz_probab_prime_p(n: mpz_t, reps: cint): cint {.gmpdef.}

proc mpz_cmp(a, b: mpz_t): cint {.gmpdef.}
proc mpz_cmp_d(a: mpz_t, d: float64): cint {.gmpdef.}
proc mpz_cmp_si(a: mpz_t, d: int): cint {.gmpdef.}
proc mpz_cmp_ui(a: mpz_t, d: uint): cint {.gmpdef.}
proc mpz_cmpabs(a, b: mpz_t): cint {.gmpdef.}
proc mpz_cmpabs_d(a: mpz_t, d: float64): cint {.gmpdef.}
proc mpz_cmpabs_ui(a: mpz_t, d: uint): cint {.gmpdef.}
proc mpz_sgn(x: mpz_t): cint {.gmpdef.}

proc mpz_and(r, op1, op2: mpz_t) {.gmpdef.}
proc mpz_ior(r, op1, op2: mpz_t) {.gmpdef.}
proc mpz_xor(r, op1, op2: mpz_t) {.gmpdef.}
proc mpz_com(r, op: mpz_t) {.gmpdef.}
proc mpz_popcount(op: mpz_t): bitcount {.gmpdef.}
proc mpz_setbit(r: mpz_t, n: bitcount) {.gmpdef.}
proc mpz_clrbit(r: mpz_t, n: bitcount) {.gmpdef.}
proc mpz_combit(r: mpz_t, n: bitcount) {.gmpdef.}
proc mpz_tstbit(r: mpz_t, n: bitcount): cint {.gmpdef.}
proc mpz_odd_p(op: mpz_t): cint {.gmpdef.}
proc mpz_even_p(op: mpz_t): cint {.gmpdef.}

proc mpz_get_str(str: cstring, base: cint, op: mpz_t): cstring {.gmpdef.}
proc mpz_sizeinbase(op: mpz_t, base: cint): csize {.gmpdef.}

proc mpq_init(x: mpq_t) {.gmpdef.}
proc mpq_clear(x: mpq_t) {.gmpdef.}

proc finalizerInt(z: GmpInt) =
  mpz_clear(z.value)

proc finalizerRat(q: GmpRat) =
  mpq_clear(q.value)

proc newGmpInt*(): GmpInt =
  new(result, finalizerInt)
  mpz_init(result.value)

proc newGmpInt*(i: int): GmpInt =
  new(result, finalizerInt)
  mpz_init_set_si(result.value, i)

proc newGmpInt*(u: uint): GmpInt =
  new(result, finalizerInt)
  mpz_init_set_ui(result.value, u)

proc toGmpInt*(i: int): GmpInt =
  new(result, finalizerInt)
  mpz_init_set_si(result.value, i)

proc toGmpInt*(u: uint): GmpInt =
  new(result, finalizerInt)
  mpz_init_set_ui(result.value, u)

template Z*(x: int|uint): GmpInt =
  toGmpInt(x)

proc newRat*(): GmpRat =
  new(result, finalizerRat)
  mpq_init(result.value)

proc parseGmpInt*(s: string, base: int = 10): GmpInt =
  new(result, finalizerInt)
  mpz_init_set_str(result.value, s, base.cint)

proc `+`*(z1, z2: GmpInt): GmpInt =
  result = newGmpInt()
  mpz_add(result.value, z1.value, z2.value)

proc `+`*(z: GmpInt, i: int): GmpInt =
  result = newGmpInt()
  if i >= 0:
    mpz_add_ui(result.value, z.value, i.uint)
  else:
    mpz_sub_ui(result.value, z.value, (0 -% i).uint)

proc `-`*(z1, z2: GmpInt): GmpInt =
  result = newGmpInt()
  mpz_sub(result.value, z1.value, z2.value)

proc `-`*(z: GmpInt, i: int): GmpInt =
  result = newGmpInt()
  if i >= 0:
    mpz_sub_ui(result.value, z.value, i.uint)
  else:
    mpz_add_ui(result.value, z.value, (0 -% i).uint)

proc `-`*(z: GmpInt): GmpInt =
  result = newGmpInt()
  mpz_neg(result.value, z.value)

proc abs*(z: GmpInt): GmpInt =
  result = newGmpInt()
  mpz_abs(result.value, z.value)

proc sgn*(z: GmpInt): int =
  result = mpz_sgn(z.value)

proc `*`*(z1, z2: GmpInt): GmpInt =
  result = newGmpInt()
  mpz_mul(result.value, z1.value, z2.value)

proc `*`*(z: GmpInt, i:int): GmpInt =
  result = newGmpInt()
  mpz_mul_si(result.value, z.value, i)

proc `div`*(z1, z2: GmpInt): GmpInt =
  result = newGmpInt()
  mpz_fdiv_q(result.value, z1.value, z2.value)

proc `mod`*(z1, z2: GmpInt): GmpInt =
  result = newGmpInt()
  mpz_fdiv_r(result.value, z1.value, z2.value)

proc divmod*(q, r: var GmpInt, z1, z2: GmpInt) =
  q = newGmpInt()
  r = newGmpInt()
  mpz_fdiv_qr(q.value, r.value, z1.value, z2.value)

proc powmod*(base, exp, modulus: GmpInt): GmpInt =
  result = newGmpInt()
  mpz_powm(result.value, base.value, exp.value, modulus.value)

proc powmod*(base, exp: GmpInt, modulus: int): GmpInt =
  assert modulus >= 0
  result = newGmpInt()
  mpz_powm_ui(result.value, base.value, exp.value, modulus.uint)

proc powmod*(base, exp: GmpInt, modulus: uint): GmpInt =
  result = newGmpInt()
  mpz_powm_ui(result.value, base.value, exp.value, modulus)

proc fact*(i: int): GmpInt =
  result = newGmpInt()
  mpz_fac_ui(result.value, i.uint)

proc binom*(a, b: int): GmpInt =
  assert a >= 0 and b >= 0
  result = newGmpInt()
  mpz_bin_uiui(result.value, a.uint, b.uint)

proc `^`*(z: GmpInt, i: int): GmpInt =
  assert i >= 0
  result = newGmpInt()
  mpz_pow_ui(result.value, z.value, i.uint)

proc `^`*(a, b: int): GmpInt =
  assert b >= 0
  result = newGmpInt()
  if a >= 0:
    mpz_ui_pow_ui(result.value, a.uint, b.uint)
  else:
    mpz_ui_pow_ui(result.value, a.uint, b.uint)
    if (b and 1) == 0:
      result = -result

proc gcd*(z1, z2: GmpInt): GmpInt =
  result = newGmpInt()
  mpz_gcd(result.value, z1.value, z2.value)

proc lcm*(z1, z2: GmpInt): GmpInt =
  result = newGmpInt()
  mpz_lcm(result.value, z1.value, z2.value)

proc cmp*(z1, z2: GmpInt): int =
  mpz_cmp(z1.value, z2.value)

proc `==`*(z1, z2: GmpInt): bool =
  mpz_cmp(z1.value, z2.value) == 0

proc `==`*(z: GmpInt, i: int): bool =
  mpz_cmp_si(z.value, i) == 0

proc `==`*(i: int, z: GmpInt): bool =
  mpz_cmp_si(z.value, i) == 0

proc `<`*(z1, z2: GmpInt): bool =
  mpz_cmp(z1.value, z2.value) < 0

proc `<`*(z: GmpInt, i: int): bool =
  mpz_cmp_si(z.value, i) < 0

proc `<`*(i: int, z: GmpInt): bool =
  mpz_cmp_si(z.value, i) > 0

proc `<=`*(z1, z2: GmpInt): bool =
  mpz_cmp(z1.value, z2.value) <= 0

proc `<=`*(z: GmpInt, i: int): bool =
  mpz_cmp_si(z.value, i) <= 0

proc `<=`*(i: int, z: GmpInt): bool =
  mpz_cmp_si(z.value, i) >= 0

proc `and`*(z1, z2: GmpInt): GmpInt =
  result = newGmpInt()
  mpz_and(result.value, z1.value, z2.value)

proc `or`*(z1, z2: GmpInt): GmpInt =
  result = newGmpInt()
  mpz_ior(result.value, z1.value, z2.value)

proc `xor`*(z1, z2: GmpInt): GmpInt =
  result = newGmpInt()
  mpz_xor(result.value, z1.value, z2.value)

proc `not`*(z: GmpInt): GmpInt =
  result = newGmpInt()
  mpz_com(result.value, z.value)

proc setBit*(z: GmpInt, i: int) =
  assert i >= 0
  mpz_setbit(z.value, i.bitcount)

proc clearBit*(z: GmpInt, i: int) =
  assert i >= 0
  mpz_clrbit(z.value, i.bitcount)

proc flipBit*(z: GmpInt, i: int) =
  assert i >= 0
  mpz_combit(z.value, i.bitcount)

proc testBit(z: GmpInt, i: int): bool =
  assert i >= 0
  mpz_tstbit(z.value, i.bitcount) != 0

proc countBits(z: GmpInt): int =
  mpz_popcount(z.value).int

proc isOdd*(z: GmpInt): bool =
  mpz_odd_p(z.value) != 0

proc isEven*(z: GmpInt): bool =
  mpz_even_p(z.value) != 0

proc toString*(z: GmpInt, base: int = 10): string =
  let estLen = mpz_sizeinbase(z.value, base.cint)+2
  result = newString(estLen)
  discard mpz_get_str(result, base.cint, z.value)
  for i in 1..estLen-1:
    if result[i] == '\0':
      result.setLen(i)
      return

proc `$`*(z: GmpInt): string =
  let estLen = mpz_sizeinbase(z.value, 10)+2
  result = newString(estLen)
  discard mpz_get_str(result, 10, z.value)
  for i in 1..estLen-1:
    if result[i] == '\0':
      result.setLen(i)
      return
