%% Apply COMBAT to ABCD data

cd /home/kanep/kg98_scratch/Kane/FC_estimations/data/ABCD   
addpath(genpath('/home/kanep/kg98_scratch/Kane/FC_estimations/utils'))

sub_list=readcell('stringent_sub_list_exclusions.csv');
MRI=readtable('../ABCD_tabulated_data/core/imaging/mri_y_adm_info.csv');
MRI=MRI(strcmp(MRI.eventname, 'baseline_year_1_arm_1'), :);
MRI.src_subject_id = erase(MRI.src_subject_id, '_');

demo=readtable('../ABCD_tabulated_data/core/abcd-general/abcd_p_demo.csv');
demo=demo(strcmp(demo.eventname, 'baseline_year_1_arm_1'), :);
demo.src_subject_id = erase(demo.src_subject_id, '_');

% Filter MRI and demo so that it matches the kept subs
demo_ids = demo.src_subject_id;
[~, idx] = ismember(sub_list, demo_ids); % Find indices where demo's IDs match sub_list (in order)
filtered_demo = demo(idx(idx > 0), :); 

MRI_ids = MRI.src_subject_id;
[~, idx] = ismember(sub_list, MRI_ids); % Find indices where demo's IDs match sub_list (in order)
filtered_MRI = MRI(idx(idx > 0), :); 

%% Prepare combat variables

for s=1:length(sub_list)
    device=string(filtered_MRI.mri_info_deviceserialnumber(s));

    if device=="HASH96a0c182"
        batch(s)=1;
    elseif device=="HASHb640a1b8"
        batch(s)=2;
    end
end

mod(:,1)=filtered_demo.demo_sex_v2;
mod(:,2)=filtered_demo.demo_brthdat_v2;

%% Load in MRI

load ../ABCD_results/FC/stringent_motion_exclusions_FC.mat
fns=fieldnames(FC_low_motion);
num_subs=423;
all_zero_linear = struct();

% Combat replaces abs 0 values, so need to store these for later
for i = 1:length(fns)
    curr_FC = FC_low_motion.(fns{i});
    tmp_FC_2D = reshape(curr_FC, [], size(curr_FC, 3));
    
    % Find linear indices of zeros and replace temporarily
    zero_linear = find(tmp_FC_2D == 0);
    tmp_FC_2D(zero_linear) = 0.000001;
    
    % Handle Inf values (e.g., on diagonal)
    tmp_FC_2D(tmp_FC_2D == Inf) = 0.99999999999;
    
    All_FC_2D(:,:,i) = tmp_FC_2D;
    all_zero_linear.(fns{i}) = zero_linear; % Store linear indices
    disp(fns{i});
end

%% Run ComBat 
adjusted_FC = zeros(size(All_FC_2D)); 
for i = 1:length(fns)
    curr_FC = All_FC_2D(:,:,i);
    adjusted_FC(:,:,i) = combat(curr_FC, batch, mod, 1);
end

%% re-input zeros and save
for i = 1:length(fns)
    curr_adj_FC = adjusted_FC(:,:,i);
    
    % Restore zeros using linear indices
    curr_adj_FC(all_zero_linear.(fns{i})) = 0;
    
    All_FC.(fns{i}) = reshape(curr_adj_FC, 300, 300, num_subs);
    disp(fns{i});
end

% Save results 
FC_name_out = '../ABCD_results/FC/stringent_motion_exclusions_FC.mat';
save(FC_name_out, "All_FC", '-v7.3');