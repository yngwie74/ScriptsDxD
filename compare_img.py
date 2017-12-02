#!/usr/bin/env python
# -*- coding: utf-8 -*-

import re
import sys

from glob import glob
from os import path
from repoze.lru import lru_cache
from scipy import average
from scipy.misc import imread, imresize
from skimage.measure import compare_ssim as ssim

_THRESHOLD = 0.33  # 0.1875
_TARGET_SIZE = [160, 200]  # [640, 800]


def prnt_stderr(s):
    sys.stderr.write(s)
    sys.stderr.flush()


def to_grayscale(arr):
    '''If arr is a color image (3D array), convert it to grayscale (2D array).'''

    if len(arr.shape) == 3:
        return average(arr, -1)  # average over the last axis (color channels)
    else:
        return arr


@lru_cache(53)
def read_image(filename):
    # read images as 2D arrays (convert to grayscale for simplicity)
    return imresize(to_grayscale(imread(filename).astype('float32')), _TARGET_SIZE,
                    interp='bicubic', mode='F')


def are_versions_of_same(file1, file2):
    no_ext = lambda fname: path.splitext(fname)[0]
    clean_it = lambda fname: re.sub('v\\d+$', '.', no_ext(fname))
    return clean_it(file1) == clean_it(file2)


def compare(img1, img2):
    # prnt_stderr('img2:%d' % len(img2))
    return 1 - ssim(img1, img2, data_range=img2.max() - img2.min())


def main():
    all_images = sorted(glob('*.[JjPp][PpNn][Gg]'))
    for file1 in all_images:
        if not path.exists(file1):
            continue

        prnt_stderr(file1)

        try:
            img1 = read_image(file1)
        except:
            prnt_stderr('!')
            continue

        for file2 in (img for img in all_images if img > file1):
            if not (path.exists(file1) and path.exists(file2)):
                continue

            if are_versions_of_same(file1, file2):
                continue

            try:
                img2 = read_image(file2)
                score = compare(img1, img2)
            except:
                prnt_stderr('!')
                continue

            prnt_stderr('.')

            if score < _THRESHOLD:
                print '%r\t=>\t%r' % (file1, file2)

        prnt_stderr('\n')


if __name__ == '__main__':
    if len(sys.argv) != 3:
        main()
    else:
        args = sys.argv[1:]
        images = map(read_image, args)
        print '%s/%s: %7.2f' % tuple(args + [compare(*images)])
