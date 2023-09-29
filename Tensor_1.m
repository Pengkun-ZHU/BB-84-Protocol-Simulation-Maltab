function [Mat] = Tensor_1(Mats)
% This function returns the tensor products of N matrices (or vectors).
% Input: A cell of matrices, {A, B, C}, where A, B, and C are matrices.
% Ouput: A tensor B tensor C.
% Example: D = tensor({A, B, C}).

Mat = 1;
N = numel(Mats);

for n = 1:N
   Mat = kron(Mat, Mats{n}); 
end

end