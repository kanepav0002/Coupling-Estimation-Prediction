% Match the sparsity of traditionally estimated metrics with the sparsity
% imposed by glasso partial correlation


base_dir="/home/kanep/kg98_scratch/Kane/FC_estimations";
sub_list=readcell(sprintf('%s/data/ABCD/stringent_sub_list_exclusions.csv',base_dir));
utils_path=sprintf('%s/code/utils',base_dir);
addpath(genpath(utils_path))

FC_file=sprintf('%s/data/ABCD_results/FC/stringent_motion_exclusions_FC.mat',base_dir);
load(FC_file);
for s=1:length(sub_list)

    All_FC.pearsons_sparse(:,:,s) = match_sparsity(All_FC.glasso_p_corr(:,:,s), All_FC.pearsons(:,:,s));
    All_FC.spearmans_sparse(:,:,s) = match_sparsity(All_FC.glasso_p_corr(:,:,s), All_FC.spearmans(:,:,s));
    All_FC.MI_time_sparse(:,:,s) = match_sparsity(All_FC.glasso_p_corr(:,:,s), All_FC.MI_time(:,:,s));
    All_FC.MI_freq_sparse(:,:,s) = match_sparsity(All_FC.glasso_p_corr(:,:,s), All_FC.MI_freq(:,:,s));
    All_FC.spec_coh_sparse(:,:,s) = match_sparsity(All_FC.glasso_p_corr(:,:,s), All_FC.spec_coh(:,:,s));
    All_FC.wav_coh_sparse(:,:,s) = match_sparsity(All_FC.glasso_p_corr(:,:,s), All_FC.wav_coh(:,:,s));
end

% Re-order fields so they are in plotting order
field_order.pearsons=[]; field_order.pearsons_sparse=[]; 
field_order.spearmans=[]; field_order.spearmans_sparse=[]; field_order.p_corr=[];
field_order.glasso_p_corr=[]; field_order.MI_time=[]; field_order.MI_time_sparse=[];
field_order.MI_freq=[]; field_order.MI_freq_sparse=[]; field_order.spec_coh=[]; 
field_order.spec_coh_sparse=[];field_order.wav_coh=[]; field_order.wav_coh_sparse=[];
field_order.synergy=[]; field_order.redundancy=[]; field_order.reg_DCM=[];
field_order.reg_DCM_upper=[]; field_order.reg_DCM_lower=[];

All_FC= orderfields(All_FC,field_order);

FC_file_out=sprintf('%s/data/ABCD_results/FC/stringent_motion_exclusions_FC_with_sparsity.mat',base_dir);
save(FC_file_out,"All_FC", '-v7.3');