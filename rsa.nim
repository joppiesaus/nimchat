import math, strutils, gmp, random

type PublicKey* = object
    n*: GmpInt # public key
    e*: GmpInt  # exponent
    bits*: int

type PrivateKey* = object
    n*: GmpInt # public key
    d*: GmpInt # private key
    bits*: int

type KeyPair* = object
    public*: PublicKey
    private*: PrivateKey


# Returns n^-1 % modulus
# Uses a modified version of the extended euclidian algorithm
proc invmod(n, modulus: GmpInt): GmpInt =
    var
        rem = n
        remprev = modulus
        aux = 1.Z
        auxprev = newGmpInt()
        rcur = newGmpInt()
        qcur = newGmpInt()
        acur = newGmpInt()
    while rem > 1:
        divMod(qcur, rcur, remprev, rem)
        acur = modulus - qcur
        acur = acur * aux
        acur = acur + auxprev
        acur = acur mod modulus
        remprev = rem
        auxprev = aux
        rem = rcur
        aux = acur
    return acur


# Generates a random number of max n bits length
proc randomNumber(max: int): GmpInt =
    var s = ""
    let length = random(max) + 1
    for i in 1..length:
        s.add(char(random(2) + ord('0')))
    result = parseGmpInt(s, 2)

# returns false if n is composite, and true if n is probably prime
proc isPrime(n: GmpInt, trailBytes: int, trails: int = 20): bool =
    for i in 1..trails:
        # Take a random number < n
        var test = randomNumber(trailBytes) - 1

        # if it divises n, n is not a prime
        if gcd(test, n) != 1:
            return false

        # fermat test: n^p-1 mod p always equals 1 where n is any integer and p a prime
        if powmod(test, n - 1, n) != 1:
            return false
    return true

# Returns (hopefully) a random prime of n bits
proc generatePrime(n: int): GmpInt =
    while true:
        var s = ""
        s[0] = '1' # Ensure the number is big
        for i in 1..n - 1:
            s.add(char(random(2) + ord('0')))
        s.add('1')
        var x = parseGmpInt(s, 2)
        # uncomment if you are working with a different base
        #if x.isEven():
        #    x = x + 1
        if isPrime(x, n):
            return x

proc generateE(phi: GmpInt): GmpInt =
    while true:
        let e = random((int high int) - 3) + 3
        if gcd(e.Z, phi) == 1: return e.Z # ez pz lemon sqeez
    return 65537.Z # kappa

proc generateKeyPair*(bits: int): KeyPair =
    var
        e, q, p, phi, n, d: GmpInt
    let hbits = bits div 2
    randomize()

    q = generatePrime(hbits)
    p = generatePrime(hbits)
    n = q * p

    phi = (q - 1) * (p - 1)
    e = generateE(phi) #65537.Z
    d = invmod(e, phi)

    when isMainModule:
        echo "p: ", p, ", q: ", q
        echo "phi: ", phi, "(p - 1) * (q - 1), where p and q prime"
        echo "public key: ", n, ", ", e
        echo "private key: ", d

    return KeyPair(
        public: PublicKey(n: n, e: e, bits: bits),
        private: PrivateKey(n: n, d: d, bits: bits)
    )

proc encrypt*(k: PublicKey, data: GmpInt): GmpInt =
    return powmod(data, k.e, k.n)

proc decrypt*(k: PrivateKey, data: GmpInt): GmpInt =
    return powmod(data, k.d, k.n)

proc getBlockSize*(k: PublicKey, base: int): int =
    return int(float(k.bits) / sqrt(float base))

proc getBlockSize*(k: PrivateKey, base: int): int =
    return int(float(k.bits) / sqrt(float base))


proc doTest(keys: KeyPair, test: GmpInt) =
    var encryptedTest = encrypt(keys.public, test)
    echo test, " => ", encryptedTest

    var decryptedTest = decrypt(keys.private, encryptedTest)
    echo encryptedTest, " => ", decryptedTest

    assert $test == $decryptedTest

when isMainModule:
    #echo "Random prime: ", generatePrime(512)

    const bits = 130 # Calm down it's just a test okay!
    let keys = generateKeyPair(bits)

    echo "bits: ", keys.public.bits
    echo "blocksize: ", keys.public.getBlockSize(62)

    echo ""
    for i in 1..3:
        echo "# Test ", i, ":"
        doTest(keys, randomNumber(bits))
