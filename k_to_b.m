function seq_base2 = k_to_b(seq_basek, k)
    % k can be 4, 8, 16 ...
    seqk_len = length(seq_basek);
    seq2_len = seqk_len * k / 2;
    code_len = log2(k);
    seq_base2 = zeros(1, seq2_len);
    for i = 1:seqk_len
        c = seq_basek(i);
        for j = code_len:-1:1
            seq_base2((i-1)*code_len+j) = mod(c, 2);
            c = fix(c/2);
        end
    end
end

