# nimchat
Simple chat shenanigans in Nim!
Now featuring encryption!

**DO NOT USE THIS FOR ANYTHING THAT MATTERS AND MUST REMAIN SECRET.** I am a someone who likes to program stuff, not a cryptographer. I have implemented 2048 bit RSA, which hasn't been cracked yet(as far as I know, but that doesn't mean it _hasn't_ been cracked or won't in the future), but that doesn't mean that this particular implementation could be cracked. For example, maybe the way that primes are generated isn't uniform, which could be easily exploited. Or the way random numbers are generated is flawed. but I implemented it and there probably will be mistakes that make it easy to crack this encryption. If you're going snowden, **DO NOT** use this program.


# Building
`./build.sh` for debug or `/build.sh release` for release mode

On Windows: `build`/`build release`

Or one at the time(I usually do this while developing): `nim c input.nim`

If you don't have Nim yet, [get it](http://nim-lang.org/download.html)!

## Dependencies
 * [`GNU MP`](https://gmplib.org/)

*nix: It usually comes with GCC. If you're on Debian/Ubuntu, `sudo apt install libgmp-dev`. If you're not, you'll probably know what to do.

Windows: Get it from http://win-builds.org/ !

(And you'll need [nim](http://nim-lang.org)(duh))

# Using
These are a set of programs which goal is to provide chat functions.
```
# SERVER - server <port>
	The server will run a chat server at destinated port.
	When a client connects to the server, it will be added to a list of
	clients. When a client pushses a line of text to the server, it will be
	broadcasted to all clients.

# SENDER - sender <host> <port> [prefix]
	This program will open a socket to host:port. Then it will allow you to
	enter data via stdin, which will be pushed trough the socket.
	If prefix is specified, it'll send the data with prefix in front of it.

# RECEIVER - receiver <host> <port>
	This program will open a socket to host:port, then it will echo all data
	that is being received by the socket.
```
(Or view `usage.txt`)
