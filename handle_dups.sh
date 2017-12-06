#!/bin/bash

function tabs_to_lines() {
    sed 's/\t/\n/g'
}

function exists_any() {
    local glob="$1"
    local found=0
    local f
    for f in $glob; do
        if [[ -f "$f" ]]; then
            found=1
            break
        fi
    done
    [[ found -eq 0 ]] && return 1 || return 0
}

reps=`cut -f1 _comps.txt | sort | uniq -c | sort -nr | head -n1 | sed 's/^ \+//'`

max_reps=`cut -d' ' -f1 <<< $reps`
top_id=`cut -d' ' -f2 <<< $reps`

if [[ $max_reps -lt 1 ]]; then
    echo No se encontraron mas IDs repetidos
    exit 0
fi

grep $top_id _comps.txt | tabs_to_lines | sort -u | grep -f - _comps.txt | tabs_to_lines | sort -u > _repeated_

grep -v -f _repeated_ _comps.txt > _sans_repeated_
mv _sans_repeated_ _comps.txt

unix2dos _comps.txt 2> /dev/null

_base="0"
_all_versioned=1

for i in `cat _repeated_`; do
    if [[ "0" = "${_base}" ]]; then
        echo "base = ${i}"
        _base=${i}
        continue
    fi
    for f in *${i}*; do
        [[ -f "$f" ]] || continue

        grep -q -vE 'v[0-9]\.' <<< "$f" && _all_versioned=0

        n="${f/-/-${_base}.}"
        if [[ "$f" != "$n" ]]; then
            echo "mv $f => $n"
            mv "$f" "$n"
        fi
    done
done

if ! exists_any "*-${base}.??g" && [[ 1 -eq $_all_versioned ]]; then
    echo "All files versioned. Reverting renames:"
    for f in *-${_base}.??????*; do
        [[ -f "$f" ]] || continue
        n="${f/-${_base}./-}"
        if [[ "$f" != "$n" ]]; then
            echo "mv $f => $n"; 
            mv "$f" "$n"
        fi
    done
    echo "done."
fi

rm _repeated_
