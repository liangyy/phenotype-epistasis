import argparse
parser = argparse.ArgumentParser(prog='format_beta.py', description='''
    This script takes a summary statistic file of beta and outputs the formatted
    ss file ready for ldpred
''')
parser.add_argument('--input', help = 'input GZ file (--sep delimited)')
parser.add_argument('--output', help = 'output GZ file (TAB delimited)')
parser.add_argument('--header', type = int, default = 0, help = 'if the input file contains header, set it to 1')
parser.add_argument('--sep', type = str, help = 'the delimiter of the input file')
parser.add_argument('--col_index', help = '''
    columns indices (1-based) of input column in order:
    chr,pos,ref,alt,reffrq,info,rs,pval,effalt,n
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

col_indices_ori = args.col_index.split(',')
col_indices = [ abs(int(i)) - 1 for i in col_indices_ori ]
col_names = [ 'chr', 'pos', 'ref', 'alt', 'reffrq', 'info', 'rs', 'pval', 'effalt', 'n' ]

beta = pd.read_table(args.input, sep = args.sep, header = None, skiprows = header, compression = 'gzip')  # , dtype = {'pos': int, 'reffrq': float}, skiprows = header, compression = 'gzip', usecols = col_indices, names = col_names)

data_dic = {}
for i in range(len(col_indices)):
    coln = col_indices[i]
    name = col_names[i]
    data_dic[name] = beta[coln] 
out_table = pd.DataFrame(data_dic)

if int(col_indices_ori[4]) < 0:  # flip allele frequency
    out_table['reffrq'] = 1 - out_table['reffrq']

out_table[col_names].to_csv(args.output, sep = '\t', header = True, index = False, compression = 'gzip')
