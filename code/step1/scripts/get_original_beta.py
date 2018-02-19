import argparse
parser = argparse.ArgumentParser(prog='get_original_beta.py', description='''
    This script is for merging PRS output from LDpred with the original summary statistic results.
    Note that a2 is baseline allele.
''')
parser.add_argument('--input', help = 'an output file of LDpred to denote which SNPs should be included')
parser.add_argument('--coordinate', help = 'HDF5 file output by coord_genotype.py in LDpred')
parser.add_argument('--out', help = 'the filename of the output in GZ format')
args = parser.parse_args()

import h5py, pandas
import numpy as np

def obtain_data(h5, sid):
    data = h5py.File(h5, 'r')
    ss = data['sum_stats']
    beta = {}
    odds = {}
    ref = {}
    alt = {}
    sid_o = {}
    l = 0
    for i in ss.keys():
        sid_i = np.char.decode(ss[i]['sids'][:])
        sid_in = np.isin(sid_i, sid[i])
        beta[i] = np.extract(sid_in, ss[i]['betas'][:])
        odds[i] = np.extract(sid_in, ss[i]['log_odds'][:])
        ref[i] = np.char.decode(np.extract(sid_in, ss[i]['nts'][:][:, 0]))
        alt[i] = np.char.decode(np.extract(sid_in, ss[i]['nts'][:][:, 1]))
        sid_o[i] = np.extract(sid_in, sid_i)
        l += odds[i].shape[0]
    return beta, odds, ref, alt, sid_o, l

def get_sids(filename):
    f = pandas.read_table(filename, header = 0, sep = '\s+')
    out_dic = {}
    for i in f['chrom'].unique():
        out_dic[i] = np.array(f[f['chrom'] == i]['sid'])
    return out_dic

sid_dic = get_sids(args.input)
betas, log_odds, refs, alts, sids_o, l = obtain_data(args.coordinate, sid_dic)
out = np.empty([l, 5], dtype = np.object)
l_now = 0
for i in betas.keys():
    out[l_now : l_now + len(sids_o[i]), 0] = sids_o[i]
    out[l_now : l_now + len(refs[i]), 1] = refs[i]
    out[l_now : l_now + len(alts[i]), 2] = alts[i]
    out[l_now : l_now + len(betas[i]), 3] = betas[i]
    out[l_now : l_now + len(log_odds[i]), 4] = log_odds[i]
    l_now += len(log_odds[i])
df = pandas.DataFrame(out, columns = ['sid', 'a1', 'a2', 'beta_ori', 'log_odds'])
df.to_csv(args.out, sep = '\t', header = True, index = False, compression = 'gzip')
