#!/bin/bash

overwrite=0
if [[ "$1" == "-o" ]]; then
    overwrite=1
    shift
fi

readonly=0
if [[ "$1" == "-r" ]]; then
    readonly=1
    shift
fi

glob="*.[jp][pn]g"
if [[ ! -z "$1" ]]; then
    glob="$1"
fi

function pause() {
    local _char
    read -t$1 -N1 -p"$2" _char
    [[ "$_char" == "q" ]] && return 1
    return 0
}

function rename_if_needed() {
    local _source="$1"
    local _target="$2"

    if [[ "$_source" == "$_target" ]]; then
        return 0
    fi

    echo -n "$_source => $_target... "
    if [[ -f "$_target" ]]; then
        if [[ $overwrite -eq 1 ]]; then
            echo -ne "\b\b\b\b (overwrite)... "
        else
            echo "NAME ALREADY EXISTS!  "
            return 1
        fi
    fi

    if [[ $readonly -eq 0 ]]; then
        mv "$_source" "$_target" && echo "OK"
    else
        echo "OK"
    fi
}

function process() {
    local _filename="$1"
#cho -e "(process)_filename:\t$_filename"
    local _hash=`md5sum "$_filename" | sed \
            -e 's/[a-f]*\([0-9]\+\)[a-f]*/\1/g' \
            -e 's/^[0-9]*\([0-9]\{6\}\) .*$/\1/'`

    local _suffix=${_hash}

    local _newname=`sed -e "s/^\(.\+\)-\(.\+\)\.\([^.]\+\)$/\1-$_suffix.\3/" <<< "$_filename"`

    rename_if_needed "$_filename" "$_newname"
}

function rename_files() {
    local _glob
    local _filename
    local i=0
    for _glob in "$@"; do
#cho -e "_glob:\t$_glob"
        find . -maxdepth 1 -type f -name "$_glob"|while read _filename; do
#cho -e "_filename:\t$_filename"
            process "$_filename" &

            let i=i+1
            [[ $((i % 6)) -eq 0 ]] && wait
        done
        wait
    done
}

while true; do
    find . -maxdepth 1 -type f -name "${glob}" -print0 | xargs -r -0 stat -t > .new.stat

    run=0
    if [[ -f .old.stat ]]; then
        pause 30 "." || break
        diff -q .new.stat .old.stat > /dev/null && continue
    fi

    if [[ $# -gt 0 ]]; then
        rename_files "$@"
    else
        rename_files "*-*.*"
    fi

    mv .new.stat .old.stat
done

find . -maxdepth 1 -type f -name ".*.stat" -delete
