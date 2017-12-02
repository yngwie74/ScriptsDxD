#!/bin/bash

function tabs_to_lines() {
    sed 's/\t/\n/g'
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
for i in `cat _repeated_`; do
    if [[ "0" = $_base ]]; then
        echo "base = $i"
        _base=$i
        continue
    fi
    for f in *$i*; do
        [[ -f "$f" ]] || continue
        echo "mv $f => ${f/-/-${_base}.}"
        mv "$f" "${f/-/-${_base}.}"
    done
done

rm _repeated_
