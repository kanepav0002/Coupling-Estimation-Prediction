function estimate_FC(sub_name, sub_folder, ts_file, base_dir, tr, f1, f2)
    %Function to calculate FC in the following ways....
    % sub_name = subject ID
    % sub_folder = folder where the subjects ts is store
    % ts_file = the file to be parcellated (txp) where p is parcels and t
    % is time
    % tr = repitition time of the fMRI scan (in seconds)
    % f1 & f2 = the frequency range to average across (i.e. the values of
    % the bandpass filter used).

    sub_name="NDARINV0C471G23";
    sub_folder="/home/kanep/kg98_scratch/Kane/FC_estimations/data/ABCD/sub-NDARINV0C471G23/ses-baselineYear1Arm1/func";
    ts_file="fsl_parc_ts.txt";
    base_dir="/home/kanep/kg98_scratch/Kane/FC_estimations";
    tr= 0.8;
    f1=0.008;
    f2=0.08;

    addpath(genpath(sprintf('%s/code/utils',base_dir)));
    addpath(genpath(sprintf('%s/utils/Wavelet_Coherence',base_dir)));
    addpath(genpath(sprintf('%s/utils/Functional Connectivity Toolbox',base_dir)));
    addpath(genpath(sprintf('%s/utils/PhiID',base_dir)));
    addpath(genpath(sprintf('%s/utils/tapas-master/rDCM',base_dir)));
    
    tr=str2num(tr);
    f1=str2num(f1);
    f2=str2num(f2);
    bandpass=[f1,f2];

    ts=dlmread(sprintf('%s/%s',sub_folder,ts_file));

    % Pearsons Correlation
    pearsons=corr(ts);
    pearsons=atanh(pearsons);
    disp('Pearsons Done')

    % Spearmans Rank Correlation
    spearmans=corr(ts, 'type','Spearman');
    spearmans=atanh(spearmans);
    disp('Spearmans done')
    
    % Partial Correlation
    % Takes about 15 minutes
    p_corr=partialcorr(ts);
    p_corr = p_corr - (diag(diag(p_corr)));
    disp('Partial Correlation Done')
    
    % Mutual Information (time)
    % Takes about 30 Minutes
    nNodes = size(ts, 2);
    MI_time = zeros(nNodes);
    for i = 1:nNodes-1
        y1 = ts(:, i);
        for j = i+1:nNodes
            y2 = ts(:, j);
            MI = computeNMI(y1, y2);
            MI_time(i, j) = MI;
        end
    end
    MI_time = MI_time + MI_time';
    disp('Mutual Information - Time done')

    % Mutual Information (frequency).
    nNodes = size(ts, 2);
    MI_freq = zeros(nNodes);
    for i = 1:nNodes-1
        y1 = ts(:, i);
        for j = i+1:nNodes
            y2 = ts(:, j);
            MI_freq(i, j) = mutualinf(y1, y2, 1/tr, f1, f2);
        end
    end
    MI_freq = MI_freq + MI_freq';
    disp('Mutual Information - Frequency done')

    % Spectral Coherence Based on Functional Connectiviy toolbox
    % Takes about 35 minutes
    nNodes = size(ts, 2);
    S_coh = zeros(nNodes);
    for i = 1:nNodes-1
        y1 = ts(:, i);
        for j = i+1:nNodes
            y2 = ts(:, j);
            [c, f] = coh(y1, y2, size(ts, 1), 1/tr);
            S_coh(i, j) = mean(c(f>f1 & f<f2));
        end
    end
    S_coh = S_coh + S_coh';
    disp('Spectral Coherence done')

    % Wavelet Coherence
    % Implementation based on Grinsted toolbox
    % Grinsted, A., J. C. Moore, S. Jevrejeva (2004), Application of the cross wavelet transform and wavelet coherence to geophysical time series, Nonlin. Process. Geophys., 11, 561566
    % Takes about 2 Hours
    nNodes = size(ts,2);
    cohij = zeros(nNodes);
    for i = 1:nNodes-1
        for j = i+1:nNodes
            [Rsq,period,~] = wtc(ts(:,i),ts(:,j),'mcc',0);
            freq = 1./(period*tr);
            cohij(i,j) = mean(mean(Rsq(freq<bandpass(2)&freq>bandpass(1),:)));
        end
    end
    Wav_coh = cohij +cohij';
    disp('Wavelet Coherence done')

    % Integrated Information Decomposition
    % Takes about an hour
    ts_inv=ts';
    for row = 1:size(ts_inv,1)
        for col = 1:size(ts_inv,1)
        
        if row~=col
            atoms = PhiIDFull([ts_inv(row,:); ts_inv(col,:)]);
            synergy_mat(row,col) = atoms.sts;
            redundancy_mat(row,col) = atoms.rtr;
        end
        end
    end
    IID_gradient = floor(tiedrank(mean(synergy_mat))) - floor(tiedrank(mean(redundancy_mat)));
    
    non_zero_synergy=synergy_mat(synergy_mat~=0);
    non_zero_redundancy=redundancy_mat(redundancy_mat~=0);
    min_synergy=min(non_zero_synergy);
    min_redundancy=min(non_zero_redundancy);

    synergy_mat = synergy_mat - diag(diag(synergy_mat)) + diag(min_synergy * ones(1, size(synergy_mat, 1)));
    redundancy_mat = redundancy_mat - diag(diag(redundancy_mat)) + diag(min_redundancy * ones(1, size(redundancy_mat, 1)));

    disp('Integrated Information Decomposition done')
    % Regression Dynamic Causal Modelling 
    % Using the tapas rDCM toolbox: https://github.com/translationalneuromodeling/tapas/tree/master/rDCM
    % Load your parcellated time series (e.g., 200 time points × 5 regions)
    Y.y=ts;
    Y.dt=tr;
    DCM_model=tapas_rdcm_model_specification(Y,[],[]);
    
    [econn, options] = tapas_rdcm_estimate(DCM_model,'r',[],1);
    rDCM_connectiv = econn.Ep.A;
    disp('Regression DCM done')
    disp('saving mats')

    %% Save FC Mats

    FC_mats=cat(3,pearsons, spearmans,p_corr,MI_time,MI_freq,S_coh, Wav_coh, ...
        synergy_mat, redundancy_mat, rDCM_connectiv);
    names={'pearsons', 'spearmans', 'partial_corr', 'mutual_info_time', ...
        'mutual_info_freq','spectral_coh', 'wavelet_coh', 'synergy', 'redundancy', 'reg_DCM'};

    for mat=1:length(names)
        out_name=sprintf('%s/Schaef_300_%s.csv',sub_folder,names{mat});
        out_mat=FC_mats(:,:,mat);
        dlmwrite(out_name,out_mat);
    end
   
    %% Visualise all
    % 
    % %load glasso
    % glasso_p_corr = dlmread(sprintf('%s/Schaef300_glasso_pcorr.csv',sub_folder));
    % 
    % % load others
    % pearsons = dlmread(sprintf('%s/Schaef_300_pearsons.csv',sub_folder));
    % spearmans = dlmread(sprintf('%s/Schaef_300_spearmans.csv',sub_folder));
    % p_corr = dlmread(sprintf('%s/Schaef_300_partial_corr.csv',sub_folder));
    % MI_time = dlmread(sprintf('%s/Schaef_300_mutual_info_time.csv',sub_folder));
    % MI_freq = dlmread(sprintf('%s/Schaef_300_mutual_info_freq.csv',sub_folder));
    % S_coh = dlmread(sprintf('%s/Schaef_300_spectral_coh.csv',sub_folder));
    % Wav_coh = dlmread(sprintf('%s/Schaef_300_wavelet_coh.csv',sub_folder));
    % synergy_mat = dlmread(sprintf('%s/Schaef_300_synergy.csv',sub_folder));
    % redundancy_mat = dlmread(sprintf('%s/Schaef_300_redundancy.csv',sub_folder));
    % rDCM_connectiv = dlmread(sprintf('%s/Schaef_300_reg_DCM.csv',sub_folder));
    % 
    % 
    % FC_mats=cat(3,pearsons, spearmans,p_corr,glasso_p_corr,MI_time,MI_freq,S_coh, ...
    %     Wav_coh, synergy_mat, redundancy_mat, rDCM_connectiv);
    % names={'pearsons', 'spearmans', 'partial correlation', 'Glasso reg par corr', 'mutual info time', ...
    %     'mutual info freq','spectral coherence', 'wavelet coherence', 'synergy', 'redundancy', 'reg DCM'};
    % 
    % for mat=1:length(names)
    %     subplot(3,4,mat)
    %     imagesc(FC_mats(:,:,mat)); colormap("jet"); colorbar; title(names{mat})
    % end


