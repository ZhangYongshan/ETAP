
function obj = obj_value(X, A, Z, S, W, alpha, beta, lambda, gamma, J, Y, mu, delta, F)
% --------------------------------------------------------------
% Compute the objective value of Eq. (7)
% --------------------------------------------------------------
% Inputs:
%   X, A, Z, S, W  : cell arrays for each modality
%   alpha, beta    : modality weights
%   lambda, gamma, mu, delta : hyperparameters
%   J, Y           : auxiliary and Lagrange multiplier terms
%   F              : cluster embedding (from updateF)
% Output:
%   obj            : scalar objective value
% --------------------------------------------------------------

view_num = numel(X);
total = 0;

for v = 1:view_num
    % === 第一项: 重建误差项 ∑ ||WᵗX - U||² * z ===
    diffXZ = W{v}' * X{v} - A{v};
    term1 = sum(sum((diffXZ.^2) .* Z{v})) / alpha(v);
    
    % === 第二项: δ * ||Z||_F² ===
    term2 = delta * norm(Z{v}, 'fro')^2;
    
    % === 第三项: (1/β) * ||U - US||_F² ===
    term3 = (1 / beta(v)) * norm(A{v} - A{v} * S{v}, 'fro')^2;
    
    % 累加模态项
    total = total + term1 + term2 + term3;
end

% === 第四项: λ * ||J||ₚ^⊕ （近似为 Frobenius 范数）===
term4 = lambda * sum(cellfun(@(jv) norm(jv, 'fro')^2, J));

% === 第五项: 2γ * tr(Fᵀ L_S F) ===
Ls = construct_laplacian(S); % 需要你已有的图拉普拉斯函数
term5 = 2 * gamma * trace(F' * Ls * F);

% === 第六项: <Y, S - J> + (μ/2)||S - J||_F² ===
term6 = 0;
for v = 1:view_num
    term6 = term6 + sum(sum(Y{v} .* (S{v} - J{v}))) ...
                   + (mu/2) * norm(S{v} - J{v}, 'fro')^2;
end

obj = gather(total + term4 + term5 + term6);
end
