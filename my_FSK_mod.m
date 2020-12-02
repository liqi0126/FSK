function signal = my_FSK_mod(code, Fs, duration, f0, f1)
% code: squence to encode
% Fs: sampling frequence
% duration: hold-on time
% f0: freqency for code 0
% f1: freqency for code 1

cLen = length(code);

window = ceil(Fs * duration);
t = (0:window-1) / Fs;
sig0 = sin(2*pi*f0*t);
sig1 = sin(2*pi*f1*t);

signal = zeros(1, window*cLen);

for i = 1:cLen
    if code(i) == 0
        signal((i-1)*window+(1:window)) = sig0;
    else
        signal((i-1)*window+(1:window)) = sig1;
    end
end

end

