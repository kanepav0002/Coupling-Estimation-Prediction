function splitImages(sub_dir, spmdir)

% register fMRI to T1 and then both to MNI using ANTS
    func_dir=append(sub_dir,'/func');
    cd(func_dir)
    addpath(genpath(spmdir))
    % Get list of fmri files
    func_list=dir(fullfile(func_dir, '*run*.nii'));

    for f=1:length(func_list)
        curr_file=func_list(f).name;
        run=append('run', string(f));
        mkdir(run)
        spm_file_split(curr_file, char(run));

    end

end
