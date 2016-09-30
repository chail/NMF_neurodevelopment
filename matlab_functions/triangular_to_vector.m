function v = triangular_to_vector(A, offset)
% PURPOSE: obtain the upper triangular of an input matrix and reshape into
% a 1xn vector
% 
% INPUT:
% A: symmetric input matrix
% 
% offset: the kth diagonal to return elements on (see triu reference)
% 
% num_subjects: total number of subjects
%
% OUTPUT:
% v: upper triangular along and above specified offset reshaped into a
% vector
%--------------------------------------------------------------------------

n = size(A);
v = A(find(triu(ones(n), offset)));