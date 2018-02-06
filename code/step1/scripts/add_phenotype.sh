usage="$(basename "$0") [-h] [-i input FAM file] [-p phenotype] [-o output FAM filename]
  This script takes a plink FAM file and change the phenotype label (namely the last column of the file) to the value specified by user also the family ID and individual ID are changed accordingly
where:
    -h  show this help text
    -i  input plink FAM file
    -p  phenotype label (unaffected: 1; affected: 2)
    -o  output plink FAM filename"
while getopts ':ho:i:p:' option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    i) input=$OPTARG
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
awk -v l=$pheno '{print $1,$2,$3,$4,$5,l}' $input > $output
