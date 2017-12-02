#!/bin/bash

# <a id="next" onclick="return load_image(3, '982cee9466')" href="https://e-hentai.org/s/982cee9466/1094044-3">

pageurl="https://e-hentai.org/s/df81abbec9/1094044-192"
pageno=191

while [[ ! -z $pageurl ]]; do
	echo -n "$pageno"
	curl -s -o".tmp.htm" "$pageurl"
	imgurl=`grep -Eo '<img id="img" src="[^"]+"' .tmp.htm | grep -Eo 'http://[^"]+'`
	# <img id="img" src="http://104.172.215.55:19371/h/a7b8ffefdea4ed0d78caf750fbba2b7efcf53aa8-69844-500-875-jpg/keystamp=1506931800-27b8b5cafc;fileindex=54059091;xres=org/17801a.jpg"

	imgname="`printf "%08d.jpg" $pageno`"
	[[ ! -f "$imgname" ]] && curl -s -o"$imgname" "$imgurl" &
	let pageno=pageno+1
	[[ $pageno -gt 1978 ]] && break
	
	[[ $((pageno % 6)) -eq 0 ]] && wait

	pageurl=`grep -Eo '<a id="next" onclick="[^"]+" href="[^"]+">' .tmp.htm | head -n1 | grep -Eo 'https://[^"]+'`
done
wait
