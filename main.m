function [y_pred,clusterNum] = main(X, spLabel, m, c,p_value,lambda,gamma,iter_num,r)
%%
% Input:
%       X: 2D data matrix, each column is a pixel(sample). spLabel:
%       superpixel labels, column vector m: anchor number (superpixel
%       number). cluster_n: cluster number. r: Projection dimension.
% Output:
%       y_pred: Predict labels Z: anchor graph, n by m S: anchor-anchor
%       graph, m by m. W: projection matrix. clusternum: The number of
%       connected components of 'S'.
%%

%% init

view_num = get_viewnum;
S = cell(1,view_num);
J = cell(1,view_num);
Y = cell(1,view_num);

alpha = ones(1,view_num)/view_num;
beta = ones(1,view_num)/view_num;
beta = gpuArray(beta);
alpha = gpuArray(alpha);

k = 5;
A = initA(X, spLabel,m); % generate anchors
X = cellfun(@gpuArray, X, 'UniformOutput', false);
A = cellfun(@gpuArray, A, 'UniformOutput', false);
m = gpuArray(m);
k = gpuArray(k);
c = gpuArray(c);
% Z = updateZ(X, A, k);
Z = initZ(X,A,k,alpha);
W = initW(X,A,Z,r);

for v = 1:view_num
    rng(8);%随机化种子
    S{v} = rand(m,m);
    S{v} = S{v} ./ sum(S{v}, 1); % 每列的和为 1
    J{v} = zeros(m,m);
    Y{v} = zeros(m,m);
end

mu = 0.0001; mu_max = 10e12; eta = 1.1;

mu = gpuArray(mu);
mu_max= gpuArray(mu_max);
eta = gpuArray(eta);
lambda = gpuArray(lambda);
gamma = gpuArray(gamma);
k = gpuArray(k);
p_value = gpuArray(p_value);
S = cellfun(@gpuArray, S, 'UniformOutput', false);
J = cellfun(@gpuArray, J, 'UniformOutput', false);
Y = cellfun(@gpuArray, Y, 'UniformOutput', false);
%% 10、15迭代次数
for iter1 = 1:iter_num


%     Z = updateZ(X, A, k, alpha);  % Z first, requires current A
    Z = updateZ(X, A, k,W,alpha);

    A = updateA(X, Z, S, alpha, beta);  % A second, requires Z and possibly S

%     alpha = updateAlpha(X, A, Z);  % alpha, depends on updated A and Z
    alpha = updateAlpha(W,X,A,Z);

%     beta = updateBeta(A, S);  % beta, after A before new S
    beta = updateBeta(A,S,W);

    [F, ~] = updateF(S, alpha, c);  % F can be here, depends on S and alpha

%     S = updateS(A, F, J, Y, beta, mu, gamma);  % S, depends on updated A, F, J, Y
    S = updateS(A,F,J,Y,W,beta,mu,gamma);

    [J, Y] = updateJ(S, Y, p_value, mu, lambda);  % J and Y together, after S

    Y = updateY(Y, S, J, mu);  % Y again if necessary, consider dependencies

    W = updateW(X,A,Z,S,alpha,beta,r);
    
    mu = min(mu * eta, mu_max);

end
% S = cellfun(@gather, S, 'UniformOutput', false);
% fprintf('\n');

Final_S = weighted_average(S, beta);%按权重累加每个模态的
Final_Z = weighted_average(Z, alpha);
Final_Z = gather(Final_Z);
clear Z;
Z = Final_Z;
Final_S = gather(Final_S);
c = gather(c);
[~,~,S0] = CLR(Final_S',c);%秩约束 有聚类个数的连通分量
[U_label]=conncomp(graph(sparse(S0)));%锚点标签矩阵

% 硬标签传播
[~, X_subLabel] = max(Z,[],2);
y_pred = zeros(size(Z,1),1);
for ii = 1:m
    y_pred(X_subLabel == ii) = U_label(ii);
end


% %软标签传播
% C = gather(c);  % 类别数
% U_onehot = zeros(m, C);
% for j = 1:m
%     U_onehot(j, U_label(j)) = 1;
% end
% pixel_scores = Z * U_onehot;  % Z: n × m, U_onehot: m × C
% [~, y_pred] = max(pixel_scores, [], 2);
% 
% 



clusterNum = length(unique(y_pred));
fprintf("clusterNum:%d",clusterNum);
if clusterNum == c
    disp('聚类数正确');
else
    disp('聚类数不正确');
end

end
