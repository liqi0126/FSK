M = 2;
freqSep = 100;

fskMod = comm.FSKModulator(M,freqSep);
fskDemod = comm.FSKDemodulator(M,freqSep);

ch = comm.AWGNChannel('NoiseMethod', ...
    'Signal to noise ratio (SNR)','SNR',-2);

err = comm.ErrorRate;

for counter = 1:100
    data = randi([0 M-1],50,1);
    modSignal = step(fskMod,data);
    noisySignal = step(ch,modSignal);
    receivedData = step(fskDemod,noisySignal);
    errorStats = step(err,data,receivedData);
end

es = 'Error rate = %4.2e\nNumber of errors = %d\nNumber of symbols = %d\n';
fprintf(es,errorStats)