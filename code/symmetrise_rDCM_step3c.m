% Split rDCM into upper and lower triangles - i.e. symmetrise 

% Indicate necessary variables
base_dir=("/home/kanep/kg98_scratch/Kane/FC_estimations");
dataset_directory=(sprintf('%s/data/ABCD',base_dir));

%sub_list=readcell(sprintf('%s/data/HCP/FINAL_LR_sub_list.txt',base_dir));
%orig_FDm= dlmread(sprintf('%s/data/HCP_results/FC/All_mean_FD.csv',base_dir)); 

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

reg_DCM=All_FC.reg_DCM;

[nRows, nCols, nPages] = size(reg_DCM);
upper_sym = zeros(nRows, nCols, nPages);
lower_sym = zeros(nRows, nCols, nPages);

for k = 1:nPages
    currentMatrix = reg_DCM(:,:,k);
    % Symmetric upper matrix (upper triangular part symmetrized)
    upper_sym(:,:,k) = triu(currentMatrix) + triu(currentMatrix, 1)';
    % Symmetric lower matrix (lower triangular part symmetrized)
    lower_sym(:,:,k) = tril(currentMatrix) + tril(currentMatrix, -1)';
end

All_FC.reg_DCM_lower=lower_sym;
All_FC.reg_DCM_upper=upper_sym;

FC_name_out=sprintf('%s/data/ABCD_results/FC/recommended_fmri_inclusions.mat',base_dir);
save(FC_name_out,"All_FC", '-v7.3')
