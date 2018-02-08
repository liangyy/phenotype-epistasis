import argparse
parser = argparse.ArgumentParser(prog='direction_xtyi.py', description='''
    This script takes a collection of covariate files and a genotype file in PLINK format.
    For each covariate, it calls plink to run GWAS (logistic regression) with the covariate
''')
parser.add_argument('--inputs', nargs = '+', help = 'a collection of covariates')
parser.add_argument('--outputs', nargs = '+', help = 'a collection of output file prefix in plink')
parser.add_argument('--geno_prefix', help = 'prefix of genotype file')
args = parser.parse_args()

import sys, os

if len(args.inputs) != len(args.outputs):
    print('The number of input is different from the output. Exit!')
    sys.exit()

n = len(args.inputs)
for i in range(n):
    cov_i = args.inputs[i]
    out_i = args.outputs[i]
    cmd = 'plink --noweb \
        --bed {geno}.bed \
        --bim {geno}.bim \
        --fam {geno}.fam \
        --allow-no-sex \
        --logistic \
        --covar {cov} \
        --out {out}'.format(geno = args.geno_prefix,
                            cov = cov_i,
                            out = out_i)
    os.system(cmd)
