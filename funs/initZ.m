function [Z] = initZ(X, anchor,k,alpha)
%% 初始化Z 当没有投影矩阵的时候用这个公式
view_num = get_viewnum;%获取模态并转为gpu
view_num = gpuArray(view_num);
Z = cell(1, view_num);%初始化锚图
[~, num] = size(X{1});
[~,numAnchor] = size(anchor{1});
% distX = zeros(num,numAnchor);
for v = 1: view_num
    distX = (pdist2((X{v})',(anchor{v})')).^2*(1/alpha(v));%计算样本和锚点之间欧式距离
    Z_tmp = gpuArray.zeros(num, numAnchor);
    [~, idx] = sort(distX, 2);
    id = idx(1:num,1:k+1);%取前k+1个锚点
    indices = sub2ind(size(distX),repmat((1:num)',[1,k+1]),id);
    di = distX(indices);
    Z_tmp(indices) = (di(:,k+1)-di)./(k.*di(:,k+1)-sum(di(:,1:k),2)+eps);%构造局部坐标图的一种Soft KNN归一化权重策略
    Z{v} = Z_tmp;
end

end 
