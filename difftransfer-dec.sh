#!/bin/bash
tmpf1=$(mktemp); tmpf=$(mktemp)
awk 'BEGIN {FS=""} {ln=""; last=""; esc=0; for(i = 1; i <= NF; i++) {
if (!esc && $i != "\\") {last=$i; ln=ln $i;} else if (esc && $i == "0")
{last="\\"; ln=ln "\\";} else if (!esc) {esc = 1; continue;} else {j = int($i);
while (j-->0) {ln=ln last;}} esc = 0;} print ln;}' > "$tmpf1"
shasum=$(head -n1 "$tmpf1")
if [ -z "$VAR" ]; then
  echo 'empty input'
  rm "$tmpf1" "$tmpf"
  exit 1
fi
tail -n +2 "$tmpf1" | base64 -d > "$tmpf"
cat "$1" > "$2.orig"
gzip -dc "$tmpf" | fossil test-delta-apply "$2.orig" - "$2"
if [ "$shasum" != $(sha1sum "$2" | awk '{print $1}') ]; then
  echo 'bad input'
  rm -f "$tmpf1" "$tmpf" "$2.orig" "$2"
  exit 1
fi
rm "$tmpf1" "$tmpf" "$2.orig"
