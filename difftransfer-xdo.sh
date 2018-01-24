#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
val=$(bash "$DIR"/difftransfer.sh "$1" "$2")
echo "$val"
echo
echo -n 'ETA: '
date --date=$(dc -e $(echo "$val" | wc -c)" 0.14 * 5 + p" )" seconds"
sleep 5
xdotool type --delay 200 "$val"
date
