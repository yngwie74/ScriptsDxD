#!/bin/bash
_DUPS_FILE="_dups.txt"

_home="`dirname "$0"`"

python "${_home}/compare_img.py" $* | sed \
	-e 's/^.*-\([0-9]\+\).*-\([0-9]\+\).*$/\1\t\2/' \
	-e '/^\([0-9]\+\)\t\1$/d' | sort | uniq | tee ${_DUPS_FILE}
