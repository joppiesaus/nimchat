@echo off
REM BATCH IS FUNNY
SET build=debug
SET command=nim c
SET files=server.nim sender.nim receiver.nim

IF [%1]==[] (
    ECHO No argument specified, building default %build%
	GOTO build
)
IF "%~1"=="release" GOTO release
IF "%~1"=="r" GOTO release

ECHO No idea what build that is, going to build %build% instead
GOTO build

:release
SET command=%command% -d:release
SET build=release

:build
ECHO Initiating build nimchat %build%(%command%)...

FOR %%i IN (%files%) DO (
    ECHO Building %%i...
	%command% %%i
)
