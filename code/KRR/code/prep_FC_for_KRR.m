% Prepare FC for KRR - input as 2D matrices

base_dir=("/home/kanep/kg98_scratch/Kane/FC_estimations");

%% With sparsity
preprocs = ["Pearsons", "Pearsons sparse","Spearmans", "Spearmans sparse", ...
    "Partial correlation", "Glasso Partial correlation", "Mutual information (time)", ...
    "Mutual information (time) sparse", "Mutual information (frequency)", ...
    "Mutual information (frequency) sparse", "Spectral Coherence", "Spectral Coherence sparse" ...
    "Wavelet Coherence", "Wavelet Coherence sparse", "Synergy", "Redundancy", ...
    "Regression DCM All connnections", "Regression DCM Outgoing connections", ...
    "Regresssion DCM Incoming connections"]; 

%% Load in FC
All_FC=load(sprintf('%s/data/ABCD_results/FC/stringent_motion_exclusions_FC_with_sparsity.mat',base_dir));
fieldName = fieldnames(All_FC); 
fieldName = fieldName{1}; 
subfields = fieldnames(All_FC.(fieldName));
for i = 1:length(subfields)
    subfieldName = subfields{i};
    All_FC.(subfieldName) = All_FC.(fieldName).(subfieldName);
end
All_FC = rmfield(All_FC, fieldName);

% Seperate each FC and save
upper_t=triu(true(300,300),1);
lower_t=tril(true(300,300),-1);

fns=fieldnames(All_FC);
for i=1:length(fns)
    curr_FC=All_FC.(fns{i});
    
    for s=1:size(curr_FC,3)
        curr_sub= curr_FC(:,:,s);
        upper_values= curr_sub(upper_t);
        lower_values= curr_sub(lower_t);

        curr_FC_2D(:,s) = [upper_values; lower_values];
        %curr_FC_2D(:,s)=upper_values;
    end

    file_out=sprintf('%s/KRR/FC/Upper_and_lower_T/ABCD/%s_stringent_subs.mat',base_dir,fns{i});
    save(file_out,"curr_FC_2D")
    clear curr_FC_2D
    disp(fns{i})
end