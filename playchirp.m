function playchirp(f0,f1,T,method)
Fs = 48000;

t = 0:1/Fs:T;
signal = chirp(t, f0, T, f1,method);

sound(signal, Fs);
end

