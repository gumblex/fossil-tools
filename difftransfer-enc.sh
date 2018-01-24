#!/bin/bash
tmpf=$(mktemp)
orig=$(mktemp)
cat "$1" > "$orig"
fossil test-delta-create "$orig" "$2" "$tmpf"
zopfli --gzip "$tmpf"
mv "$tmpf".gz "$tmpf"
(sha1sum "$2" | awk '{print $1}'; base64 "$tmpf") | awk 'BEGIN {FS="";RS="\n"} {
ln=""; last=""; lstcnt="."; lcount=0;
for(i = 1; i <= NF; i++) {
  if ($i == last && lcount < 9) {
    lcount++;
  } else {
    if (lstcnt == last) {ln=ln "\\."}
    lstcnt="";
    if (last == "\\") {ln=ln "\\0"; lstcnt="0";} else {ln=ln last}
    if (lcount > 0) {ln=ln"\\"lcount; lstcnt=lcount}
    last=$i; lcount=0;
  }
}
if (lstcnt == last) {ln=ln "\\."}
if (last == "\\") {ln=ln "\\0"} else {ln=ln last};
if (lcount > 0) ln=ln"\\"lcount;
print ln;
}'
rm "$tmpf" "$orig"
