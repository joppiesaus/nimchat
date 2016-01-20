import math

type PublicKey* = object
    n: int # public key
    e: int  # exponent

type PrivateKey* = object
    n: int # public key
    d: int # private key

type KeyPair* = object
    public: PublicKey
    private: PrivateKey


# Returns factor^power % modulus
proc modexp(factor, power, modulus: int): int =
    result = 1
    var
        fac = factor
        pow = power
    while pow > 0:
        if pow mod 2 == 1:
            result = (result * fac) mod modulus
            pow -= 1
        pow = pow shr 1 # divide by 2. (pow = int(pow / 2))
        fac = (fac * fac) mod modulus

# Returns n^-1 % modulus
# Uses the extended euclidian algorithm
proc invmod(n, modulus: int): int =
    var
        a = n
        b = modulus
        x = 0
        x0 = 1
        q, temp: int
    while b != 0:
        q = int(a / b)
        temp = a mod b
        a = b
        b = temp
        temp = x
        x = x0 - q * x
        x0 = temp
    if x0 < 0:
        x0 += modulus
    return x0

# Returns gcd(a, b)
proc gcd(a, b: int): int =
    var
        x = a
        y = b
        z: int
    while y != 0:
        z = x mod y
        x = y
        y = z
    return x

# returns false if n is composite, and true if n is probably prime
proc isPrime(n: int): bool =
    const Trails = 20
    for i in 1..Trails:
        # random number between 1 and n - 1
        var test = random(n - 2) + 2

        if gcd(test, n) != 1:
            return false

        if modexp(test, n - 1, n) != 1:
            return false
    return true

# returns a random prime, between 3 and max - 1
# not uniform
# ...hopefully(there's a chance it will return a composite)
proc generatePrime(max: int): int =
    let m = max + (max mod 2) - 4
    while true:
        let prime = random(m) + 4
        if prime mod 2 == 0:
            continue
        if isPrime(prime):
            return prime

# returns a random exponent between n -1 and >= 3, sharing no factors with phi
proc generateE(phi, n: int): int =
    # inneficient?
    while true:
        var e = random(n - 3) + 3
        if gcd(e, phi) == 1: return e
    return 3 #huehuehuehue 65537


proc generateKeyPair*(): KeyPair =
    var
        e, q, p, phi, n, d: int

    const
        maxPrime = 10001
        maxExponent = 1000

    while true:
        q = generatePrime(maxPrime)
        p = generatePrime(maxPrime)
        n = q * p
        if n > 127:
            break

    phi = (q - 1) * (p - 1)
    e = generateE(phi, maxExponent)
    d = invmod(e, phi)

    echo "p: ", p, ", q: ", q
    echo "phi: ", phi, "(p - 1) * (q - 1), where p and q prime"
    echo "public key: ", n, ", ", e
    echo "private key: ", d

    return KeyPair(public: PublicKey(n: n, e: e), private: PrivateKey(n: n, d: d))

proc encrypt*(k: PublicKey, data: int): int =
    return modexp(data, k.e, k.n)

proc decrypt*(k: PrivateKey, data: int): int =
    return modexp(data, k.d, k.n)

proc doTest(keys: KeyPair, test: int) =
    var encryptedTest = encrypt(keys.public, test)
    echo test, " => ", encryptedTest

    var decryptedTest = decrypt(keys.private, encryptedTest)
    echo encryptedTest, " => ", decryptedTest

when isMainModule:
    echo "sheep"
    randomize()
    echo "Random prime: ", generatePrime(20000000)

    let keys = generateKeyPair()

    echo ""
    for i in 1..3:
        echo "# Test ", i, ":"
        doTest(keys, random(256))
