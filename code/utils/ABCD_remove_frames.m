function ABCD_remove_frames(func_dir, sub)
    cd(func_dir)
    manaf_list=readtable('/home/kanep/kg98_scratch/Kane/FC_estimations/data/ABCD/MRI_manafacturer_list.csv');
    fmri_list=dir(fullfile(func_dir, '*run*.nii*'));
    confs_list=dir(fullfile(func_dir, '*run*.tsv*'));
    
    sub=string(sub);
    sub_manafac=manaf_list(manaf_list.subject_ID == sub, :);

    for i=1:length(fmri_list)
        fmri=niftiread(fmri_list(i).name);
        fmri_info=niftiinfo(fmri_list(i).name);
        curr_confs=readtable(confs_list(i).name,  'FileType', 'text', 'Delimiter', '\t');

        if ismember(sub_manafac.mri_info_manufacturer, {'SIEMENS', 'Philips Medical Systems'})
            fmri_fremv=fmri(:,:,:,9:end);
            curr_confs_fremv=curr_confs(9:end,:);
        elseif contains(sub_manafac.mri_info_softwareversion ,'DV25')
            fmri_fremv=fmri(:,:,:,6:end);
            curr_confs_fremv=curr_confs(6:end,:);
        elseif contains(sub_manafac.mri_info_softwareversion ,'DV26')
            fmri_fremv=fmri(:,:,:,13:end);
            curr_confs_fremv=curr_confs(13:end,:);
        end
        table_out=sprintf('motion_confs_frem_run%d.csv',i);
        writetable(curr_confs_fremv, table_out)

        fmri_info.ImageSize=size(fmri_fremv);
        fmri_file_out=sprintf('frames_removed_run0%d',i);
        niftiwrite(fmri_fremv, fmri_file_out, fmri_info)
        delete(fmri_list(i).name)
        delete(confs_list(i).name)
        
    end
end