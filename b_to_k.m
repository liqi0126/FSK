function seq_basek = b_to_k(seq_base2, k)
    % k can be 4, 8, 16 ...
    seq2_len = length(seq_base2);
    seqk_len = ceil(seq2_len * 2 / k);
    seq_base2 = [seq_base2, zeros(1, seqk_len * k / 2 - seq2_len)];
    code_len = log2(k);
    seq_basek = zeros(1, seqk_len);
    for i = 1:seqk_len
        c = 0;
        for j=1:code_len
            c = c + seq_base2((i-1)*code_len + j) * 2^(code_len - j);
        end
        seq_basek(i) = c;
    end
end

