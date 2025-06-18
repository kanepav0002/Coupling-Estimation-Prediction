#!/bin/bash

#SBATCH --job-name=HCP_KRR
#SBATCH --time=0-12:30:00
#SBATCH --ntasks=1
#SBATCH --mem=45000
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mail-user=<knpavlovich@gmail.com>
#SBATCH --mail-type=FAIL

cd ~/kg98_scratch/Kane/FC_estimations/KRR/code

#FC_files=("FC/Upper_and_lower_T/HCP/pearsons_stringent_subs.mat" "FC/Upper_and_lower_T/HCP/spearmans_stringent_subs.mat" "FC/Upper_and_lower_T/HCP/p_corr_stringent_subs.mat" "FC/Upper_and_lower_T/HCP/glasso_p_corr_stringent_subs.mat" "FC/Upper_and_lower_T/HCP/MI_time_stringent_subs.mat" "FC/Upper_and_lower_T/HCP/MI_freq_stringent_subs.mat" "FC/Upper_and_lower_T/HCP/spec_coh_stringent_subs.mat" "FC/Upper_and_lower_T/HCP/wav_coh_stringent_subs.mat" "FC/Upper_and_lower_T/HCP/synergy_stringent_subs.mat" "FC/Upper_and_lower_T/HCP/redundancy_stringent_subs.mat" "FC/Upper_and_lower_T/HCP/reg_DCM_stringent_subs.mat" "FC/Upper_and_lower_T/HCP/reg_DCM_lower_stringent_subs.mat" "FC/Upper_and_lower_T/HCP/reg_DCM_upper_stringent_subs.mat")

#stem_names=("pearsons" "spearmans" "p_corr" "glasso_p_corr" "MI_time" "MI_freq" "spec_coh" "wav_coh" "synergy" "redundancy" "reg_DCM" "reg_DCM_lower" "reg_DCM_upper")

FC_files=("FC/Upper_and_lower_T/HCP/pearsons_sparse_stringent_subs.mat" "FC/Upper_and_lower_T/HCP/spearmans_sparse_stringent_subs.mat" "FC/Upper_and_lower_T/HCP/MI_time_sparse_stringent_subs.mat" "FC/Upper_and_lower_T/HCP/MI_freq_sparse_stringent_subs.mat" "FC/Upper_and_lower_T/HCP/spec_coh_sparse_stringent_subs.mat" "FC/Upper_and_lower_T/HCP/wav_coh_sparse_stringent_subs.mat")

stem_names=("pearsons_sparse" "spearmans_sparse" "MI_time_sparse" "MI_freq_sparse" "spec_coh_sparse" "wav_coh_sparse")

y_list="file_list/HCP/stringent_behaviours.csv"
covars="file_list/HCP/stringent_covars.csv"
subject_list="file_list/HCP/stringent_sub_list.csv"
FC_inclusions="file_list/HCP/stringent_subject_inclusions.csv"

counter=0
for FC in ${FC_files[@]}; do
	
	FC_name=${FC_files[$counter]}
	outdir="Results/HCP/"${stem_names[$counter]}"_stringent"
	outstem=${stem_names[$counter]}
	counter=$((counter+1))

	sbatch KRR_single_run.sh -s $outstem -f $FC_name -d $outdir -y $y_list -c $covars -l $subject_list -b $FC_inclusions
done

