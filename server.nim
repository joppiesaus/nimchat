import os, strutils, asyncnet, asyncdispatch, lists

let pargs = commandLineParams()

if paramCount() < 1:
    echo "Usage: ", paramStr(0), "<port>"
    quit(QuitFailure)

let port = parseInt(pargs[0])

var clients {.threadvar.}: DoublyLinkedList[AsyncSocket]

proc processClient(node: DoublyLinkedNode[AsyncSocket]) {.async.} =
    var client = node.value
    while true:
        let line = await client.recvLine()
        if line == "":  
            clients.remove(node)
            client.close()
            echo "Client disconnected!"
            break

        echo line
        for c in clients:
            await c.send(line & "\n")

proc serve() {.async.} =
    clients = initDoublyLinkedList[AsyncSocket]()
    var server = newAsyncSocket()
    server.bindAddr(Port(port))
    server.listen()

    while true:
        let client = await server.accept()
        let node = newDoublyLinkedNode(client)
        clients.append(node)
        echo "New client connected!"
        asyncCheck processClient(node)

asyncCheck serve()
runForever()
