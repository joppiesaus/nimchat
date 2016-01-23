# VERY LARGE SIGH
# Very thank you to https://github.com/pantaloons/RSA/blob/master/multiple.c
# and https://github.com/peterolson/BigInteger.js
type BigNum* = object
    limbs: seq[uint32]

proc initBigNum*(n: seq[uint32] = @[]): BigNum =
    result.limbs = n

proc initBigNum*(n: int): BigNum =
    initBigNum(@[uint32 n])

const bignumZero = 0.initBigNum
const bignumOne = 1.initBigNum
const bignumTwo = 2.initBigNum

const BASE = int high uint32
const UBASE = uint64 BASE
const HALFRADIX = BASE shr 1

# Creates a bignum with n limbs
proc initBigNumWithLength*(n: int): BigNum =
    result.limbs = @[]
    for i in 1..n:
        result.limbs.add(0)

# Removes all trailing zeros in front of a bignum
proc trim*(n: var BigNum) =
    for i in countdown(n.limbs.len - 1, 1):
        if n.limbs[i] == 0: n.limbs.delete(i)
        else: return

proc iszero*(n: BigNum): bool =
    return n.limbs.len == 0 or (n.limbs.len == 1 and n.limbs[0] == 0)

proc equal(a, b: BigNum): bool =
    if a.limbs.len != b.limbs.len:
        return false
    for i in countdown(a.limbs.len - 1, 0):
        if a.limbs[i] != b.limbs[i]:
            return false
    return true

proc `==`*(a, b: BigNum): bool = equal(a, b)

proc greater(a, b: BigNum): bool =
    if a.limbs.len != b.limbs.len:
        return a.limbs.len > b.limbs.len
    for i in countdown(a.limbs.len - 1, 0):
        if a.limbs[i] != b.limbs[i]:
            return a.limbs[i] > b.limbs[i]
    return false

proc `>`*(a, b: BigNum): bool = greater(a, b)

proc less(a, b: BigNum): bool =
    if a.limbs.len != b.limbs.len:
        return a.limbs.len < b.limbs.len
    for i in countdown(a.limbs.len - 1, 0):
        if a.limbs[i] != b.limbs[i]:
            return a.limbs[i] < b.limbs[i]
    return false

proc `<`*(a, b: BigNum): bool = less(a, b)
proc `>=`*(a, b: BigNum): bool = not less(a, b)
proc `<=`*(a, b: BigNum): bool = not greater(a, b)

# computes c = a + b
proc add(c: var BigNum, a, b: BigNum) =
    var
        sum = 0'u32
        carry = 0'u32
    let n = max(a.limbs.len, b.limbs.len)
    c = initBigNum()
    for i in 0..<n:
        sum = carry
        if i < a.limbs.len: sum += a.limbs[i]
        if i < b.limbs.len: sum += b.limbs[i]
        c.limbs.add(sum)
        if i < a.limbs.len:
            if sum < a.limbs[i]: carry = 1
            else: carry = 0
        else:
            if sum < b.limbs[i]: carry = 1
            else: carry = 0
    if carry == 1:
        c.limbs.add(1)

proc `+`*(a, b: BigNum): BigNum = add(result, a, b)

template `+=`*(a: var BigNum, b: BigNum) =
    var c = a
    add(a, c, b)

# computes c = a - b
proc substract(c: var BigNum, a, b: BigNum) =
    c = initBigNum()
    var
        temp = 0'u32
        carry = 0'u32
        diff = 0'u32
    for i in 0..<b.limbs.len:
        temp = carry
        if i < b.limbs.len: temp = temp + b.limbs[i]
        diff = a.limbs[i] - temp
        carry = if temp > a.limbs[i]: 1 else: 0
        c.limbs.add(diff)

proc `-`*(a, b: BigNum): BigNum = substract(result, a, b)

template `-=`*(a: var BigNum, b: BigNum) =
    var c = a
    substract(a, c, b)

# computes c = a * b
proc multiply(c: var BigNum, a, b: BigNum) =
    c = initBigNumWithLength(a.limbs.len + b.limbs.len)
    var
        product = 0'u64
        carry = 0'u32
    for i in 0..<a.limbs.len:
        let a_i = uint64 a.limbs[i]
        for j in 0..<b.limbs.len:
            product = a_i * (uint64 b.limbs[j]) + (uint64 c.limbs[i + j])
            carry = uint32(product div UBASE)
            c.limbs[i + j] = uint32 (product - (uint64 carry) * UBASE)
            c.limbs[i + j + 1] += carry
    trim c #hueheuheuhe

proc `*`*(a, b: BigNum): BigNum = multiply(result, a, b)

template `*=`*(a: var BigNum, b: BigNum) =
    var c = a
    multiply(a, c, b)

# Computes a/b = q R r
proc divMod*(q, r: var BigNum, a, b: BigNum) =
    # DAMN YOU TYPES
    if b == bigNumZero:
        raise newException(ValueError, "Can't divide by zero!")
    elif a < b: # a/b = 0 r a where b > a
        q = bignumZero
        r = a
    elif b.limbs.len == 1: # Simple division
        q = initBigNumWithLength(a.limbs.len)
        var
            carry = 0'u64
            gtemp = 0'u64
            bl0 = uint64 b.limbs[0]
        for i in countdown(a.limbs.len - 1, 0):
            gtemp = carry * UBASE + (uint64 a.limbs[i])
            q.limbs[i] = uint32(gtemp div bl0)
            carry = gtemp mod bl0
        trim(q)
        r = (int carry).initBigNum
    else:
        # TODO: TEST
        var
            ac = a # copy of a
            bc = b # copy of b
            factor = 1
            carry = 0'u32
            gtemp = 0'u64
            gquot = 0'u64
            grem = 0'u64
            quottemp = bigNumZero
            temp2, temp3: BigNum
        let
            n = a.limbs.len + 1
            m = b.limbs.len

        q = initBigNumWithLength(n - m)

        # Normalize
        while bc.limbs[bc.limbs.len - 1] < HALFRADIX:
            factor *= 2
            bc *= bignumTwo
        if factor > 1:
            ac *= factor.initBigNum

        # Make sure that the dividend is no longer then the divisor
        # If it's not, inflate it with a dummy zero
        if a.limbs.len != n:
            ac.limbs.add(0)

        # Process quotient by long division
        for i in countdown(n - m - 1, 0):
            gtemp = UBASE * (uint64 ac.limbs[i + m]) + (uint64 ac.limbs[i + m - 1])
            gquot = uint64(gtemp div (uint64 bc.limbs[m - 1]))
            if gquot > UBASE:
                gquot = UBASE
            grem = gtemp mod (uint64 bc.limbs[m - 1])
            while grem < UBASE and
                gquot * (uint64 bc.limbs[m - 2]) >
                UBASE * grem + (uint64 ac.limbs[i + m - 2]):
                gquot -= 1
                grem += bc.limbs[m - 1]
            quottemp.limbs[0] = uint32(gquot mod UBASE)
            let quottemp2 = uint32(gquot div UBASE)
            if quottemp2 != 0:
                if quottemp.limbs.len == 1:
                    quottemp.limbs.add(quottemp2)
                else:
                    quottemp.limbs[1] = quottemp2
            elif quottemp.limbs.len != 1:
                quottemp.limbs.delete(1)
            temp2 = bc * quottemp
            temp3 = initBigNumWithLength(m + 1)
            for j in 0..m:
                temp3.limbs[j] = ac.limbs[i + j]
            trim(temp3)
            if temp3 < temp2:
                temp3 += bc
                gquot -= 1
            temp3 -= temp2
            for j in 0..<temp3.limbs.len:
                ac.limbs[i + j] = temp3.limbs[j]
            for j in temp3.limbs.len..m:
                ac.limbs[i + j] = 0
            q.limbs[i] = uint32 gquot

        trim(q)

        let uf = uint64 factor
        # Divide by factor to find final remainder
        for i in countdown(ac.limbs.len - 1, 0):
            gtemp = uint64(carry) * UBASE + uint64(ac.limbs[i])
            ac.limbs[i] = uint32(gtemp div uf)
            carry = uint32(gtemp mod uf)

        trim(ac)
        r = ac

proc `/`*(a, b: BigNum): BigNum =
    var d = bigNumZero
    divMod(result, d, a, b)

proc `div`*(a, b: BigNum): BigNum =
    var d = bigNumZero
    divMod(result, d, a, b)

template `/=`*(a: var BigNum, b: BigNum) =
    var d = bignumZero
    divMod(a, d, a, b)

proc `mod`*(a, b: BigNum): BigNum =
    var d = bigNumZero
    divMod(d, result, a, b)

# RIP computer standards
const DIGITS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

# Converts n to base notation. Default decimal notation.
proc toString*(n: BigNum, base: range[2..62] = 10): string =
    if n.iszero: return "0"
    let baseb = base.initBigNum
    var
        s = ""
        c = n
        r = bignumZero
    while not c.iszero:
        divmod(c, r, c, baseb)
        s.add(DIGITS[int r.limbs[0]])
    result = ""
    for i in countdown(s.len - 1, 0):
        result.add(s[i])

proc `$`*(n: BigNum): string = toString(n)

# Inits n with base base to a BigNum. Default decimal
proc initBigNum*(n: string, base: range[2..62] = 10): BigNum =
    result.limbs = @[0'u32]
    let baseb = base.initBigNum
    for i in n:
        result *= baseb

        case i:
        of '0'..'9': result += (ord(i) - ord('0')).initBigNum
        of 'A'..'Z': result += (ord(i) - ord('A') + 10).initBigNum
        of 'a'..'z': result += (ord(i) - ord('a') + 36).initBigNum
        else: raise newException(ValueError, "Invalid input: " & n)


# I probably should test this more...
when isMainModule:
    # Well this is what I call a testing-suite!
    var a = initBigNum(6)
    var b = initBigNum(7)

    var c = a + b
    c += 35.initBigNum
    echo c.limbs[0]

    var d = (int high uint32).initBigNum
    d += (int high uint32).initBigNum + 5153.initBigNum
    echo d.limbs[1], d.limbs[0]
    d -= d - 1.initBigNum
    echo d.limbs[0]
    echo c < d

    d = a * b
    echo d.limbs[0]
    echo d / 4.initBigNum
    echo d mod 4.initBigNum

    d = initBigNum(@[2'u32, 56'u32])
    var e = initBigNum(@[1'u32, 1'u32]) + 234234.initBigNum
    echo d / e
    echo d mod e
    var f = d/e
    echo d.toString
    echo e.toString
    echo f.toString

    f = "95241862187".initBigNum
    echo f
    echo f.toString(62)
    f = f.toString(62).initBigNum(62)
    echo f
    f = f / 524.initBigNum
    echo f
