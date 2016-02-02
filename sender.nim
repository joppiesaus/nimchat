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
publicKey.n = parseInt(string tmpLine)
tmpLine = TaintedString""
s.readLine(tmpLine)
publicKey.e = parseInt(string tmpLine)

while true:
    var message = prefix & readLine(stdin)

    for c in message:
        s.send(encrypt(publicKey, c) & "\n")

    s.send(MessageEnd & "\n")
    
