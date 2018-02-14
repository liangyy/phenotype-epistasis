import argparse
parser = argparse.ArgumentParser(prog='interaction_by_set.py', description='''
    This script takes a collection of covariate files, a genotype file in PLINK format, and a subset file telling which SNPs are being tested. For each covariate, it calls plink to run GWAS (logistic regression) with the covariate
''')
parser.add_argument('--inputs', nargs = '+', help = 'a collection of covariates')
parser.add_argument('--outputs', nargs = '+', help = 'a collection of output file prefix in plink')
parser.add_argument('--geno_prefix', help = 'prefix of genotype file')
parser.add_argument('--set', help = 'set file for plink')
parser.add_argument('--pattern', help = 'pattern used to extract set name')
args = parser.parse_args()

import sys, os, re

def get_set_name(covname, parts):
    covname = os.path.basename(covname)
    for p in parts:
        covname = re.sub(p, '', covname)
    return covname

if len(args.inputs) != len(args.outputs):
    print('The number of input is different from the output. Exit!')
    sys.exit()

n = len(args.inputs)
parts = args.pattern.split(':')
for i in range(n):
    cov_i = args.inputs[i]
    out_i = args.outputs[i]
    setname_i = get_set_name(cov_i, parts)
    cmd = 'plink --noweb \
        --bed {geno}.bed \
        --bim {geno}.bim \
        --fam {geno}.fam \
        --allow-no-sex \
        --logistic \
        --covar {cov} \
        --covar-name PRS \
        --interaction \
        --set {setfile} \
        --subset <(echo "{setname}") \
        --out {out}'.format(geno = args.geno_prefix,
                            cov = cov_i,
                            out = out_i,
                            setfile = args.set,
                            setname = setname_i)
    print(cmd)
    os.system('CMD="{cmd}"; bash -c "$CMD"'.format(cmd = cmd))
