function distance = distance(start_pos, end_pos, Fs)
%distance �������������������㣬�Ͳ�����Fs�������
    time = (end_pos - start_pos) / Fs;
    distance = 340 * time;
end

