import argparse
parser = argparse.ArgumentParser(prog='format_beta.py', description='''
    This script takes a summary statistic file of beta and outputs the formatted
    ss file ready for ldpred
''')
parser.add_argument('--input', help = 'input GZ file (TAB delimited)')
parser.add_argument('--output', help = 'output GZ file (TAB delimited)')
parser.add_argument('--header', type = int, default = 0, help = 'if the input file contains header, set it to 1')
parser.add_argument('--col_index', help = '''
    columns indices (1-based) of input column in order:
    chr,pos,ref,alt,reffrq,info,rs,pval,effalt
''')
args = parser.parse_args()

import pandas as pd
import sys

if args.header == 0:
    header = 0
elif args.header == 1:
    header = 1
else:
    sys.exit('Wrong --header {h}. Please use 0 or 1'.format(h = args.header))

col_indices = args.col_index.split(',')
col_indices = [ int(i) - 1 for i in col_indices ]
col_names = [ 'chr', 'pos', 'ref', 'alt', 'reffrq', 'info', 'rs', 'pval', 'effalt' ]

beta = pd.read_table(args.input, sep = '\t', header = None, skiprows = header, compression = 'gzip', usecols = col_indices, names = col_names)
beta.to_csv(args.output, sep = '\t', header = True, index = False, compression = 'gzip')
