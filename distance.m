function distance = distance(start_pos, end_pos, Fs)
%distance 根据声音传播的两个点，和采样率Fs计算距离
    time = (end_pos - start_pos) / Fs;
    distance = 340 * time;
end

