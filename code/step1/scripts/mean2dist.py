import argparse
parser = argparse.ArgumentParser(prog='mean2dist.py', description='''
    Take a genotype mean file in BIMBAM format and output an imputed genotype distribution file where the posterior probability is either 0 or 1 and the closest genotype is set to one and others are set to zero. Also the alternative allele and reference allele are fliped.

    Note that fliped genotype dist format is
    [snp-id] [ref-allele] [alt-allele] [posterior-prob-of-ref-ref] [posterior-prob-of-ref-alt]
''')
parser.add_argument('--input', help = 'input genotype mean file in GZ format')
parser.add_argument('--output', help = 'file name of output genotype distribution file in GZ format')
args = parser.parse_args()

import sys
import pandas as pd
import numpy as np

geno = pd.read_table(args.input, sep = ' ', header = None, compression = 'gzip')
geno_info = geno.iloc[:, [0, 2, 1]]
geno_mean = geno.iloc[:, 3:]
(ns, ni) = geno_mean.shape
geno_dist = np.empty([ns, ni * 2])  # pd.DataFrame()
distance = 0
for i in range(ni): # iter over every individual
    # print(str(i) + '--a')
    geno_mean_i = round(geno_mean.iloc[:, i])
    # print(str(i) + '-a')
    distance += sum(abs(geno_mean_i - geno_mean.iloc[:, i]))
    # print(str(i) + 'a')
    geno_dist_i = pd.DataFrame(np.zeros((ns, 2)))
    # print(str(i) + 'b')
    geno_dist_i.ix[geno_mean_i == 0, 0] = 1
    # print(str(i) + 'c')
    geno_dist_i.ix[geno_mean_i == 1, 1] = 1
    # print(str(i) + 'd')
    geno_dist[:, i * 2 : i * 2 + 2] = geno_dist_i  # np.concatenate([geno_dist, geno_dist_i], axis = 1)
    # print(i)
# for i in range(ns):
    
geno_out = pd.concat([geno_info, pd.DataFrame(geno_dist)], axis = 1)
print('average distance between posterior mean genotype and integerized genotype is {avg_distance}'.format(avg_distance = distance / ns / ni), file=sys.stderr)

def print_row(row):
    print(' '.join([ str(i) for i in row ]))
geno_out.apply(print_row, axis=1)
# geno_out.to_csv(args.output, sep = ' ', header = False, index = False, compression = 'gzip', chunksize=100000)
