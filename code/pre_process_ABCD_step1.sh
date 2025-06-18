#!/bin/bash

#SBATCH --job-name=preproc_ABCD
#SBATCH --time=0-24:00:00
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
module load fsl
module load ants
module load matlab/r2023b 


#base_dir="/home/kanep/kg98_scratch/Kane/FC_estimations"
#sub_dir="data/ABCD/sub-NDARINVKK5BJGB6/ses-baselineYear1Arm1"
#sub_name="NDARINVKK5BJGB6"
anat_file="anat/sub-"$sub_name"_ses-baselineYear1Arm1_run-01_T1w.nii"
MNI_Template="/home/kanep/kg98_scratch/Kane/FC_estimations/utils/MNI152_T1_2mm.nii.gz"
spm_dir="/home/kanep/kg98_scratch/Kane/FC_estimations/utils/spm12"
oasis_dir="$base_dir/utils/MICCAI2012-Multi-Atlas-Challenge-Data"
parc_file="$base_dir/utils/Schaefer2018_300Parcels_17Networks_order_FSLMNI152_2mm.nii.gz"

sh $base_dir/code/utils/get_abcd_files.sh -s $sub_name -r $base_dir
cd "$base_dir/$sub_dir"


################################################################
# Remove Initial Frames
matlab -nodisplay -r "addpath('$base_dir/code/utils'); ABCD_remove_frames('$base_dir/$sub_dir/func', '$sub_name'); exit;"


################################################################
# Registration
fslmaths func/frames_removed_run01.nii -Tmean func/mean_fmri.nii.gz

antsRegistrationSyNQuick.sh -d 3 -f $anat_file -m func/mean_fmri.nii.gz -o func/fmri_to_t1 -t s

antsRegistrationSyNQuick.sh -d 3 -f $MNI_Template -m $anat_file -o func/t1_to_MNI -t s

mv func/t1_to_MNIWarped.nii.gz anat/T1_MNI.nii.gz

matlab -nodisplay -r "addpath('$base_dir/code/utils'); splitImages('$base_dir/$sub_dir', '$spm_dir'); exit;"
for run_dir in func/run*; do
       	# Create a list of files for this run
        file_list="${run_dir}/file_list.txt"
        ls "$run_dir" | grep -v "file_list.txt" > "$file_list"     
done

run=1
for run_dir in func/run*; do
	file_list=$run_dir/file_list.txt
	i=1
	while IFS= read -r file; do
            
			antsApplyTransforms -d 3 -i $run_dir/$file -r $MNI_Template -o $run_dir/MNI_frame"$i".nii.gz -t func/t1_to_MNI1Warp.nii.gz -t func/t1_to_MNI0GenericAffine.mat -t func/fmri_to_t10GenericAffine.mat
            echo "$file"
			let i=i+1
    done < "$file_list"
	fslmerge -t func/MNI_image_run"$run".nii.gz $run_dir/MNI_frame*
	let run=run+1

done

rm func/frames_removed*.nii

#############################
# Base pre-processing
###############################
# Brain Extract T1
antsBrainExtraction.sh -d 3 -a anat/T1_MNI.nii.gz -e $oasis_dir/T_template0.nii.gz -m $oasis_dir/T_template0_BrainCerebellumProbabilityMask.nii.gz -o anat/T1_MNI_

# Merge images
image_files=$(ls func/MNI_image_run*.nii.gz | sort)
fslmerge -t func/combined_rsfmri.nii.gz $image_files
# Merge confounds
motion_files=$(ls func/motion_confs_frem_run*.csv | sort)
head -n 1 $(echo $motion_files | awk '{print $1}') > func/MovementRegressors.csv
tail -n +2 -q $motion_files >> func/MovementRegressors.csv

# Brain Extract rsfmri
fslmaths func/combined_rsfmri.nii.gz -mas anat/T1_MNI_BrainExtractionMask.nii.gz func/combined_rsfmri_brain.nii.gz

# Remove all nifti except for final processed file.
find func -type f \( -name "*.nii" -o -name "*.nii.gz" \) ! -name "combined_rsfmri_brain.nii.gz" -delete

#############################
# Get Data ready for FIX
#######################################
# Melodic
melodic -i func/combined_rsfmri_brain.nii.gz

cd $base_dir/$sub_dir/func
mkdir -p reg
mkdir -p mc
	
# Rename files so FIX recognises them
mv combined_rsfmri_brain.ica filtered_func_data.ica
mv combined_rsfmri_brain.nii.gz filtered_func_data.nii.gz

# copy mean and mask of func to above directory
cp filtered_func_data.ica/mean.nii.gz mean_func.nii.gz
cp filtered_func_data.ica/mask.nii.gz mask.nii.gz

# Get example function image (middle volume)
middle_vol=$(( $(fslinfo filtered_func_data.nii.gz | grep '^dim4' | awk '{print $2}') / 2 ))
fslroi filtered_func_data.nii.gz reg/example_func.nii.gz $middle_vol 1
	
# Copy structural image
cp $base_dir/$sub_dir/anat/T1_MNI_BrainExtractionBrain.nii.gz reg/highres.nii.gz

# copy in an identity matrix instead of affine transform, as the images are already in the same space
cp $base_dir/utils/identity_matrix.mat reg/highres2example_func.mat

# Format movement parameters for FIX
tail -n +2 MovementRegressors.csv | awk -F',' '{for (i=2; i<=NF; i++) printf "%s%s", $i, (i==NF ? ORS : OFS)}' OFS='\t' > mc/prefiltered_func_data_mcf.par

####################################
# Do FIX
#######################################
module purge
export R_LIBS="$base_dir/utils/FIX_R_LIB"
module load R/4.4.0-mkl
module load matlab/r2017a
module load fsl/5.0.9
export LD_LIBRARY_PATH="/usr/lib64/:$LD_LIBRARY_PATH"

cd $base_dir/$sub_dir
sh $base_dir/utils/fix/fix func $base_dir/utils/ABCD_Train_Weights.RData 50

fixed_fmri="filtered_func_data_clean.nii.gz"

#######################################
# Regress out motion params and GS
#######################################
module purge
module load fsl
module load matlab/r2023b 
source $base_dir/utils/FC_estimations_venv/bin/activate

# Intensity Normalise
matlab -nodisplay -r "addpath('$base_dir/code/utils'); Inorm('$fixed_fmri', '$base_dir/$sub_dir/func/', '$base_dir'); exit;"
fixed_fmri="i"$fixed_fmri

# Get masks
cd $base_dir
sh code/utils/linden_WM_CSF_masks.sh -a T1_MNI_BrainExtractionBrain.nii.gz -f $base_dir/$sub_dir/func -r $base_dir

# Get mean signals
fslmeants -i $base_dir/$sub_dir/func/$fixed_fmri -o $base_dir/$sub_dir/func/WM_post_fix_ts.txt -m $base_dir/$sub_dir/anat/final_wmmask.nii.gz
fslmeants -i $base_dir/$sub_dir/func/$fixed_fmri -o $base_dir/$sub_dir/func/CSF_post_fix_ts.txt -m $base_dir/$sub_dir/anat/final_csfmask.nii.gz
fslmeants -i $base_dir/$sub_dir/func/$fixed_fmri -o $base_dir/$sub_dir/func/GS_post_fix_ts.txt -m $base_dir/$sub_dir/anat/T1_MNI_BrainExtractionMask.nii.gz

# Collate regressors & Get derivatives 
python code/utils/get_p24_regs.py -s $sub_name -f $base_dir/$sub_dir/func -m $base_dir/$sub_dir/func/mc/prefiltered_func_data_mcf.par -w $base_dir/$sub_dir/func/WM_post_fix_ts.txt -c $base_dir/$sub_dir/func/CSF_post_fix_ts.txt -g $base_dir/$sub_dir/func/GS_post_fix_ts.txt -d "not_this_time"

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
matlab -nodisplay -r "addpath('$base_dir/code/utils'); bandpass_filter('$base_dir/$sub_dir/func', 'FIX_24P_2P_GS.nii.gz', '$base_dir/$sub_dir/anat/T1_MNI_BrainExtractionMask.nii.gz', '0.8', '0.008', '0.08', '$base_dir'); exit;"

# Parcellate
fslmeants -i $base_dir/$sub_dir/func/FIX_24P_2P_GS_bpass.nii.gz --label=$parc_file -o $base_dir/$sub_dir/func/fsl_parc_ts.txt
#######################################
# Delete all unwanted files
#######################################
find $base_dir/$sub_dir/func -type f \( -name "*.nii" -o -name "*.nii.gz" \) ! -name "FIX_24P_2P_GS_bpass.nii.gz" -exec rm -v {} +
find $base_dir/$sub_dir/anat -type f \( -name "*.nii" -o -name "*.nii.gz" \) ! -name "T1_MNI_BrainExtractionBrain.nii.gz" ! -name "T1_MNI_BrainExtractionMask.nii.gz" -exec rm -v {} +
cd $base_dir/$sub_dir/func
rm -r filtered_func_data.ica
rm -r run*
rm -r reg
rm -r fix








