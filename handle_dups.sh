#!/bin/bash

_DUPS_FILE="_dups.txt"

function tabs_to_lines() {
    sed 's/\t/\n/g'
}

function safe_mv() {
    if [[ "$1" != "$2" ]]; then
        echo "$1 => $2"; 
        mv "$1" "$2"
    fi
}

function safe_rm() {
    [[ -f "$1" ]] && rm "$1"
}

function exists_any() {
    local glob="$1"
    local lines=`find . -maxdepth 1 -type f -name "$glob" | wc -l`
    [[ $lines -eq 0 ]] && return 1 || return 0
}

reps=`cut -f1 ${_DUPS_FILE} | sort | uniq -c | sort -nr | head -n1 | sed 's/^ \+//'`

max_reps=`cut -d' ' -f1 <<< $reps`
top_id=`cut -d' ' -f2 <<< $reps`

if [[ $max_reps -lt 1 ]]; then
    echo No se encontraron mas IDs repetidos
    exit 0
fi

grep $top_id ${_DUPS_FILE} | tabs_to_lines | sort -u | grep -f - ${_DUPS_FILE} | tabs_to_lines | sort -u > _repeated_

grep -v -f _repeated_ ${_DUPS_FILE} > _sans_repeated_
mv _sans_repeated_ ${_DUPS_FILE}

#unix2dos ${_DUPS_FILE} 2> /dev/null

_base="0"
touch _all_have_ver_num_

for i in `cat _repeated_`; do
    if [[ "0" = "${_base}" ]]; then
        echo "base = ${i}"
        _base=${i}
        continue
    fi
    find . -maxdepth 1 -type f -iname "*${i}*.??g" -print | while IFS='' read -r f || [[ -n "$f" ]]; do
        [[ -f "$f" ]] || continue

        if grep -q -vE 'v[0-9]\.' <<< "$f"; then
            safe_rm _all_have_ver_num_
        fi

        n="${f/-/-${_base}.}"
        safe_mv "$f" "$n"
    done
done

if [[ -f _all_have_ver_num_ ]]; then
    echo "All files already versioned."
    if ! exists_any "*-${_base}.??g"; then
        echo "Reverting renames:"
        for f in *-${_base}.??????*; do
            [[ -f "$f" ]] || continue
            n="${f/-${_base}./-}"
            safe_mv "$f" "$n"
        done
        echo "done."
    fi
fi

safe_rm _repeated_
safe_rm _all_have_ver_num_
