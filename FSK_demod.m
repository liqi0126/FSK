M = 2;         % Modulation order
k = log2(M);   % Bits per symbol
EbNo = 100;      % Eb/No (dB)
nsamp = 100;     % Number of samples per symbol
freqsep = 20000;  % Frequency separation (Hz)

[signal, Fs] = audioread('sound.wav');


dataOut = fskdemod(signal,M,freqsep,nsamp,Fs);