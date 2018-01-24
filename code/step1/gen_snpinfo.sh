usage="$(basename "$0") [-h] [-i snp-info] [-o output-name]
  Take SNP information file in the format:
  [snp-id]  [chr] [position]
  and output a SNP information file in BIMBAM format:
  ## af is the allele freq for A
  rs  A B af  chr pos
  [snp-id]  [allele-alt]  [allele-ref]  [allele-freq]  [pos]
where:
    -h  show this help text
    -i  input SNP information file in GZ format
    -o  output file name in GZ format"
while getopts ':ho:i:' option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    i) input=$OPTARG
       ;;
    o) output=$OPTARG
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

zcat $input | awk -F"\t" -v OFS="\t" '{print $1,"X","X",0.1,$2,$3}' > $output.temp
echo -e 'rs\tA\tB\taf\tchr\tpos' | cat - $output.temp | gzip > $output && rm $output.temp
