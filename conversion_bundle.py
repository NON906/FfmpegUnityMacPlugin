#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import shutil
import argparse

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('input')
    parser.add_argument('-o', '--output', default='./FfmpegUnityMacPlugin.bundle')
    args = parser.parse_args()

    os.makedirs(args.output + '/Contents')

    shutil.copytree(args.input + '/Contents/_CodeSignature', args.output + '/Contents/_CodeSignature')
    shutil.copy2(args.input + '/Contents/Info.plist', args.output + '/Contents/Info.plist')
    shutil.copytree(args.input + '/Contents/MacOS', args.output + '/Contents/MacOS')

    os.makedirs(args.output + '/Contents/Frameworks')

    dirs = os.listdir(args.input + '/Contents/Frameworks')
    for dir_path in dirs:
        os.makedirs(args.output + '/Contents/Frameworks/' + dir_path)
        shutil.copy2(args.input + '/Contents/Frameworks/' + dir_path + '/Versions/A/' + os.path.splitext(dir_path)[0], args.output + '/Contents/Frameworks/' + dir_path)
        shutil.copytree(args.input + '/Contents/Frameworks/' + dir_path + '/Versions/A/Resources', args.output + '/Contents/Frameworks/' + dir_path + '/Resources')
