#!/bin/bash
tmpf=$(mktemp)
fossil test-delta-create "$1" "$2" - | gzip -9 > "$tmpf"
(sha1sum < "$tmpf" | awk '{print $1}'; base64 "$tmpf") | awk 'BEGIN {FS="";RS="\n"} {
ln=""; last=""; lcount=1;
for(i = 1; i <= NF; i++) {
  if ($i == last && lcount < 10) {
    lcount++;
  } else {
    if (last == "\\") {ln=ln "\\\\"} else {ln=ln last};
    if (lcount > 1) ln=ln"\\"(lcount-1);
    last=$i;
    lcount=1;
  }
}
if (last == "\\") {ln=ln "\\\\"} else {ln=ln last};
if (lcount > 1) ln=ln"\\"(lcount-1);
print ln;
}'
rm "$tmpf"
