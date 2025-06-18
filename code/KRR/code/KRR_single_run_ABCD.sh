#!/bin/bash

#SBATCH --job-name=KRR_stringent
#SBATCH --time=5-00:00:00
#SBATCH --ntasks=1
#SBATCH --mem=20000
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mail-user=<knpavlovich@gmail.com>
#SBATCH --mail-type=FAIL
while getopts "s:f:d:y:c:l:b:" flag; do
	case "${flag}" in
		s) outstem=${OPTARG} ;;
		f) FC_name=${OPTARG} ;;
		d) outdir=${OPTARG} ;;
		y) y_name=${OPTARG} ;;
		c) covars=${OPTARG} ;;
		l) sub_list=${OPTARG} ;;
		b) sub_boolean=${OPTARG} ;;
	esac
done
module purge
module load matlab/r2023b

cd ~/kg98_scratch/Kane/FC_estimations/KRR/code

base_dir="/home/kanep/kg98_scratch/Kane/FC_estimations"
echo $FC_name
echo $sub_boolean
matlab -nodisplay -r "run_KRR_repeats('$FC_name','$y_name','$covars', '$sub_list', '$sub_boolean','$outdir','$outstem', '$base_dir'); exit;"


