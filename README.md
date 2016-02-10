# nimchat
Simple chat shenanigans in Nim!
Now featuring encryption!

**DO NOT USE THIS FOR ANYTHING THAT MATTERS AND MUST REMAIN SECRET.** I am a someone who likes to program stuff, not a cryptographer. I have implemented 2048 bit RSA, which hasn't been cracked yet, but that doesn't mean that this particular implementation could be cracked. For example, maybe the way that primes are generated isn't uniform, which could be easily exploited. but I implemented it and there probably will be mistakes that make it easy to crack this encryption. If you're going snowden, don't use this program.


# Building
`nim c -d:release input.nim`

If you don't have Nim yet, [get it](http://nim-lang.org/download.html)!

This program uses GMP, so you need to have that installed. If you have GCC you usually have GMP, but on Windows you usually don't. You need to get it from http://win-builds.org/ and install it in your compiler. 

# Using
View `usage.txt`
