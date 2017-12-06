#!/bin/bash

if [[ $# -eq 0 ]]; then
    echo "$0 <girl name>"
    exit 1
fi

find . -maxdepth 1 -type f -name "*${1}*.??g" | sort > _list_
rar a -k -t "${1}.cbr" @_list_
if [[ $? -eq 0 ]]; then
    rm _list_
    find . -maxdepth 1 -type f -name "${1}-*.??g" -delete
fi
