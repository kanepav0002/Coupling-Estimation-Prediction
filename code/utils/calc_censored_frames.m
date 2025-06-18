function censored_frames = calc_censored_frames(sub,fd)

    censored_frames=fd<0.3;
 
    if sum(censored_frames(1:5)) < 5
        censored_frames(1:5)=0;
    end
    
    for i = 6:(length(censored_frames)-6)
        curr_val=censored_frames(i);
        before_sum=sum(censored_frames(i-4:i));
        after_sum=sum(censored_frames(i:i+4));
        middle_sum=(sum(censored_frames(i-2:i)))+(sum(censored_frames(i+1:i+2)));
        
        if before_sum <5 && after_sum <5 && middle_sum < 5
            censored_frames(i) = 0;
        end
    end
    
    n_frames=length(censored_frames);
    if sum(censored_frames(n_frames-5:end)) <5
        censored_frames(n_frames-5:end)=0;
    end
    
    % file_out=sprintf('%s/%s/func/censored_frames.txt',data_dir,sub);
    % dlmwrite(file_out,censored_frames)
    % disp(sub)
end