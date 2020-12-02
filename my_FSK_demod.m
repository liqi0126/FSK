function [code, fft_diff, start, window] = my_FSK_demod(signal, Fs, duration, f0, f1)
% code: squence to encode
% Fs: sampling frequence
% duration: hold-on time
% f0: freqency for code 0
% f1: freqency for code 1

signal = [zeros(1, 500), signal];

hd = design(fdesign.bandpass('N,F3dB1,F3dB2',6, f0-500, f1+500, Fs),'butter');
%用定义好的带通滤波器对data进行滤波
signal = filter(hd,signal);

window = ceil(Fs * duration);

[~, n] = size(signal);%获取数据的长度值
if n == 1
    [n, ~] = size(signal);
end

fft_diff = zeros(1, n);
for i = 1:1:n-window
    %对从当前点开始的window长度的数据进行傅里叶变换
    y = fft(signal(i:i+window-1));
    y = abs(y);
    %得到目标频率傅里叶变换结果中对应的index
    index_impulse0 = round(f0/Fs*window);
    index_impulse1 = round(f1/Fs*window);
    %考虑到声音通信过程中的频率偏移，我们取以目标频率为中心的5个频率采样点中最大的一个来代表目标频率的强度
%     impulse_fft0 = max(y(index_impulse0-2:index_impulse0+2));
%     impulse_fft1 = max(y(index_impulse1-2:index_impulse1+2));
%     fft_diff(i) = impulse_fft1 - impulse_fft0;
    fft_diff(i) = y(index_impulse1) - y(index_impulse0);
end


% 找到第一个波峰
total_max = max(abs(fft_diff));
activated = 0;
start = 0;
for i = window:1:n
    window_diff = abs(fft_diff(i) - fft_diff(i-window+1));
    if window_diff > total_max/2
        activated = 1;
    end
    if activated == 1 && window_diff < 5
        [~, start] = max(abs(fft_diff(1:i)));
        break
    end
end

% get code
high = max(fft_diff);
low = max(-fft_diff);
code_num = ceil((n - start) / window);
code = -1 * ones(1, code_num);
cursor = start;
for i=1:code_num
   if fft_diff(cursor) > high/15
       code(i) = 1;
   elseif fft_diff(cursor) < -low/15
       code(i) = 0;
   end
   cursor = cursor + window;
end

end

