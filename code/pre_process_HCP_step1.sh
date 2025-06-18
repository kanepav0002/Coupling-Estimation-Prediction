#!/bin/bash

#SBATCH --job-name=HCP_PIPELINE
#SBATCH --time=0-2:30:00
#SBATCH --ntasks=1
#SBATCH --mem=60000
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1

while getopts "s:d:r:" flag; do
	case "${flag}" in
		s) sub_name=${OPTARG} ;; 
		d) sub_dir=${OPTARG} ;; 
		r) base_dir=${OPTARG} ;; 

	esac
done

# Manual inputs
MNI_Template="/home/kanep/kg98_scratch/Kane/FC_estimations/utils/MNI152_T1_2mm.nii.gz"
spm_dir="/home/kanep/kg98_scratch/Kane/FC_estimations/utils/spm12"
oasis_dir="$base_dir/utils/MICCAI2012-Multi-Atlas-Challenge-Data"
parc_file="$base_dir/utils/Schaefer2018_300Parcels_17Networks_order_FSLMNI152_2mm.nii.gz"
TR=0.72
fixed_fmri="rfMRI_REST1_LR_hp2000_clean.nii.gz"

# Modules required - make sure these exist
# Replace these with the module names in your cluster
module purge
module load fsl
module load matlab/r2023b 
source $base_dir/utils/FC_estimations_venv/bin/activate

# Copy HCP files from central location
mkdir $base_dir/$sub_dir
T1_file="/mnt/reference2/hcp1200/$sub_name/MNINonLinear/T1w_restore_brain.nii.gz"
fixed_func_file="/mnt/reference2/hcp1200/$sub_name/MNINonLinear/Results/rfMRI_REST1_LR/rfMRI_REST1_LR_hp2000_clean.nii.gz"
mov_file="/mnt/reference2/hcp1200/$sub_name/MNINonLinear/Results/rfMRI_REST1_LR/Movement_Regressors.txt"
cd $base_dir/$sub_dir
mkdir func
mkdir anat
cp $T1_file anat/T1w_brain.nii.gz
cp $fixed_func_file func/rfMRI_REST1_LR_hp2000_clean.nii.gz
cp $mov_file func/Movement_Regressors.txt

# Downsample T1 from 1mm to 2mm
python $base_dir/code/utils/resample_images.py -f $base_dir/$sub_dir/func/rfMRI_REST1_LR_hp2000_clean.nii.gz -r $MNI_Template -a $base_dir/$sub_dir/anat/T1w_brain.nii.gz
# Rename the anat file so that it is consistent with ABCD pre processing
cp $base_dir/$sub_dir/anat/T1w_brain_interp.nii.gz $base_dir/$sub_dir/anat/T1_MNI_BrainExtractionBrain.nii.gz

cd $base_dir
sh code/utils/linden_WM_CSF_masks.sh -a T1_MNI_BrainExtractionBrain.nii.gz -f $base_dir/$sub_dir/func -r $base_dir

# Get mean signals
fslmeants -i $base_dir/$sub_dir/func/$fixed_fmri -o $base_dir/$sub_dir/func/WM_post_fix_ts.txt -m $base_dir/$sub_dir/anat/final_wmmask.nii.gz
fslmeants -i $base_dir/$sub_dir/func/$fixed_fmri -o $base_dir/$sub_dir/func/CSF_post_fix_ts.txt -m $base_dir/$sub_dir/anat/final_csfmask.nii.gz
fslmeants -i $base_dir/$sub_dir/func/$fixed_fmri -o $base_dir/$sub_dir/func/GS_post_fix_ts.txt -m $base_dir/$sub_dir/anat/brain_mask.nii.gz

# Collate regressors & Get derivatives 
python code/utils/get_p24_regs.py -s $sub_name -f $base_dir/$sub_dir/func -m "not_this_time" -w $base_dir/$sub_dir/func/WM_post_fix_ts.txt -c $base_dir/$sub_dir/func/CSF_post_fix_ts.txt -g $base_dir/$sub_dir/func/GS_post_fix_ts.txt -d "not_this_time"

# Create a list with no censored frames
dim_time=$(fslinfo $base_dir/$sub_dir/func/$fixed_fmri | awk '/dim4/ {print $2}')
dim_time=${dim_time:0:4}
rm $base_dir/$sub_dir/func/no_censor.txt
for ((i=0; i<dim_time; i++)); do
    echo "1" >> $base_dir/$sub_dir/func/no_censor.txt
done

# Perform Regressions
echo $base_dir/$sub_dir/func/$fixed_fmri > $base_dir/$sub_dir/func/tmp_fmri_list.txt
echo $base_dir/$sub_dir/func/FIX_24P_2P_GS.nii.gz > $base_dir/$sub_dir/func/tmp_out_list.txt
echo $base_dir/$sub_dir/func/curr_regs.csv > $base_dir/$sub_dir/func/tmp_regs.txt
echo $base_dir/$sub_dir/func/no_censor.txt > $base_dir/$sub_dir/func/tmp_c_frames_list.txt
matlab -nodisplay -r "addpath('$base_dir/code/utils'); CBIG_glm_regress_vol('$base_dir/$sub_dir/func/tmp_fmri_list.txt', '$base_dir/$sub_dir/func/tmp_out_list.txt','$base_dir/$sub_dir/func/tmp_regs.txt', '1', '$base_dir/$sub_dir/func/tmp_c_frames_list.txt', '1', '0', '$base_dir'); exit;"

# Censor?????

# Bandpass Filter
matlab -nodisplay -r "addpath('$base_dir/code/utils'); bandpass_filter('$base_dir/$sub_dir/func', 'FIX_24P_2P_GS.nii.gz', '$base_dir/$sub_dir/anat/brain_mask.nii.gz', '$TR', '0.008', '0.08', '$base_dir'); exit;"

# Parcellate
fslmeants -i $base_dir/$sub_dir/func/FIX_24P_2P_GS_bpass.nii.gz --label=$parc_file -o $base_dir/$sub_dir/func/fsl_parc_ts.txt
#######################################
# Delete all unwanted files
#######################################
find $base_dir/$sub_dir/func -type f \( -name "*.nii" -o -name "*.nii.gz" \) ! -name "FIX_24P_2P_GS_bpass.nii.gz" -exec rm -v {} +
find $base_dir/$sub_dir/anat -type f \( -name "*.nii" -o -name "*.nii.gz" \) ! -name "T1_MNI_BrainExtractionBrain.nii.gz" ! -name "T1_MNI_BrainExtractionMask.nii.gz" -exec rm -v {} +



