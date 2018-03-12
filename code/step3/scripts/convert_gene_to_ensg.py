import argparse
parser = argparse.ArgumentParser(prog='convert_gene_to_ensg.py', description='''
    The script takes a set of human readable gene name and output the corresponding ENSGXXXX code used in GENCODE and PrediXcan.
    The scripts prints the output in the following format (each row) is
    gene_name[TAB]ensg_id[\n]
''')
parser.add_argument('--genes', help = 'separate genes by `,`, i.e. GENE1,GENE2,...')
parser.add_argument('--gencode', help = 'gencode annotation file for mapping gene name with ENSG code')
args = parser.parse_args()

import subprocess

genes = args.genes.split(',')
for g in genes:
    cmd = "zcat {gencode} |grep {gene}|sed -n 's/.*gene_id \"\(ENSG[0-9.]*\)\";.*$/\1/p' | sort | uniq ".format(
        gencode = args.gencode,
        gene = g)
    ensg = subprocess.check_output([cmd], shell=True).decode().strip().split('\n')
    if ensg[0] == '':
        ensgid = ['NA']
    else:
        ensgid = ensg
    for i in ensgid:
        print('{gene}\t{i}'.format(gene = g, ensgid = i))
