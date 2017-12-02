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


def compare(img1, img2):
    return 1 - ssim(img1, img2, data_range=img2.max() - img2.min())


def main(file1):
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

    all_images = (img for img
                  in sorted(glob('*.[JjPp][PpNn][Gg]'))
                  if img != file1)

    for file2 in all_images:
        if not (path.exists(file1) and path.exists(file2)):
            continue

        prnt_stderr('.')

        try:
            img2 = read_image(file2)
            n_0 = compare(img1, img2)
        except:
            prnt_stderr('!')
            continue

        img_map[file2] = n_0

    prnt_stderr('\n')

    top_scores = list(sorted(img_map.items(), key=operator.itemgetter(1)))[:10]
    for (key, value) in top_scores:
        print '\t%-4.2f\t%s:' % (value, key)

if __name__ == '__main__':
    if len(sys.argv) >= 2:
        for arg in sys.argv[1:]:
            main(arg)
            print ''
        exit(0)

    prnt_stderr('%s <file1> [<file2>...]' % sys.argv[0])
