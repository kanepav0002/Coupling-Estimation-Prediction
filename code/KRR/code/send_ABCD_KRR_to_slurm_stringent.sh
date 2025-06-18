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

FC_files=("FC/Upper_and_lower_T/ABCD/pearsons_stringent_subs.mat" "FC/Upper_and_lower_T/ABCD/pearsons_sparse_stringent_subs.mat" "FC/Upper_and_lower_T/ABCD/spearmans_stringent_subs.mat" "FC/Upper_and_lower_T/ABCD/spearmans_sparse_stringent_subs.mat" "FC/Upper_and_lower_T/ABCD/p_corr_stringent_subs.mat" "FC/Upper_and_lower_T/ABCD/glasso_p_corr_stringent_subs.mat" "FC/Upper_and_lower_T/ABCD/MI_time_stringent_subs.mat" "FC/Upper_and_lower_T/ABCD/MI_time_sparse_stringent_subs.mat" "FC/Upper_and_lower_T/ABCD/MI_freq_stringent_subs.mat" "FC/Upper_and_lower_T/ABCD/MI_freq_sparse_stringent_subs.mat" "FC/Upper_and_lower_T/ABCD/spec_coh_stringent_subs.mat" "FC/Upper_and_lower_T/ABCD/spec_coh_sparse_stringent_subs.mat" "FC/Upper_and_lower_T/ABCD/wav_coh_stringent_subs.mat" "FC/Upper_and_lower_T/ABCD/wav_coh_sparse_stringent_subs.mat" "FC/Upper_and_lower_T/ABCD/synergy_stringent_subs.mat" "FC/Upper_and_lower_T/ABCD/redundancy_stringent_subs.mat" "FC/Upper_and_lower_T/ABCD/reg_DCM_stringent_subs.mat" "FC/Upper_and_lower_T/ABCD/reg_DCM_lower_stringent_subs.mat" "FC/Upper_and_lower_T/ABCD/reg_DCM_upper_stringent_subs.mat")

stem_names=("pearsons" "pearsons_sparse" "spearmans" "spearmans_sparse" "p_corr" "glasso_p_corr" "MI_time" "MI_time_sparse" "MI_freq" "MI_freq_sparse" "spec_coh" "spec_coh_sparse" "wav_coh" "wav_coh_sparse" "synergy" "redundancy" "reg_DCM" "reg_DCM_lower" "reg_DCM_upper")


y_list="file_list/ABCD/stringent_behaviours.csv"
covars="file_list/ABCD/stringent_covars.csv"
subject_list="file_list/ABCD/stringent_sub_list.csv"
FC_inclusions="file_list/ABCD/stringent_FC_subject_inclusions.csv"

counter=0
for FC in ${FC_files[@]}; do
	
	FC_name=${FC_files[$counter]}
	outdir="Results/ABCD/"${stem_names[$counter]}"_stringent"
	outstem=${stem_names[$counter]}
	counter=$((counter+1))

	sbatch KRR_single_run_ABCD.sh -s $outstem -f $FC_name -d $outdir -y $y_list -c $covars -l $subject_list -b $FC_inclusions
done

