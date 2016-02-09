import net, strutils, os, rsa, utils

let pargs = commandLineParams()

if paramCount() < 2:
    echo "Usage: ", paramStr(0), " <host> <port> [prefix]"
    quit(QuitFailure)

let
    host = pargs[0]
    port = parseInt(pargs[1])
    prefix = if paramCount() > 2: pargs[2] else: ""

var s = newSocket()
var publicKey: PublicKey

s.connect(host, Port(port))

# Receive key
s.send(SockSender & "\n")
# What a mess
var tmpLine = TaintedString""
s.readLine(tmpLine)
publicKey.n = fromBroadcastString(string tmpLine)
tmpLine = TaintedString""
s.readLine(tmpLine)
publicKey.e = fromBroadcastString(string tmpLine)
tmpLine = TaintedString""
s.readLine(tmpLine)
publicKey.bits = parseInt(string tmpLine)

var blockSize = publicKey.getBlockSize(EncryptionBase)

while true:
    var
        # Encode to encryption base
        message = encodeToEncryptionBase(prefix & readLine(stdin))
        i = 0
        prevI = 0
    while true:
        i += blockSize
        if i >= message.len:
            break
        # Make sure the characters are broadcast correctly(not split halfway)
        if i != message.high and
            message[i - 1] != EncodeEncryptionBaseThingSplitChar and
            message[i] != EncodeEncryptionBaseThingSplitChar:
            while message[i] != EncodeEncryptionBaseThingSplitChar:
                i -= 1
        # Encrypt and send it
        s.send(encrypt(publicKey, message[prevI..i]) & "\n")
        prevI = i
    if prevI < message.high:
        s.send(encrypt(publicKey, message[prevI..message.high]) & "\n")
    s.send(MessageEnd & "\n") # Declare end-of-message
