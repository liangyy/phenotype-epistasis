usage="$(basename "$0") [-h] [-i input BIM file] [-e input BED file] [-f input FAM file] [-p phenotype] [-o output FAM filename]
  This script takes matched BIM, BED, FAM files in plink format and outputs the corresponding plink binary files with changed family and individual IDs
where:
    -h  show this help text
    -i  input plink BIM file
    -e  input plink BED file
    -f  input plink FAM file
    -p  phenotype label (unaffected: 1; affected: 2)
    -o  output plink FAM filename"
while getopts ':ho:i:p:e:f:' option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    i) bim=$OPTARG
       ;;
    f) fam=$OPTARG
       ;;
    e) bed=$OPTARG
       ;;
    o) output=$OPTARG
       ;;
    p) pheno=$OPTARG
       ;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
   \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done
if [ "$pheno" = "1" ]; then
  name='control'
else
  name='case'
fi
awk -v l=$name '{print $1,$2,l$1,l$2}' $fam > $output.update-list.temp
plink --noweb --bim $bim --bed $bed --fam $fam --update-ids $output.update-list.temp --make-bed --out $output
rm $output.update-list.temp
