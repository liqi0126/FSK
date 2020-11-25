fileID = fopen('data.bin', 'r');
code = fread(fileID);
code = code';




f0 = 10500;
f1 = 12500;
duration = 10*pi/f0;

% f0 = 4500;
% f1 = 8500;
% duration = 10*pi/f0;

[signal, Fs] = audioread('sound.wav');
signal = signal(:,1).';
[recon_code, fft_diff, start, window] = my_FSK_demod(signal, Fs, duration, f0, f1);

len = length(fft_diff);
figure;
plot(fft_diff);
hold on;
while start < len
    xline(start);
    start = start + window;
end