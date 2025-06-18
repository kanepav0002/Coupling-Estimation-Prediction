function thresholded_matrix = match_sparsity(glasso_matrix, other_matrix)
% Thresholds a Pearson's matrix to match the sparsity level of a GLASSO matrix
%
% Inputs:
%   glasso_matrix    : Symmetric sparse matrix from GLASSO (300x300)
%   pearsons_matrix  : Symmetric other matrix you want to match sparsity (300x300)
%
% Output:
%   thresholded_matrix : Pearson's matrix with sparsity matched to GLASSO

n = size(glasso_matrix, 1);

% 1. Calculate number of non-zero upper-triangle elements in GLASSO matrix
nnz_glasso = nnz(triu(glasso_matrix, 1));

% 2. Extract upper triangle of Pearson's matrix (excluding diagonal)
upper_pearsons = triu(other_matrix, 1);
abs_upper = abs(upper_pearsons);

% 3. Find threshold to retain the same number of non-zeros as GLASSO
[~, sorted_idx] = sort(abs_upper(:), 'descend');
keep_idx = sorted_idx(1:nnz_glasso);

% 4. Create thresholding mask
mask_upper = false(size(upper_pearsons));
mask_upper(keep_idx) = true;

% 5. Apply mask to upper triangle
upper_thresholded = upper_pearsons .* mask_upper;

% 6. Construct symmetric matrix from thresholded upper triangle
thresholded_matrix = upper_thresholded + tril(upper_thresholded.', -1);

% 7. Restore original diagonal values
thresholded_matrix(1:n+1:end) = diag(other_matrix);
end