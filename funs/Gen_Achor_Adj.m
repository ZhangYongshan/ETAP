function [S, D] = Gen_Achor_Adj(X, anchor, k, issymmetric)
%% code by wang xinxin 2022/08/20
% 修改：加入边界检查，防止 k+2 越界（ChatGPT 2025/07/17）
%
% 输入：
% X: each column is a data point ：d*n
% anchor: each column is a data point ： d*m
% k: number of neighbors
% issymmetric: set S = (S+S')/2 if issymmetric=1
% S: similarity matrix, each row is a data point
%
% 参考：F. Nie et al., AAAI 2016

if nargin < 4
    issymmetric = 1;
end
if nargin < 3
    k = 5;
end

[~, n] = size(X);
[~, m] = size(anchor);

% 计算距离矩阵
D = EuDist2(X', anchor', 0);  % D: n x m
[~, idx] = sort(D, 2);        % 每一行升序排列，列数为 m

S = zeros(n, m);
for i = 1:n
    max_valid_k = size(idx, 2) - 1;  % 可用邻居个数（除自身）
    k_used = min(k, max_valid_k);   % 实际使用的邻居数（不能超出范围）
    
    if k_used == 0
        continue;  % 没有可用邻居则跳过
    end

    id = idx(i, 2:k_used+1);  % 索引从第2列开始取 k_used 个
    di = D(i, id);

    % 使用鲁棒归一化方式构造权重
    S(i, id) = (di(end) - di) / (k_used * di(end) - sum(di) + eps);
end

% 是否对称化
if issymmetric == 1
    S = (S + S') / 2;
end


% function [S, D] = Gen_Achor_Adj(X,anchor,k, issymmetric)
% %% code by wang xinxin 2022/08/20
% % X: each column is a data point ：d*n
% % anchor: each column is a data point ： d*m
% % k: number of neighbors
% % issymmetric: set S = (S+S')/2 if issymmetric=1
% % S: similarity matrix, each row is a data point
% % Ref: F. Nie, X. Wang, M. I. Jordan, and H. Huang, The constrained
% % Laplacian rank algorithm for graph-based clustering, in AAAI, 2016.
% 
% if nargin < 3
%     issymmetric = 1;
% end;
% if nargin < 2
%     k = 5;
% end;
% 
% [~, n] = size(X);
% [~, m] = size(anchor);
% D = EuDist2(X', anchor',0);
% [~, idx] = sort(D, 2); % sort each row
% 
% S = zeros(n,m);
% for i = 1:n
%     id = idx(i,2:k+2);
%     di = D(i, id);
%     S(i,id) = (di(k+1)-di)/(k*di(k+1)-sum(di(1:k))+eps);
% end;
% 
% if issymmetric == 1
%     S = (S+S')/2;
% end;