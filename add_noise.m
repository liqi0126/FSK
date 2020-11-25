function [noisy_signal] = add_noise(signal)
    noisy_signal = [zeros(1,500), signal, zeros(1,500)];
    noisy_signal = awgn(noisy_signal, 0, 'measured');
end

