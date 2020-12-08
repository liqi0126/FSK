Fs = 48000;
f0 = 3000;
f1 = 5000;
T = 1;

t = 0:1/Fs:T;
signal = chirp(t, f0, T, f1);


flow = [zeros(1,100000), signal, zeros(1,1000000), signal, zeros(1,100000)];

% plot(flow);

sound(signal, Fs);