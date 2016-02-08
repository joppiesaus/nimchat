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
    var message = prefix & readLine(stdin)
    var m = ""
    var i = 0
    for c in message:
        i += 1
        m.add(c)
        if i == blockSize:
            s.send(encrypt(publicKey, m) & "\n")
            m = ""
            i = 0
    if i != 0:
        s.send(encrypt(publicKey, m) & "\n")
    s.send(MessageEnd & "\n")
