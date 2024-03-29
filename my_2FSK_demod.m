function [recon_code, fft_diff, start, window] = my_2FSK_demod(signal, Fs, duration, f0, f1)
% code: squence to encode
% Fs: sampling frequence
% duration: hold-on time
% f0: freqency for code 0
% f1: freqency for code 1


window = ceil(Fs * duration);

[~, n] = size(signal);
if n == 1
   signal = signal'; 
end

signal = [zeros(1, window), signal];

hd = design(fdesign.bandpass('N,F3dB1,F3dB2',6, f0-500, f1+500, Fs),'butter');
%用定义好的带通滤波器对data进行滤波
signal = filter(hd,signal);

n = length(signal); %获取数据的长度值

fft_diff = zeros(1, n);
for i = 1:1:n-window
    %对从当前点开始的window长度的数据进行傅里叶变换
    y = fft(signal(i:i+window-1));
    y = abs(y);
    %得到目标频率傅里叶变换结果中对应的index
    index_impulse0 = round(f0/Fs*window);
    index_impulse1 = round(f1/Fs*window);
    %考虑到声音通信过程中的频率偏移，我们取以目标频率为中心的5个频率采样点中最大的一个来代表目标频率的强度
    impulse_fft0 = max(y(index_impulse0-5:index_impulse0+5));
    impulse_fft1 = max(y(index_impulse1-5:index_impulse1+5));
    fft_diff(i) = impulse_fft1 - impulse_fft0;
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
recon_code = -1 * ones(1, code_num);
cursor = start;
for i=1:code_num
   range = 50;
   cursor_start = cursor - range;
   cursor_end = cursor + range;
   if cursor_end > n
      cursor_end = n; 
   end
   if max(fft_diff(cursor_start:cursor_end)) > high/15
        recon_code(i) = 1;
   elseif min(fft_diff(cursor_start:cursor_end)) < -low/15
        recon_code(i) = 0;
   end
   cursor = cursor + window;
end

end