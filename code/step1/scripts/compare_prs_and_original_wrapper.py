import argparse
parser = argparse.ArgumentParser(prog='compare_prs_and_original_wrapper.py', description='''
    This script is a wrapper for merging PRS output from LDpred with the original summary statistic results
''')
parser.add_argument('--inputs', nargs = '+', help = 'list all files that would like to process')
parser.add_argument('--summary_statistic', help = 'summary statistic file which contains original effect size')
parser.add_argument('--fraction', help = 'the identifier of the inputs (separated by `,`) in order (it will be shown in the output)')
parser.add_argument('--out_prefix', help = 'the prefix of the output files')
args = parser.parse_args()

import os

ps = args.fraction.split(',')
for i in range(len(args.inputs)):
    cmd = '''
    awk 'NR==FNR'{{a[$]}}

    'NR==FNR{a[$7]=$8"\t"$9"\t"$10;b[$1]="0.1\t"$3"\t"$2;next}{print a[$1],$3,$2,b[$1]}' OFS="\t" FS='\t' <(zcat < $input) FS=' ' <(zcat < $geno) > $output.temp
