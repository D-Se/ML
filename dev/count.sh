#!/usr/bin/bash sh
# count lines of code per contributor to github repo in main .rmd files
contr () {
  local perfile="false";
  if [[ $1 = "-f" ]]; then
  perfile="true";
  shift;
  fi;
  if [[ $# -eq 0 ]]; then
          echo "no files given!" 1>&2;
        return 1;
        else
          local f; {
            for f in "$@";
            do
            echo "$f";
            git blame --show-email "$f" |
              sed -nE 's/^[^ ]* *.<([^>]*)>.*$/: \1/p' |
              sort | uniq -c | sort -r -nk1;
            done
          } | if [[ "$perfile" = "true" ]]; then
        tee /tmp/s.txt;
        else
          tee /tmp/s.txt > /dev/null;
        fi;
        awk -v FS='*: *' '/^ *[0-9]/{sums[$2] += $1} END {
        for (i in sums) printf("%7s : %s\n", sums[i], i)
        }' /tmp/s.txt |
          sort -r -nk1;
        fi
}
find . -iname '*.Rmd' | while read file; do contr -f "$file"; done > dev/counts.txt
