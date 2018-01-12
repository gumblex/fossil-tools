#!/bin/bash
tmpf=$(mktemp)
fossil test-delta-create "$1" "$2" - | gzip -9 > "$tmpf"
(sha1sum < "$tmpf" | awk '{print $1}'; base64 "$tmpf") | awk 'BEGIN {FS="";RS="\n"} {
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
rm "$tmpf"
