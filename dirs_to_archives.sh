#!/bin/bash

for d in [A-Z]*; do
    [[ -d "$d" ]] || continue

    find . -type f \( -name "${d}-*.[pj][np]g" -or -name "*[+-]${d}-*.[pj][np]g" -or -name "${d}[+-]*.[pj][np]g" \) | sort | tee _list \
        && find "./$d/" -type f -iname "*.txt" >> _list \
        && ~/winrar/Rar a -ep -k -t "${d}.rar" @_list \
        && rm -Rf "$d"

    [[ -f _list ]] && rm _list
done
