% Collate the results from the KRR across repetitions

base_dir="/home/kanep/kg98_scratch/Kane/FC_estimations";
dataset="HCP";
exclusions="stringent";
reps=20;
pipes = ["pearsons", "spearmans", "p_corr", "glasso_p_corr", "MI_time", ...
    "MI_freq", "spec_coh", "wav_coh", "synergy", "redundancy", "reg_DCM", ...
    "reg_DCM_lower", "reg_DCM_upper"];

% HCP indicies
cog_index=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,24,25,29];
cog_index=cog_index+1;
personality_index=[30,31,32,33,34,41,42,43,44,45,46,49];
personality_index=personality_index+1;

for p=1:length(pipes)
    curr_pipe=sprintf('%s/KRR/Results/%s/%s_%s',base_dir,dataset,pipes(p),exclusions);
    
    for r=1:reps
        rep_to_load=sprintf('%s/final_result_%s_rep%d.mat',curr_pipe,pipes(p),r);
        load(rep_to_load)
        
        optimal_acc=optimal_acc(:,cog_index);
        accuracy_result(:,:,r)=optimal_acc;
    end

    all_res(:,:,:,p)=accuracy_result;

    reps_mean=mean(accuracy_result,3);
    mean_acc_across_reps_behavs(:,p)=mean(reps_mean,2);

end

mean_reps_out_name=sprintf('%s/data/%s_results/KRR/cognitive_mean_across_reps_UTLT_%s.csv',base_dir,dataset,exclusions);
dlmwrite(mean_reps_out_name,mean_acc_across_reps_behavs)

%% ABCD
base_dir="/home/kanep/kg98_scratch/Kane/FC_estimations";
dataset="ABCD";
exclusions="stringent";
reps=20;
pipes = ["pearsons", "spearmans", "p_corr", "glasso_p_corr", "MI_time", ...
    "MI_freq", "spec_coh", "wav_coh", "synergy", "redundancy", "reg_DCM", ...
    "reg_DCM_lower", "reg_DCM_upper"];

% ABCD indicies
cog_index=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];
pyschopathology_index=[17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36];


for p=1:length(pipes)
    curr_pipe=sprintf('%s/KRR/Results/%s/%s_%s',base_dir,dataset,pipes(p),exclusions);
    
    for r=1:reps
        rep_to_load=sprintf('%s/final_result_%s_rep%d.mat',curr_pipe,pipes(p),r);
        load(rep_to_load)
        
        optimal_acc=optimal_acc(:,cog_index);
        accuracy_result(:,:,r)=optimal_acc;
    end

    all_res(:,:,:,p)=accuracy_result;

    reps_mean=mean(accuracy_result,3);
    mean_acc_across_reps_behavs(:,p)=mean(reps_mean,2);

end

mean_reps_out_name=sprintf('%s/data/%s_results/KRR/cognitive_mean_across_reps_UTLT_%s.csv',base_dir,dataset,exclusions);
dlmwrite(mean_reps_out_name,mean_acc_across_reps_behavs)


%% Including Sparsity

base_dir="/home/kanep/kg98_scratch/Kane/FC_estimations";
dataset="HCP";
exclusions="stringent";
reps=20;
pipes = ["pearsons","pearsons_sparse", "spearmans", "spearmans_sparse","p_corr", ...
    "glasso_p_corr", "MI_time", "MI_time_sparse", "MI_freq", "MI_freq_sparse", ...
    "spec_coh", "spec_coh_sparse", "wav_coh", "wav_coh_sparse", "synergy", ...
    "redundancy", "reg_DCM", "reg_DCM_lower", "reg_DCM_upper"];

% HCP indicies
cog_index=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,24,25,29];
cog_index=cog_index+1;
personality_index=[30,31,32,33,34,41,42,43,44,45,46,49];
personality_index=personality_index+1;

for p=1:length(pipes)
    curr_pipe=sprintf('%s/KRR/Results/%s/%s_%s',base_dir,dataset,pipes(p),exclusions);
    
    for r=1:reps
        rep_to_load=sprintf('%s/final_result_%s_rep%d.mat',curr_pipe,pipes(p),r);
        load(rep_to_load)
        
        optimal_acc=optimal_acc;
        accuracy_result(:,:,r)=optimal_acc;
    end

    all_res(:,:,:,p)=accuracy_result;

    reps_mean=mean(accuracy_result,3);
    mean_acc_across_reps_behavs(:,p)=mean(reps_mean,2);

end

mean_reps_out_name=sprintf('%s/data/%s_results/KRR/sparse/mean_across_reps_UTLT_%s.csv',base_dir,dataset,exclusions);
dlmwrite(mean_reps_out_name,mean_acc_across_reps_behavs)

%% ABCD
base_dir="/home/kanep/kg98_scratch/Kane/FC_estimations";
dataset="ABCD";
exclusions="recommended";
reps=20;
pipes = ["pearsons","pearsons_sparse", "spearmans", "spearmans_sparse","p_corr", ...
    "glasso_p_corr", "MI_time", "MI_time_sparse", "MI_freq", "MI_freq_sparse", ...
    "spec_coh", "spec_coh_sparse", "wav_coh", "wav_coh_sparse", "synergy", ...
    "redundancy", "reg_DCM", "reg_DCM_lower", "reg_DCM_upper"];

% ABCD indicies
cog_index=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];
pyschopathology_index=[17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36];


for p=1:length(pipes)
    curr_pipe=sprintf('%s/KRR/Results/%s/%s_%s',base_dir,dataset,pipes(p),exclusions);
    
    for r=1:reps
        rep_to_load=sprintf('%s/final_result_%s_rep%d.mat',curr_pipe,pipes(p),r);
        load(rep_to_load)
        
        optimal_acc=optimal_acc(:,cog_index);
        accuracy_result(:,:,r)=optimal_acc;
    end

    all_res(:,:,:,p)=accuracy_result;

    reps_mean=mean(accuracy_result,3);
    mean_acc_across_reps_behavs(:,p)=mean(reps_mean,2);

end

mean_reps_out_name=sprintf('%s/data/%s_results/KRR/sparse/cognitive_mean_across_reps_UTLT_%s.csv',base_dir,dataset,exclusions);
dlmwrite(mean_reps_out_name,mean_acc_across_reps_behavs)

