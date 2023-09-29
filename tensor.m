function [Mat] = tensor(Mats, T)
% This function returns the tensor products of N matrices (or vectors) (repeat T times).
% Input: A cell of matrices, {A, B, C}, where A, B, and C are matrices.
% Ouput: A tensor B tensor C.
% Example: D = tensor({A, B, C}, 1).

% Default value for T is 1.
if nargin < 2
    T = 1;
end

Mat = 1;
N = numel(Mats);

for t = 1:T
    for n = 1:N
        Mat = kron(Mat, sparse(Mats{n}));
    end
end

end