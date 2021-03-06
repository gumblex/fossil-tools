#!/bin/bash

# apt install inotify-tools

DIRNAME="${PWD##*/}"
FOSSILREPO=".fossil"
DATEFORMAT="+%Y-%m-%d %H:%M:%S"
WAITSEC=3

if [ ! -f "$FOSSILREPO" ]; then
    fossil new "$FOSSILREPO"
    fossil rebuild --wal "$FOSSILREPO"
    fossil sqlite3 -R "$FOSSILREPO" "INSERT OR REPLACE INTO config VALUES ('project-name', '$DIRNAME', now());"
    fossil open "$FOSSILREPO"
    fossil addremove
    fossil commit --no-warnings -m "initial commit"
fi

counter=0
changed=0
changedtime=""

while true; do
    inotifywait --exclude "(_FOSSIL_|.fslckout|$FOSSILREPO.*)" -r -e close_write -e delete -e move -t 1 -q .
    exit_status=$?
    if [ $exit_status -eq 0 ]; then
        changed=1
        changedtime="$(date "$DATEFORMAT" | tee /dev/tty)"
        counter=0
        continue
    elif [ $exit_status -eq 1 ]; then
        continue
    elif [ $exit_status -eq 2 ]; then
        counter=$((counter+1))
    fi
    if [ $changed -eq 1 ] && [ $counter -gt $WAITSEC ]; then
        counter=0
        changed=0
        msg="$changedtime $(fossil addremove | tee /dev/tty | head -n 1)"
        fossil commit --no-warnings --allow-fork -m "$msg"
    fi
done
