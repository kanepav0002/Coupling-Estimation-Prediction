% Script to perform QC-FC correlations, QC Distance Dependence and Variance
% explained by VE1

% Indicate necessary variables
base_dir=("/home/kanep/kg98_scratch/Kane/FC_estimations");
dataset_directory=(sprintf('%s/data/ABCD',base_dir));

sub_list=readcell(sprintf('%s/data/ABCD/recommended_subs_to_keep.csv',base_dir));
orig_FDm= dlmread(sprintf('%s/data/ABCD_results/FC/recommended_fmri_inclusions_mean_FD.csv',base_dir)); 

% Load in FC
All_FC=load(sprintf('%s/data/ABCD_results/FC/recommended_fmri_inclusions.mat',base_dir));
fieldName = fieldnames(All_FC); 
fieldName = fieldName{1}; 
subfields = fieldnames(All_FC.(fieldName));
for i = 1:length(subfields)
    subfieldName = subfields{i};
    All_FC.(subfieldName) = All_FC.(fieldName).(subfieldName);
end
All_FC = rmfield(All_FC, fieldName);

%% With sparsity definitions
num_procs= 19; 
preprocs = ["Pearsons", "Pearsons sparse","Spearmans", "Spearmans sparse", ...
    "Partial correlation", "Glasso Partial correlation", "Mutual information (time)", ...
    "Mutual information (time) sparse", "Mutual information (frequency)", ...
    "Mutual information (frequency) sparse", "Spectral Coherence", "Spectral Coherence sparse", ...
    "Wavelet Coherence", "Wavelet Coherence sparse", "Synergy", "Redundancy", ...
    "Regression DCM All connnections", "Regression DCM Outgoing connections", ...
    "Regresssion DCM Incoming connections"]; 

%% Without sparsity definitions
num_procs= 13; 
preprocs = ["Pearsons", "Spearmans", ...
    "Partial correlation", "Glasso Partial correlation", "Mutual information (time)", ...
     "Mutual information (frequency)", ...
    "Spectral Coherence", ...
    "Wavelet Coherence", "Synergy", "Redundancy", ...
    "Regression DCM All connnections", "Regression DCM Outgoing connections", ...
    "Regresssion DCM Incoming connections"]; 

%% Load necessary tools
cd(dataset_directory)
stat_dir=sprintf('%s/code/utils',base_dir);
addpath(genpath(stat_dir))

%% Begin analysis

% Remove subjects with NaN
fns=fieldnames(All_FC);
rmv=zeros(length(orig_FDm),1);
for i=1:length(fns)
    rmv_tmp=squeeze(any(any(isnan(All_FC.(fns{i})),1),2));
    rmv=rmv+rmv_tmp;
end
rmv=logical(rmv);
for i=1:length(fns)
    All_FC.(fns{i})(:,:,rmv)=[];
end
orig_FDm(rmv)=[];

All_QC = struct('preprocs',[]',...
    'NaNFilter',[],...
    'QCFC',[],...
    'QCFC_corrected_P',[],...
    'prop_sig_corr',[],...
    'prop_sig_corr_corrected',[],...
    'DistDep',[],...
    'DistDep_P',[]);

%% Perform QC_FC

for i=1:length(fns)
    [QCFC,P] = GetDistCorr(orig_FDm,All_FC.(fns{i}));
    P = P(~eye(size(P)));
    %P = LP_FlatMat(P);
    
    P_corrected = mafdr(P, 'BHFDR','true');
    All_QC(i).QCFC_corrected_P = P_corrected;
    All_QC(i).QCFC = QCFC(~eye(size(QCFC)));
    
    
    %All_QC(i).NaNFilter = ~isnan(All_QC(i).QCFC);
    %if ~any(All_QC(i).NaNFilter)
    %    error('FATAL: No data left after filtering NaNs!');
    %elseif any(All_QC(i).NaNFilter)
    %    fprintf(1, '\tRemoved %u NaN samples from data \n',sum(~All_QC(i).NaNFilter));
    %    All_QC(i).QCFC = All_QC(i).QCFC(All_QC(i).NaNFilter);
    %    P = P(All_QC(i).NaNFilter);
    %end
    
    All_QC(i).prop_sig_corr=round(sum(P<0.05) / numel(P) * 100,2);
    All_QC(i).prop_sig_corr_corrected = round(sum(P_corrected<0.05) / numel(P_corrected) * 100,2);

    All_QC(i).preprocs = preprocs(i);
end

%% Perform Distance Dependant Correlations

ROI_Coords = dlmread(sprintf('%s/utils/roi_Schaef300_MMP.txt',base_dir));
% the above ROI coords are for Schaefer 300 parcellation, if you are using
% another parcellation you need to generate your own.
ROIDist = pdist2(ROI_Coords,ROI_Coords,'euclidean');
ROIDistVec = ROIDist(~eye(size(ROIDist)));

for i=1:length(preprocs)
    [All_QC(i).DistDep, All_QC(i).DistDep_P] = corr(ROIDistVec,All_QC(i).QCFC,'type','Spearman');
    
end

  %% Save results

for i=1:length(preprocs)
    QC_FC(i,:)=All_QC(i).QCFC;
    dist_dep(i)=All_QC(i).DistDep;
end

QC_FC_out_name=sprintf('%s/data/ABCD_results/Quality_metrics/QC_FC_corrs_recommended_inclusions.csv',base_dir);
dlmwrite(QC_FC_out_name, QC_FC)
dist_dep_out_name=sprintf('%s/data/ABCD_results/Quality_metrics/distance_dependence_recommended_inclusions.csv',base_dir);
dlmwrite(dist_dep_out_name, dist_dep)



  
