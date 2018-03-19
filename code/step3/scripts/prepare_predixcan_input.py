import argparse
parser = argparse.ArgumentParser(prog='prepare_predixcan_input.py', description='''
    This script takes recodeA file and freq file from plink and outputs dosage file for PrediXcan by chromosome. The format is
    chromosome rsid position allele1 allele2 MAF_A2F id1 id2 ... idn

    CAUTION: Dosage for each person refers to the number of alleles for the 2nd allele listed (between 0 and 2)
''')
parser.add_argument('--input_raw', help = 'output RAW file from plink --recodeA option')
parser.add_argument('--input_freq', help = 'output FRQ file from plink --freq option')
parser.add_argument('--output', help = 'name of output dosage file')
parser.add_argument('--output_sample', help = 'the FID and IID of individuals')
args = parser.parse_args()

import pandas as pd
import gzip

def if_valid(x):
    complement = {'A': 'T', 'T': 'A', 'G': 'C', 'C': 'G'}
    if x[0] == 'N' or x[1] == 'N':
        return False
    if x[0] == complement[x[1]]:
        return False
    return True

def join_id_and_a1(x):
    return '_'.join(x)

def write_row(row, handle):
    row[0] = 'chr' + str(row[0])
    row[2] = int(row[2])
    handle.write('\t'.join([ str(i) for i in row ]) + '\n')

print('start to read raw file')
raw = pd.read_table(args.input_raw, sep = ' ', header = 0)
print('start to read frequency file')
frq = pd.read_table(args.input_freq, sep = '\s+', header = 0)
print('read files finished')
chrm = list(frq['CHR'])[0]
# chrms = set(frq['CHR'])
# for chrm in chrms:
print('working with chromosome ' + str(chrm))
subset_frq = frq.loc[frq.CHR == chrm]
valid_ind = frq[['A1', 'A2']].apply(if_valid, axis = 1)
valid_subset_frq = subset_frq.loc[valid_ind]
snp_name = valid_subset_frq[['SNP', 'A1']].apply(join_id_and_a1, axis = 1)
subset_raw = raw[snp_name]
new = subset_raw.transpose()
idv_col = [ 'idv' + str(i) for i in new.columns.values ]
new.columns = idv_col
new = new.assign(chromosome = valid_subset_frq['CHR'].values)
new = new.assign(rsid = valid_subset_frq['SNP'].values)
new = new.assign(allele1 = valid_subset_frq['A2'].values)
new = new.assign(allele2 = valid_subset_frq['A1'].values)
new = new.assign(MAF = valid_subset_frq['MAF'].values)
new = new.assign(position = valid_subset_frq['POS'].values)
col_order = ['chromosome', 'rsid', 'position', 'allele1', 'allele2', 'MAF'] + idv_col
new = new[col_order]
# output_name = '{pre}{chrm}.{suf}'.format(pre = args.output_prefix, chrm = chrm, suf = args.output_suffix)
o_handle = gzip.open(args.output, 'wt')
print('start to write result on chromosome ' + str(chrm))
new.apply(lambda x: write_row(x, o_handle), axis=1)
o_handle.close()
# new.to_csv(args.output, sep = '\t', compression = 'gzip', header = False, index = False)
