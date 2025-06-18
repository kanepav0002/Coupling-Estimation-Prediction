% Collate FC and remove subjects below an FD threshold.

base_dir="/home/kanep/kg98_scratch/Kane/FC_estimations";
%sub_list=readcell(sprintf('%s/data/ABCD/recommended_subs_to_keep.csv',base_dir));
sub_list=readcell('/home/kanep/kg98_scratch/Kane/FC_estimations/data/ABCD/recommended_subs_to_keep.csv');
tr=0.8;
utils_path=sprintf('%s/code/utils',base_dir);
addpath(genpath(utils_path))

%% Collate FC
for s=1:length(sub_list)
    sub=string(sub_list{s});
    sub_folder=sprintf('%s/data/ABCD/sub-%s/ses-baselineYear1Arm1/func',base_dir,sub);

    FC.pearsons(:,:,s)=dlmread(sprintf('%s/Schaef_300_pearsons.csv',sub_folder));
    FC.spearmans(:,:,s)=dlmread(sprintf('%s/Schaef_300_spearmans.csv',sub_folder));
    FC.p_corr(:,:,s)=dlmread(sprintf('%s/Schaef_300_partial_corr.csv',sub_folder));
    FC.glasso_p_corr(:,:,s)=dlmread(sprintf('%s/Schaef300_glasso_pcorr.csv',sub_folder));
    FC.MI_time(:,:,s)= dlmread(sprintf('%s/Schaef_300_mutual_info_time.csv',sub_folder));
    FC.MI_freq(:,:,s)= dlmread(sprintf('%s/Schaef_300_mutual_info_freq.csv',sub_folder));
    FC.spec_coh(:,:,s)= dlmread(sprintf('%s/Schaef_300_spectral_coh.csv',sub_folder));
    FC.wav_coh(:,:,s)= dlmread(sprintf('%s/Schaef_300_wavelet_coh.csv',sub_folder));
    FC.synergy(:,:,s)= dlmread(sprintf('%s/Schaef_300_synergy.csv',sub_folder));
    FC.redundancy(:,:,s)= dlmread(sprintf('%s/Schaef_300_redundancy.csv',sub_folder));
    FC.reg_DCM(:,:,s)= dlmread(sprintf('%s/Schaef_300_reg_DCM.csv',sub_folder));
    disp(s)
end

% Save all FC
FC_name_out=sprintf('%s/data/ABCD_results/FC/recommended_fmri_inclusions.mat',base_dir);
save(FC_name_out,"FC", '-v7.3')

%% Calculate motion exclusions
over_5mm=false(1,length(sub_list));
over_cens=false(1,length(sub_list));
suprathreshold_exclude=false(1,length(sub_list));
for s=1:length(sub_list)
    sub=string(sub_list{s});
    sub_folder=sprintf('%s/data/ABCD/sub-%s',base_dir,sub);
    
    motion_params=dlmread(sprintf('%s/ses-baselineYear1Arm1/func/mc/prefiltered_func_data_mcf.par',sub_folder));
    motion_params=motion_params(:,1:6);
    sub_orig_FD=mband_powerFD(motion_params,tr);
    %sub_orig_FD=GetFDPower(motion_params);

    sub_orig_FD(1)=0;
    orig_FDm(s) = (mean(sub_orig_FD));
    
    high_frames=sub_orig_FD>0.3;
    high_frames_percent = sum(high_frames==1) / numel(high_frames);
    if high_frames_percent>0.2
        suprathreshold_exclude(:,s)=true;
    end
    clear high_frames
    if any(sub_orig_FD > 5)
        over_5mm(:,s)=true;
    end
    
   
    cens_frames=calc_censored_frames(sub,sub_orig_FD);

    % censor if more than half their frames are missing
    n_frames=size(cens_frames,1)/2;
    n_cens=sum(cens_frames==0);
    if n_cens>n_frames
        over_cens(s)=true;
    end

end

% merge exclusion criteria
over_3mm_thresh = orig_FDm>0.3;
over_FD_thresh = or(over_3mm_thresh, over_5mm);
over_FD_thresh = or(over_FD_thresh, suprathreshold_exclude);
over_FD_thresh = or(over_FD_thresh, over_cens);
under_FD_thresh = ~over_FD_thresh;
FDm_under_thresholds = orig_FDm(under_FD_thresh);
sub_list=sub_list(under_FD_thresh);

% Exclude
fns=fieldnames(FC);
for i=1:length(fns)
    FC_low_motion.(fns{i})=FC.(fns{i})(:,:,under_FD_thresh);
end

%% Save motion excluded FC
FC_name_out=sprintf('%s/data/ABCD_results/FC/stringent_motion_exclusions_FC.mat',base_dir);
save(FC_name_out,"FC_low_motion", '-v7.3')

%% Save mean FD
recommended_mFD_out_file=sprintf('%s/data/ABCD_results/FC/recommended_fmri_inclusions_mean_FD.csv',base_dir);
dlmwrite(recommended_mFD_out_file, orig_FDm');

stringent_FD_out_file=sprintf('%s/data/ABCD_results/FC/stringent_motion_exclusions_mean_FD.csv',base_dir);
dlmwrite(stringent_FD_out_file, FDm_under_thresholds');

% Save reduced sub list
stringent_sub_list_file = sprintf('%s/data/ABCD/stringent_sub_list_exclusions.csv',base_dir);
writecell(sub_list, stringent_sub_list_file)

%% Visualise
addpath(genpath('/home/kanep/kg98_scratch/Kane/utils/cbrewer'));
cmap=cbrewer('div','RdBu',11);
cmap=flipud(cmap);

load /home/kanep/kg98_scratch/Kane/FC_estimations/data/HCP_results/FC/stringent_motion_exclusions_FC.mat
fns=fieldnames(All_FC);

for i=1:length(fns)
    curr_FC=All_FC.(fns{i});
    mean_FC(:,:,i)=mean(curr_FC,3);
end

original_measures_index=[1,3,5,6,7,9,11,13,15,16,17];
mean_FC=mean_FC(:,:,original_measures_index);

names={'Pearson', 'Spearman', 'Partial correlation', 'GLASSO', ...
    'Mutual information (time)','Mutual information (frequency)',...
    'Spectral coherence', 'Wavelet coherence', 'Synergy', 'Redundancy', 'Regression DCM'};

for mat=1:length(names)
    subplot(3,4,mat)
    imagesc(mean_FC(:,:,mat)); colormap(cmap); colorbar; title(names{mat})
end

%% Cluster average matrices
% --- assume mean_FC, names already in workspace

% 1) Vectorize upper?triangle
N = size(mean_FC,1);
Mvec = zeros(90000,11);
for k = 1:numel(names)
    Mvec(:,k) = reshape(mean_FC(:,:,k),1,[]);
end
Mvec(Mvec==Inf)=0;
% 2) Compute distance
R = corr(Mvec);
D = 1 - R;
Y = squareform(D);          % condensed vector

% 3) Hierarchical clustering + optimal leaf order
Z = linkage(Y,'average');
leafOrder = optimalleaforder(Z, Y);

% 4) Plot, using the SAME leafOrder for both panels
%% FIGURE 1: Dendrogram alone
figure;
[~,~,perm] = dendrogram(Z, 0, ...
                       'Orientation','left', ...
                       'Reorder', leafOrder);

% remove spines
ax = gca;
ax.Box = 'off';
ax.XRuler.Axle.Visible = 'off';
ax.YRuler.Axle.Visible = 'off';

% flip so leafOrder(1) is at the top
set(gca, ...
    'YDir', 'reverse', ...
    'TickDir','out', ...
    'YTick', 1:numel(names), ...
    'YTickLabel', names(perm) ...
);
title('FC-Measure Clustering');


%% FIGURE 2: Heatmap with blue scale + overlaid values with adaptive color
figure(2);
M = R(leafOrder, leafOrder);    % reorder R

imagesc(M);
axis square;

% sequential blues
cmap_blue = cbrewer('seq','Blues', 100);
colormap(cmap_blue);
hcb = colorbar;
ylabel(hcb, 'Correlation');

% tick labels
set(gca, ...
    'XTick', 1:numel(names), ...
    'XTickLabel', names(leafOrder), ...
    'XTickLabelRotation', 45, ...
    'YTick', 1:numel(names), ...
    'YTickLabel', names(leafOrder), ...
    'TickDir', 'out'      );
title('Pairwise FC-Matrix Correlation');

% get colormap midpoint in data units
clim = get(gca,'CLim');
mid = mean(clim);

% overlay numeric values with adaptive color
textFmt = '%.2f';
for i = 1:numel(names)
    for j = 1:numel(names)
        % choose white on dark bg, black on light bg
        if M(i,j) > mid
            txtColor = 'w';
        else
            txtColor = 'k';
        end
        text(j, i, sprintf(textFmt, M(i,j)), ...
             'HorizontalAlignment','center', ...
             'FontSize',8, ...
             'Color', txtColor);
    end
end