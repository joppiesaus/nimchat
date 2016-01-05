import os, strutils, asyncnet, asyncdispatch, lists

let pargs = commandLineParams()

if paramCount() < 1:
    echo "Usage: ", paramStr(0), "<port>"
    quit(QuitFailure)

let port = parseInt(pargs[0])

var clients {.threadvar.}: DoublyLinkedList[AsyncSocket]
var clientCount = 0

proc broadcast(message: string) {.async.} =
    echo message
    for c in clients:
        await c.send(message & "\n")

proc processClient(node: DoublyLinkedNode[AsyncSocket]) {.async.} =
    var client = node.value
    while true:
        let line = await client.recvLine()
        if line == "":  
            clients.remove(node)
            clientCount -= 1
            client.close()
            asyncCheck broadcast("Client disconnected! " & $clientCount & " online now!")
            break

        asyncCheck broadcast(line)

proc serve() {.async.} =
    clients = initDoublyLinkedList[AsyncSocket]()
    var server = newAsyncSocket()
    server.bindAddr(Port(port))
    server.listen()

    while true:
        let client = await server.accept()
        let node = newDoublyLinkedNode(client)
        clients.append(node)
        clientCount += 1
        asyncCheck processClient(node)
        asyncCheck broadcast("New client connected! " & $clientCount & " online now!")

asyncCheck serve()
runForever()
