#/bin/csh -f

expand $1 | \
perl -pe 's/^.*        /ASM%/g' | grep '^ASM%' | \
perl -pe 's/^ASM%//g; s/[\t ]+/ /g; s/ $//g; s/\br\d\b/R/g; s/\[R[^\]]+\]/[R]/g; s/\[_[^\]]+\]/[I]/g; s/\bL\$\d+/L/g; s/\b_\w+\b/I/g; s/-?\d+\b/I/g; s/\brr\b/R/g; s/\$/I/g;s/^j[^m]\w*/jcc/g'	| \
sort | uniq -c | sort -r > ${1}.stat
