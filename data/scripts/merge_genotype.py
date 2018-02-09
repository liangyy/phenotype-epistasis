import argparse
parser = argparse.ArgumentParser(prog='merge_genotype.py', description='''
    This script takes two BIMBAM mean genotype files (matched SNP per row, two non-overlapped opulations) and output the merged file
''')
parser.add_argument('--geno1', help = 'first genotype file in GZ')
parser.add_argument('--geno2', help = 'second genotype file in GZ')
parser.add_argument('--output', help = 'output file name')
args = parser.parse_args()

import pandas as pd
import sys, gzip

rs_dic = {}
with gzip.open(args.geno2, 'rt') as f:
    for i in f:
        info = i.strip()
        info = info.split(' ')
        rs_dic[info[0]] = ' '.join(info[3:])
o = gzip.open(args.output, 'wt')
with gzip.open(args.geno1, 'rt') as f:
    for i in f:
        info = i.strip()
        info_s = i.split(' ')
        o.write(info + ' ' + rs_dic[info_s[0]] + '\n')
o.close()
