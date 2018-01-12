#!/bin/bash
tmpf1=$(mktemp); tmpf=$(mktemp)
awk 'BEGIN {FS=""} {ln=""; last=""; esc=0; for(i = 1; i <= NF; i++) {
if (!esc && $i != "\\") {last=$i; ln=ln $i;} else if (esc && $i == "0")
{last="\\"; ln=ln "\\";} else if (!esc) {esc = 1; continue;} else {j = int($i);
while (j-->0) {ln=ln last;}} esc = 0;} print ln;}' > "$tmpf1"
shasum=$(head -n1 "$tmpf1")
tail -n +2 "$tmpf1" | base64 -d > "$tmpf"
if [ "$shasum" != $(sha1sum "$tmpf" | awk '{print $1}') ]; then
  echo 'bad input'; exit 1
fi
cp "$1" "$2"
gzip -dc "$tmpf" | fossil test-delta-apply "$1" - "$2"
rm "$tmpf1" "$tmpf"
