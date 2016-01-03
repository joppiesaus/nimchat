import net, strutils, os

let pargs = commandLineParams()

if paramCount() < 2:
     echo "Usage: ", paramStr(0), " <host> <port>"
     quit(QuitFailure)

let
     host = pargs[0]
     port = parseInt(pargs[1])

var s = newSocket()

s.connect(host, Port(port))

while true:
     var response = TaintedString""
     s.readLine(response)
     echo response
