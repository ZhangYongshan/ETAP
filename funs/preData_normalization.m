function [X,labels_cell] = preData_normalization(data3D,num_Pixel,k)
% 对数据做了归一化
%% HSI data preprocessing
% Input:
%       data3D: 3D cube, HSI data.
% Output:
%       X:      new data, 2D matrix. each column is a pixel labels:
%       superpixel labels num_Pixel: the number of superpixel
%%
view_num = get_viewnum;
newData = cell(1,view_num);


% for v = 1 : view_num
%      % 找到数组中的最大值
%     maxValue = max(data3D{v}(:));
% 
%     data3D{v} = data3D{v} ./ maxValue;
% end


% for v = 1 : view_num
%      % 找到数组中的最小值和最大值
%     minValue = min(data3D{v}(:)); maxValue = max(data3D{v}(:));
%
%     % 计算范围 range = maxValue - minValue;
%
%     % 归一化数据 data3D{v} = (data3D{v} - minValue) / range;
% end


% 遍历每个模态
% for v = 1:view_num
%     Data = data3D{v};
%     [m, n, p] = size(Data);
% 
%     % 初始化该模态的归一化数据数组
%     normalizedData = zeros(m, n, p);
% 
%     % 对每个光谱带进行归一化

%     for i = 1:p
%         band = Data(:,:,i);
%         minVal = min(band, [], 'all');
%         maxVal = max(band, [], 'all');
% 
%         % 最大最小归一化
%         normalizedData(:,:,i) = (band - minVal) / (maxVal - minVal);
%     end
% 
%     % 将归一化后的数据存回对应的cell元素
%     data3D{v} = normalizedData;
% end



labels_cell = cell(1, view_num);
% 对每个模态进行单独处理
for v = 1:view_num
    % 获取当前模态的数据
    data = data3D{v};

    % 获取数据的尺寸
    [nRow, nCol, ~] = size(data);

    % 将数据 reshape 为二维矩阵
    X = reshape(data, nRow * nCol, []);

    % 对当前模态进行 PCA 降维（要是本来就是1维度的模态，实测相当于不起作用）
    start_pca = tic;
    coeff = pca(X);
    fprintf("PCA for modality %d, time: %f\n", v, toc(start_pca));
    Y_pca = X * coeff(:, 1);  % 降至一维

    % 将降维后的数据 reshape 回图像尺寸
    img = im2uint8(mat2gray(reshape(Y_pca, nRow, nCol)));

    % 对当前模态进行超像素分割
    labels = mex_ers(double(img), num_Pixel);
    labels = labels + 1;

    % 保存当前模态的分割结果
    labels_cell{v} = labels;
end

X = cell(1,view_num);
if nargin > 2  %     去噪
    fprintf('denoising,');
    for i = 1: view_num
        tic;
        [~,~,dim] = size(data3D{i});
        newData{i} = S3_PCA(data3D{i},k,labels);
        time1 = toc;
        fprintf('time = %f\n',time1);
        X{i} = reshape(newData{i},nRow*nCol,dim);
        X{i} = X{i}';
    end
    return;
end

fprintf('without_denoising:\n');
for i = 1: view_num
    [~,~,dim] = size(data3D{i});
    X{i} = reshape(data3D{i},nRow*nCol,dim);
    X{i} = X{i}';
end

end




