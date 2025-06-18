# Functional Coupling Analysis in Resting-state fMRI

This repository reproduces all analysis and results found in the manuscript:  
**"The Motion Sensitivity and Predictive Utility of Different Estimates of Inter-regional Functional Coupling in Resting-state Functional MRI."**  
(Kane Pavlovich, James C. Pang & Alex Fornito)

## Software Versions
All code has been run with the following software versions:
- Matlab (r2023b)
- Python (5.3)
- FSL (6.0.1)

## Code Organization & Descriptions

### Functional Coupling

All code is labelled in the order it needs to be run. Below are brief descriptions of what each stage entails:

1. **Preprocessing**
   - `pre_process_HCP_step1.sh` - Conducts preprocessing steps (regression of head motion parameters, white matter and cerebrospinal fluid signals, applies ICA-FIX, and conducts global signal regression).
   - *Note*: There is a separate script for ABCD data labelled `pre_process_ABCD_step1.sh`

2. **Coupling Estimation**
   - `estimate_FC_step2.sh` - Computes estimates for each of the 11 coupling metrics described in the manuscript

3. **Post-processing**
   - `collate_FC_step3a.m` - Collates all functional coupling for each participant into a single .mat file
   - `COMBAT_step3b.m` - Corrects FC for site-specific distortions (only necessary for multi-site data)
   - `symmetrise_rDCM_step3c.m` - Processes regression dynamic causal modelling outputs to be more comparable with traditional symmetric measures
   - `match_sparsity_step3d.m` - Matches coupling matrices sparsity to GLASSO matrices constraints

4. **Quality Control**
   - `Quality_metrics_step4.m` - Conducts QC analysis including:
     - QC-FC correlations
     - Distance dependence analyses
     - *Note*: ROI coordinates for Schaefer 300 parcellation are included in utils folder

### Kernel Ridge Regression

The code for predictive behavior analysis can be found in: `code/KRR/code`

- `collate_{dataset}_behaviours.py` - Specifies behaviors used and their data sources
- `prep_FC_for_KRR.m` - Formats coupling files for analysis
- `run_KRR_repeats.m` - Runs KRR analysis (adapted from [CBIG lab](https://github.com/ThomasYeoLab/CBIG))
- `send_{dataset}_KRR_to_slurm.sh` - Example cluster computing script

### Plots

- `plot_1B.py` - Reproduces Figure 1B
- `plots_3-5.py` - Reproduces Figures 3-5

## Required Utilities

All necessary dependencies and toolboxes:

### Add to the `utils` folder in current repository:
- `CBIG_glm_regress_vol.m` - [Source](https://github.com/ThomasYeoLab/Standalone_CBIG_fMRI_Preproc2016/blob/master/utilities/matlab/stats/CBIG_glm_regress_vol.m)
- `computeNMI.m` - [Source](https://github.com/arunsm/motion-FC-metrics/blob/master/computeNMI.m)

### MATLAB Toolboxes (need to be added to path):
- [CBIG toolbox](https://github.com/ThomasYeoLab/CBIG)
- [REST-master](https://github.com/Chaogan-Yan/REST)
- [spm8](https://github.com/spm/spm8)
- [linden_rsfmri](https://github.com/lindenmp/rs-fMRI)
- [ICA-FIX](https://fsl.fmrib.ox.ac.uk/fsl/docs/#/resting_state/fix_matlab)
- [fieldtrip-master](https://github.com/fieldtrip/fieldtrip)
- [COMBAT](https://github.com/Jfortin1/ComBatHarmonization/tree/master/Matlab)
- [Functional Connectivity Toolbox](https://sites.pitt.edu/~gsiegle/FunctionalConnectivityToolbox.zip)
- [Partial Information Decomposition](https://static-content.springer.com/esm/art%3A10.1038%2Fs41593-022-01070-0/MediaObjects/41593_2022_1070_MOESM3_ESM.zip)
- [tapas-master](https://github.com/ComputationalPsychiatry)
- [Wavelet Coherence](https://au.mathworks.com/matlabcentral/fileexchange/47985-cross-wavelet-and-wavelet-coherence)

### Python Packages:
- [GraphicalLassoCV](https://github.com/ColeLab/ActflowToolbox/tree/master/connectivity_estimation)

