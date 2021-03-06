import argparse
parser = argparse.ArgumentParser(prog='get_ld_radius.py', description='''
    This script takes an HDF5 file generated by ldpred/coord_genotypes.py and
    outputs the ld-radius (average number of SNPs per [x]Mb)
''')
parser.add_argument('--input', help = 'input HDF5 file')
parser.add_argument('--output', help = 'output ld-radius in YAML format')
parser.add_argument('--per_x_mb', type = float, default = 1, help = 'count the average number of SNPs per [x] Mb')
args = parser.parse_args()

import h5py, yaml

coord = h5py.File(args.input, 'r')
sum_stats = coord['sum_stats']
nsnp = 0
length = 0
# print(sum_stats.keys())
for i in list(sum_stats.keys()):
    pos = sum_stats[i]['positions'][:]
    # print(pos)
    length += max(pos) - min(pos)
    nsnp += pos.size
radius = nsnp / length * 1e6 * args.per_x_mb
coord.close()
with open(args.output, 'w') as out:
    yaml.dump({'ld-radius' : float(radius)}, out, default_flow_style = False)
