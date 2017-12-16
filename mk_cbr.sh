#!/bin/bash

if [[ "$1" = "-i" ]]; then
    _inclusive_mode="true"
    shift
fi

if [[ $# -eq 0 ]]; then
    echo "$0 [-i] <girl name>"
    exit 1
fi

# assume "inclusive mode"
_fspec="*${1}*.??g"
if [[ -z ${_inclusive_mode} ]]; then
    _fspec="${1}-*.??g"
fi

find . -maxdepth 1 -type f -name "${_fspec}" | sort > _list_
rar a -k -t "${1}.cbr" @_list_
if [[ $? -eq 0 ]]; then
    rm _list_
    find . -maxdepth 1 -type f -name "${1}-*.??g" -delete
fi
