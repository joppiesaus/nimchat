import net, strutils, os, rsa, utils

let pargs = commandLineParams()

if paramCount() < 2:
    echo "Usage: ", paramStr(0), " <host> <port>"
    quit(QuitFailure)

let
    host = pargs[0]
    port = parseInt(pargs[1])
    keypair = generateKeyPair()

var s = newSocket()

s.connect(host, Port(port))
s.send(SockReceiver & "\n")
s.send(toBroadcastString(keypair.public))

while true:
    while true:
        var response = TaintedString""
        s.readLine(response)
        if response == MessageEnd:
            break
        var c = decrypt(keypair.private, string(response))
        stdout.write c
        #echo response
    stdout.write("\n")
