usage="$(basename "$0") [-h] [-i snp-info] [-g genotype-mean (no flip)] [-o output-name]
  Take SNP information file in the format:
  [snp-id]  [chr] [position]
  and output a SNP information file in BIMBAM format (FLIP alt and ref):
  ## af is the allele freq for A
  rs  A B af  chr pos
  [snp-id]  [allele-ref]  [allele-alt]  [allele-freq]  [pos]
where:
    -h  show this help text
    -i  input SNP information file in GZ format
    -g  BIMBAM genotype mean file (no filp) in GZ format
    -o  output file name in GZ format"
while getopts ':ho:i:g:' option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    i) input=$OPTARG
       ;;
    o) output=$OPTARG
       ;;
    g) geno=$OPTARG
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
awk 'NR==FNR{a[$1]=$3"\t"$2;next}{print $1,a[$1],0.1,$2,$3}' OFS="\t" FS=' ' <(zcat $geno) FS='\t' <(zcat $input) > $output.temp
echo -e 'rs\tA\tB\taf\tchr\tpos' | cat - $output.temp | gzip > $output && rm $output.temp
