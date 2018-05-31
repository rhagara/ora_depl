#!/usr/sunos/bin/ksh
#Purpose: array processing

set -A P3_MEJLS
set -A P3_FILENAMES
P3_CNT=0

tst()
{
P3_FILENAMES[2]="dva";
P3_FILENAMES[5]="pat";

for i in ${P3_FILENAMES[@]}; do
  echo $i
done

integer i=2

echo "${P3_FILENAMES[2]}"
echo "${P3_FILENAMES[$i]}"

integer i=1
echo ".${P3_FILENAMES[$i]}."
}

add()
{
local mejl="$1"
local names="$2"

integer i=0

#search array
while [[ $i < "$P3_CNT" ]]; do
   if [[ "${P3_MEJLS[$i]}" == "$mejl" ]]; then
      break
   fi
   let i="$i + 1" 
done

#new mejl
if [[ "${P3_MEJLS[$i]}" != "$mejl" ]]; then
  let P3_CNT="$P3_CNT+1"
  let i="$P3_CNT"
fi

P3_MEJLS[$i]="$mejl"
P3_FILENAMES[$i]="${P3_FILENAMES[$i]} $names"

echo "stored :: $i :: ${P3_MEJLS[$i]} || $names"
}

echo "................................"

echo "1.0"

add "a@b" "a b c d"
add "a@z" "a b"
add "a@b" "o p r s"
add "a@q" "q r"
add "a@b" "q r"

echo "2.0"

for a in "${P3_FILENAMES[@]}"; do
  echo "$a"
done

for a in "${P3_MEJLS[@]}"; do
  echo "$a"
done

exit;
