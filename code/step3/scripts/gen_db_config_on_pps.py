import argparse
parser = argparse.ArgumentParser(prog='gen_db_config_on_pps.py', description='''
    This script in written to generate proper format for PrediXcan databases on pps cluster
    The working dir should contain folders of PrediXcan databases in each sub dir
''')
parser.add_argument('--work_dir', help = 'the dir of database sib dirs. DO NOT use relative path!')
args = parser.parse_args()

import os, glob
from os.path import expanduser

wd = expanduser(args.work_dir)

e = glob.glob(wd +  '/*')
for i in e:
    if os.path.isdir(i):
        f = glob.glob(i + '/*')
        for d in f:
            if d.endswith('.db'):
                string = '{name}:\n  db: \'{path}\''.format(name = os.path.basename(i), path = d)
                print(string)
