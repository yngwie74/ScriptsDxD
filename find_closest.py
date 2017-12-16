#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import operator
import re
from glob import glob
from os import path

from skimage.measure import compare_ssim as ssim
from scipy.misc import imread, imresize
from scipy import average

_TARGET_SIZE = [160, 200]  # [640, 800]
_THRESHOLD = 0.50


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
    # read images as 2D arrays (convert to grayscale for simplicity)
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


def main(file1, others):
    if not path.exists(file1):
        prnt_stderr("%r no existe!\n" % file1)
        exit(2)

    try:
        img1 = read_image(file1)
    except:
        prnt_stderr('No se pudo leer %r!' % file1)
        exit(3)

    prnt_stderr(file1)

    img_map = dict()

    all_images = (img for img in others if not are_versions_of_same(img, file1))

    for file2 in all_images:
        if not (path.exists(file1) and path.exists(file2)):
            continue

        prnt_stderr('.')

        try:
            img2 = read_image(file2)
            n_0 = 1.0 - compare(img1, img2)
        except:
            prnt_stderr('!')
            continue

        img_map[file2] = n_0

    prnt_stderr('\n')

    top_scores = list((key, value)
        for (key, value) in reversed(sorted(img_map.items(), key=operator.itemgetter(1)))
        if value >= _THRESHOLD)[:10]

    for (key, value) in top_scores:
        print '\t%-4.2f\t%s:' % (value, key)

if __name__ == '__main__':
    if len(sys.argv) <= 1:
        prnt_stderr('%s <file1> [<file2>...]' % sys.argv[0])
        exit(1)

    args = sys.argv[1:]
    if ('--among' in args):
        pos = args.index('--among')
        others = args[pos:]
        args = args[0:pos]
    else:
        others = sorted(glob('*.[JjPp][PpNn][Gg]'))

    for arg in args:
        main(arg, others)
        print ''
