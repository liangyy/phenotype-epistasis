import argparse
parser = argparse.ArgumentParser(prog='plink_merge_wrapper.py', description='''
    This script is a wrapper for plink --bmerge. It will catch the error caused by unmatched SNPs between two inputs.
    Specifically, it will ignore all unmatched SNPs.
''')
parser.add_argument('--bim1', help = 'BIM file to merge (the main)')
parser.add_argument('--bed1', help = 'BED file to merge (the main)')
parser.add_argument('--fam1', help = 'FAM file to merge (the main)')
parser.add_argument('--merge_list', help = 'the list of file to merge into the main')
parser.add_argument('--out_prefix', help = 'output prefix in plink')
args = parser.parse_args()

'''
plink --noweb --bim {input.bim1} --bed {input.bed1} --fam {input.fam1} --merge-list {input.mlist} --make-bed --out {params.out}
'''


import subprocess, os


cmd = 'plink --noweb \
                --bim {bim1} \
                --bed {bed1} \
                --fam {fam1} \
                --merge-list {mlist} \
                --make-bed \
                --out {out}'.format(bim1 = args.bim1, bed1 = args.bed1, fam1 = args.fam1, mlist = args.merge_list, out = args.out_prefix)

print('=============== PLINK wrapper START ================')
print('Do:')
print(cmd)
try:
    subprocess.call([cmd])
except OSError:
    print ('There are mismatched SNPs')
    missnp = '{prefix}.missnp'.format(prefix = args.out_prefix)

    clean_up_cmd = 'mv {missnp} temp.{missnp}; rm {prefix}*'.format(missnp = missnp, prefix = args.out_prefix)
    print('Grabbing missnp list and cleaning up failure')
    print(clean_up_cmd)
    os.sysmte(clean_up_cmd)
    missnp = 'temp.' + missnp

    merge2 = {}
    with open(args.merge_list, 'r') as f:
        for i in f:
            i = i.strip()
            filename, file_extension = os.path.splitext(i)
            merge2[file_extension] = i

    cmd1 = 'plink --noweb \
                    --bim {bim1} \
                    --bed {bed1} \
                    --fam {fam1} \
                    --exclude {missnp} \
                    --make-bed \
                    --out {out}_tmp1'.format(bim1 = args.bim1, bed1 = args.bed1, fam1 = args.fam1, missnp = missnp, out = args.out_prefix)
    print('Cleaning up set1:')
    print(cmd1)
    os.system(cmd1)

    cmd2 = 'plink --noweb \
                    --bim {bim1} \
                    --bed {bed1} \
                    --fam {fam1} \
                    --exclude {missnp} \
                    --make-bed \
                    --out {out}_tmp2'.format(bim1 = merge2['bim'], bed1 = merge2['bed'], fam1 = merge2['fam'], missnp = missnp, out = args.out_prefix)
    print('Cleaning up set2:')
    print(cmd2)
    os.system(cmd2)

    cmd3 = 'plink --bfile {out}_tmp1 --bmerge {out}_tmp2 --make-bed --out {out}'.format(out = args.out_prefix)
    print('Final merging:')
    print(cmd3)
    os.system(cmd3)

    clean_up_final_cmd = 'rm {out}_tmp1.*; rm {out}_tmp2.*'.format(out = args.out_prefix)
    print('Cleaning up temp files:')
    os.sysmte(clean_up_final_cmd)
print('=============== PLINK wrapper FINISH ===============')
