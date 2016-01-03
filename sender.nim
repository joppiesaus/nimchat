import net, strutils, os

let pargs = commandLineParams()

if paramCount() < 2:
     echo "Usage: ", paramStr(0), " <host> <port> [prefix]"
     quit(QuitFailure)

let
     host = pargs[0]
     port = parseInt(pargs[1])
     prefix = if paramCount() > 2: pargs[2] else: ""

var s = newSocket()

s.connect(host, Port(port))

while true:
     s.send(prefix & readLine(stdin) & "\n")
