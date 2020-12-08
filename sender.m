fileID = fopen('data.bin', 'r');
code = fread(fileID);
code = code';

Fs = 48000;


% f0 = 10500;
% f1 = 12500;
% duration = 10*pi/f0;

f0 = 4000;
f1 = 6000;
duration = 0.025;



signal = my_FSK_mod(code, Fs, duration, f0, f1);

signal = [zeros(1,500), signal, zeros(1,500)];

sound(signal, Fs);