#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import operator
import re
from glob import glob
from os import path
from itertools import islice

from skimage.measure import compare_ssim as ssim
from scipy.misc import imread, imresize
from scipy import average

_TARGET_SIZE = [160, 200]  # [640, 800]
_DEFAULT_THRESHOLD = 0.63


def prnt_stderr(s):
    sys.stderr.write(s)
    sys.stderr.flush()


def to_grayscale(arr):
    '''If arr is a color image (3D array), convert it to grayscale (2D array.)'''

    if len(arr.shape) == 3:
        return average(arr, -1)  # average over the last axis (color channels)
    else:
        return arr


def read_image(filename):
    '''Read images as 2D arrays (convert to grayscale for simplicity)'''
    return imresize(to_grayscale(imread(filename).astype('float32')), _TARGET_SIZE,
                    interp='bicubic', mode='F')


def are_versions_of_same(file1, file2):
    if file1 == file2:
        return True
    no_ext = lambda fname: path.splitext(fname)[0]
    clean_it = lambda fname: re.sub('v\\d+$', '.', no_ext(fname))
    return clean_it(file1) == clean_it(file2)


def compare(img1, img2):
    return 1 - ssim(img1, img2, data_range=img2.max() - img2.min())


def get_top_scores(score_dict, threshold, max_count):
    sorted_by_value = sorted(score_dict.iteritems(), key=operator.itemgetter(1))
    higher_to_lower = reversed(sorted_by_value)
    filtered = ((key, value) for (key, value) in higher_to_lower if value >= threshold)
    return list(islice(filtered, 0, max_count))


def main(file1, others, threshold):
    if not path.exists(file1):
        prnt_stderr('%r no existe!\n' % file1)
        exit(2)

    try:
        img1 = read_image(file1)
    except:
        prnt_stderr('No se pudo leer %r!' % file1)
        exit(3)

    prnt_stderr(file1)

    img_map = dict()

    all_images = (img for img in others if not are_versions_of_same(img, file1))

    for file2 in filter(lambda x: path.exists(file1) and path.exists(x), all_images):
        prnt_stderr('.')
        try:
            img2 = read_image(file2)
            n_0 = 1.0 - compare(img1, img2)
            img_map[file2] = n_0
        except:
            prnt_stderr('!')

    prnt_stderr('\n')

    for (key, value) in get_top_scores(img_map, threshold, max_count=10):
        print '\t%-4.2f\t%s:' % (value, key)


def without(seq, item):
    return (curr for curr in seq if curr != item)


def index_if(alist, pred):
    gen = (i for i in xrange(0, len(alist)) if pred(alist[i]))
    return next(gen, -1)


def parse_args(argv):
    (myproc, argv) = (argv[0], argv[1:])
    if len(argv) < 1:
        prnt_stderr('%s [-t:<threshold>] <file1> [<file2>...] [--among [<filen>...]]' % myproc)
        exit(1)

    threshold = _DEFAULT_THRESHOLD

    pos = index_if(argv, lambda x: x.startswith('-t:'))
    if pos >= 0:
        threshold = float((argv[pos])[3:].strip())
        del argv[pos]

    if '--among' in argv:
        pos = argv.index('--among')
        del argv[pos]
        others = argv[pos:]
        argv = argv[0:pos]
    else:
        others = glob('*.[JjPp][PpNn][Gg]')

    return dict(threshold=threshold, files_to_process=argv, search_set=sorted(others))


if __name__ == '__main__':
    args = parse_args(sys.argv[:])
    for current in args['files_to_process']:
        main(current, without(args['search_set'], current), args['threshold'])
        print ''
