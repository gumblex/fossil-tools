#!/bin/bash

# apt install inotify-tools

DIRNAME="${PWD##*/}"
FOSSILREPO=".fossil"
DATEFORMAT="+%Y-%m-%d %H:%M:%S"

if [ ! -f "$FOSSILREPO" ]; then
    fossil new "$FOSSILREPO"
    fossil rebuild --wal "$FOSSILREPO"
    fossil sqlite3 -R "$FOSSILREPO" "INSERT OR REPLACE INTO config VALUES ('project-name', '$DIRNAME', now());"
    fossil open "$FOSSILREPO"
    fossil addremove
    fossil commit --no-warnings -m "initial commit"
fi

while true; do
    inotifywait --exclude _FOSSIL_ --exclude .fslckout --exclude "$FOSSILREPO*" -r -e create -e modify -e delete -e move .
    # Check NGINX Configuration Test
    # Only Reload NGINX If NGINX Configuration Test Pass
    now="$(date "$DATEFORMAT" | tee /dev/tty)"
    echo "$now"
    msg="$now $(fossil addremove | tee /dev/tty | head -n 1)"
    fossil commit -m "$msg"
done
