#!/bin/bash
find . -type f -iname "*.[pj][np]g" -print0 | \
    xargs -0 md5sum | \
    tee md5sums.txt | \
    cut -d ' ' -f1 | \
    sort | uniq -c | \
    sed -e '/ 1 /d' -e 's/^ *[0-9]\+ \+\([0-9a-f]\+\).*$/\1/' | \
    grep -f - md5sums.txt | \
    sort