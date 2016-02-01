import rsa, strutils

const
    MessageEnd* = "JAN"
    SockSender* = "TEA"
    SockReceiver* = "CUP"


proc toBroadcastString*(k: PublicKey): string =
    return $k.n & "\n" & $k.e & "\n"

proc initPublicKey*(a: string, b: string): PublicKey =
    result.n = parseInt(a)
    result.e = parseInt(b)
