#!/usr/bin/env python
# -*- coding: utf-8 -*-

from sys import argv, stderr
from PIL import Image

#~ _THRESHOLD = 640 * 800
_THRESHOLD = 480 * 600

for image_file in argv[1:]:
    try:
        im = Image.open(image_file)
        w,h = im.size
        size = w * h
        too_small = (size < _THRESHOLD)
        print "%s\t%s\t%d\t%dx%d" % (image_file, str(too_small), size, w, h)

    except Exception as e:
        stderr.write('>>>%s\n' % str(e))
else:
    pass
