import rsa, gmp, strutils

# AAAAAAAAAAAAAHHH SEND HELP

const
    MessageEnd* = ";"
    SockSender* = ">"
    SockReceiver* = "<"
    BASE = 62
    EncryptionBase* = BASE
    DefaultBitsEncryption* = 2048


proc toBroadcastString*(k: PublicKey): string =
    return k.n.toString(BASE) & "\n" & k.e.toString(BASE) & "\n" & $k.bits & "\n"

proc initPublicKey*(a: string, b: string, c: string): PublicKey =
    result.n = parseGmpInt(a, BASE)
    result.e = parseGmpInt(b, BASE)
    result.bits = parseInt(c)

proc fromBroadcastString*(n: string): GmpInt =
    return parseGmpInt(n, BASE)

proc toBroadcastString*(n: GmpInt): string =
    return n.toString(BASE)

proc encrypt*(k: PublicKey, s: string): string =
    return encrypt(k, parseGmpInt(s, BASE)).toString(BASE)

proc decrypt*(k: PrivateKey, s: string): string =
    return decrypt(k, parseGmpInt(s, BASE)).toString(BASE)


proc toHex(n: int): string =
    result = ""
    var
        s = ""
        c = n
        r = 0
    const DIGITS = "0123456789ABCDEF"
    const DIGITS_LEN = DIGITS.len
    while c != 0:
        s.add(DIGITS[c mod DIGITS_LEN])
        c = c div DIGITS_LEN
    for i in countdown(s.len - 1, 0):
        result.add(s[i])

# THIS IS ALL TERRIBLE HELP ME WHAT SHOULD I DO
# I WANT LIKE MAYBE POINTER AND WRITE IT TO THE SACKET WITH length
# AND THEN INTERPET IT AND THE CHARACTERS JUST INTO THA GmpInt
# BUT UNICODE CHARACTERS ACT VERY WEIRD
# ASDLKFJASKLDFJLASKDFJLKASDJFLKASJKLASDFJLKASDJFLKJASFLJKASDF
# HELP
const EncodeEncryptionBaseThingSplitChar = 'a'

proc encodeToEncryptionBase*(s: string): string =
    result = ""
    for c in s:
        result.add(ord(c).toHex() & EncodeEncryptionBaseThingSplitChar)
    delete(result, result.len - 1, result.len - 1)

proc decodeFromEncryptionBase*(s: string): string =
    result = ""
    var chars = s.split(EncodeEncryptionBaseThingSplitChar)
    for c in chars:
        result.add(char(parseHexInt(c)))

when isMainModule:
    var s = readLine(stdin)
    echo s.len
    s = encodeToEncryptionBase(s)
    echo s
    s = decodeFromEncryptionBase(s)
    echo s
