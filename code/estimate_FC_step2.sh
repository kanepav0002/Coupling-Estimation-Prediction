#!/bin/bash

#SBATCH --job-name=Estimate_connec
#SBATCH --time=0-12:00:00
#SBATCH --ntasks=1
#SBATCH --mem=65000
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mail-user=<knpavlovich@gmail.com>
#SBATCH --mail-type=FAIL

while getopts "s:d:r:" flag; do
	case "${flag}" in
		s) sub_name=${OPTARG} ;; 
		d) sub_dir=${OPTARG} ;; 
		r) base_dir=${OPTARG} ;; 

	esac
done

#base_dir="/home/kanep/kg98_scratch/Kane/FC_estimations"
#sub_dir="data/ABCD/sub-NDARINV9V4WNUEA/ses-baselineYear1Arm1"
#sub_name="NDARINV9V4WNUEA"

module load matlab/r2023b
source $base_dir/utils/FC_estimations_venv/bin/activate

ts_file="fsl_parc_ts.txt"
tr=0.72
f1="0.008"
f2="0.08"

matlab -nodisplay -r "addpath('$base_dir/code/utils'); estimate_FC('$sub_name', '$base_dir/$sub_dir/func', '$ts_file', '$base_dir', '$tr', '$f1', '$f2'); exit;"

python $base_dir/code/utils/estimate_GGLasso.py -s $sub_name -f $base_dir/$sub_dir/func -ts $ts_file -b $base_dir 


