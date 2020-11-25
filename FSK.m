M = 2;         % Modulation order
k = log2(M);   % Bits per symbol
EbNo = 100;      % Eb/No (dB)
Fs = 48000;       % Sample rate (Hz)
nsamp = 100;     % Number of samples per symbol
freqsep = 20000;  % Frequency separation (Hz)

data = randi([0 M-1],5000,1);

txsig = fskmod(data,M,freqsep,nsamp,Fs);

rxSig  = awgn(txsig,EbNo+10*log10(k)-10*log10(nsamp), 'measured',[],'dB');

sound(real(txsig), Fs);

dataOut = fskdemod(rxSig,M,freqsep,nsamp,Fs);

% [num,BER] = biterr(data,dataOut);