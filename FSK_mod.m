M = 2;         % Modulation order
k = log2(M);   % Bits per symbol
EbNo = 10;      % Eb/No (dB)
Fs = 16;       % Sample rate (Hz)
nsamp = 8;      % Number of samples per symbol
freqsep = 10;  % Frequency separation (Hz)

fileID = fopen('data.bin', 'r');
data = fread(fileID);

env = fskmod(data,M,freqsep,nsamp,Fs);

env_len = length(env);
fc = 200;
t = (0:1/env_len:1-1/env_len);

mod = sqrt(2)*real(env.*exp(2j*pi*fc*t)');


dem = hilbert(mod).*exp(-2j*pi*fc*t)'/sqrt(2);


dataOut = fskdemod(dem, M, freqsep, nsamp, Fs);
% audiowrite('sound.wav', real(signal), Fs);