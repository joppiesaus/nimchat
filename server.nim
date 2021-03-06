import os, strutils, asyncnet, asyncdispatch, lists, rsa, utils

type Receiver = object
    k: PublicKey
    s: AsyncSocket

let pargs = commandLineParams()

if paramCount() < 1:
    echo "Usage: ", paramStr(0), " <port>"
    quit(QuitFailure)

let port = parseInt(pargs[0])

var
    keypair: KeyPair
    receivers {.threadvar.}: DoublyLinkedList[Receiver]
    senders {.threadvar.}: DoublyLinkedList[AsyncSocket]
    bits = DefaultBitsEncryption

proc broadcast(message: string) {.async.} =
    echo message
    var msg = (message & "\n").encodeToEncryptionBase()
    for c in receivers:
        var
            i = 0
            prevI = 0
            blockSize = c.k.getBlockSize(EncryptionBase)
        while true:
            i += blockSize
            if i >= msg.len:
                break
            if i != msg.high and
                msg[i - 1] != EncodeEncryptionBaseThingSplitChar and
                msg[i] != EncodeEncryptionBaseThingSplitChar:
                while msg[i] != EncodeEncryptionBaseThingSplitChar:
                    i -= 1
            await c.s.send(encrypt(c.k, msg[prevI..i]) & "\n")
            prevI = i
        if prevI < msg.high:
            await c.s.send(encrypt(c.k, msg[prevI..msg.high]) & "\n")
        await c.s.send(MessageEnd & "\n")

proc processSender(node: DoublyLinkedNode[AsyncSocket]) {.async.} =
    var sender = node.value
    while true:
        var msg = ""
        while true:
            # TODO: What if fails or wrong format?
            let line = await sender.recvLine()
            if line == MessageEnd:
                break
            elif line == "":
                sender.close()
                senders.remove(node)
                asyncCheck broadcast("Sender disconnected")
                return
            var c = decrypt(keypair.private, line)
            msg.add(c)
            #stdout.write(c)
        msg = msg.decodeFromEncryptionBase()
        #stdout.write("\n") # TODO: What if two at the same time? Maybe just ouput message,
        # and not the rest. but this is real-time so it is cool!!!
        asyncCheck broadcast(msg)

proc serve() {.async.} =
    receivers = initDoublyLinkedList[Receiver]()
    senders = initDoublyLinkedList[AsyncSocket]()
    keypair = generateKeyPair(bits)

    var server = newAsyncSocket()
    server.bindAddr(Port(port))
    server.listen()

    while true:
        let client = await server.accept()
        let openingLine = await client.recvLine()

        case openingLine:
        of SockSender:
            # TODO: Will stuff like this halt everything? Maybe spawn?
            await client.send(keypair.public.toBroadcastString())
            let node = newDoublyLinkedNode(client)
            senders.append(node)
            asyncCheck processSender(node)
            asyncCheck broadcast("Sender connected!")
        of SockReceiver:
            var receiver: Receiver
            var n = await client.recvLine()
            var e = await client.recvLine()
            var c = await client.recvLine()
            receiver.k = initPublicKey(n, e, c)
            receiver.s = client
            # TODO: what if connection is closed?
            receivers.append(newDoublyLinkedNode(receiver))
            asyncCheck broadcast("Receiver connected!")
        else:
            continue

asyncCheck serve()
runForever()
