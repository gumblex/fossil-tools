#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
val=$(bash "$DIR"/difftransfer-enc.sh "$1" "$2")
sleep 5; xdotool type --delay 200 "$val"
