#!/usr/bin/env bash
# BASH IS FUNNY
build="debug"
command="nim c"
files="server.nim
sender.nim
receiver.nim"

if [ -n "$1" ]; then
	if [ "$1" = "release" ] || [ "$1" = "r" ]; then
		command="$command -d:release"
		build="release"
	else
		echo "No idea what build that is, going to build $build instead"
	fi
else
	echo "No argument specified, building default $build"
fi

echo "Initiating build nimchat $build($command)..."

for file in $files; do
	echo "Building $file..."
	($command $file)
	if [ "$?" != "0" ]; then
		# having some fun here
		echo -en "\e[48;5;197;1mBuild failed, aborting"
		echo -e "\e(B\e[m"
		exit 1
	fi
done
