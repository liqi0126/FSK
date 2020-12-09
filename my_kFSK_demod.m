function recon_code = my_kFSK_demod(signal, Fs, duration, f_seq)
% signal: the signal to decode
% Fs: sampling frequence
% duration: hold-on time
% f: freqency for code 0


window = ceil(Fs * duration);

[~, n] = size(signal);
if n == 1
   signal = signal';
   n = length(signal);
end

cLen = ceil(n / window);
cNum = length(f_seq);

hd = design(fdesign.bandpass('N,F3dB1,F3dB2',6, f_seq(1)-250, f_seq(cNum)+250, Fs),'butter');
signal = filter(hd,signal);

code_impulse_pos = zeros(1,cNum);
for i = 1:cNum
    code_impulse_pos(i) = round(f_seq(i)/Fs*window);
end

recon_code = -1 * ones(1, cLen);
for i = 1:cLen
    y = fft(signal((i-1)*window+(1:window)));
    y = abs(y);
    [~, impulse_pos] = max(y);
    [~, code] = min(abs(code_impulse_pos - impulse_pos));
    recon_code(i) = code - 1;
end

end

