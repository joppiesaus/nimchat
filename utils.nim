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
