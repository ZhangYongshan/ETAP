function [Z] = updateZ(X, anchor, k,W,alpha)
%% construct anchor graph Z
% Input:
%       X: data matrix, d by n anchor: anchor matrix, d by m k: Number of
%       neighbors

%% 和FPFC要改成Zv（参考tensor）
view_num = get_viewnum;%获取模态并转为gpu
view_num = gpuArray(view_num);
if nargin < 4 %     初始化Z，nargin传入参数的个数
    alpha = ones(view_num, 1);% 如果没有传 alpha，就默认每个模态权重一样
end

[~, num] = size(X{1});%样本数
[~,numAnchor] = size(anchor{1});%锚点数
Z = cell(1, view_num);%初始化锚图
% distX = gpuArray.zeros(num,numAnchor);
start = tic;
for v = 1: view_num
    distX = (pdist2((W{v}'*X{v})',( W{v}'*anchor{v})')).^2*(1/alpha(v));%计算样本和锚点之间欧式距离，加了投影
    Z_tmp = gpuArray.zeros(num, numAnchor);
    [~, idx] = sort(distX, 2);
    id = idx(1:num,1:k+1);%取前k+1个锚点
    indices = sub2ind(size(distX),repmat((1:num)',[1,k+1]),id);
    di = distX(indices);
    Z_tmp(indices) = (di(:,k+1)-di)./(k.*di(:,k+1)-sum(di(:,1:k),2)+eps);%构造局部坐标图的一种Soft KNN归一化权重策略
    Z{v} = Z_tmp;
    clear distX Z_tmp id indices di idx;
end
fprintf("更新Z耗时:%.2f",toc(start));
end




