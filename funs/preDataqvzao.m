%% led去噪 处理多个模态
function [X_cell, labels_cell] = preDataqvzao(data3D, t, dk, num_Pixel)
%% Multi-modality HSI data preprocessing with denoising and superpixel
% Input:
%   data3D    : cell array of 3D cubes (each modality)
%   t         : manifold parameter for denoising (lambda)
%   dk        : number of neighbors (for adjacency)
%   num_Pixel : number of superpixels
% Output:
%   X_cell       : cell array, each element is [d x N] matrix (one modality)
%   labels_cell  : cell array, each element is [nRow x nCol] superpixel labels

view_num = get_viewnum();  % 获取模态数量
X_cell = cell(1, view_num);
labels_cell = cell(1, view_num);

for v = 1:view_num
    fprintf("Processing modality %d ...\n", v);

    %% Step 1: 提取当前模态的数据
    cube = data3D{v};  % [nRow x nCol x dim]
    cube = double(cube);
    [nRow, nCol, dim] = size(cube);

    %% Step 2: reshape 成 X 并归一化
    X = reshape(cube, nRow * nCol, dim);
    X = double(X);
    [X, ~] = mapminmax(X);

    %% Step 3: PCA 降维用于超像素
    coeff = pca(X);
    Y_pca = X * coeff(:, 1);  % 只取第一主成分
    img = reshape(Y_pca, nRow, nCol);
    img = mat2gray(img);
    img = im2uint8(img);

    %% Step 4: 超像素分割
    labels = mex_ers(double(img), num_Pixel);
    labels = labels + 1;

    %% Step 5: 去噪
    tic;
    newData = LED(cube, t, labels, dk);
    fprintf("Modality %d denoising time = %f\n", v, toc);

    %% Step 6: reshape 成每列一个像素
    X_denoised = reshape(newData, nRow * nCol, dim);
    X_denoised = double(X_denoised)';
    
    %% Step 7: 存入结果
    X_cell{v} = X_denoised;
    labels_cell{v} = labels;
end
end





%% 加上了矩阵转换逻辑 但是只能处理一个模态
% function [X, labels] = preDataqvzao(data3D, t, dk, num_Pixel)
% %% HSI data preprocessing
% % Input:
% %   data3D: 3D cube, or cell array of 3D cubes
% %   t: parameter (e.g., lambda)
% %   dk: number of neighbors
% %   num_Pixel: number of superpixels (ERS)
% % Output:
% %   X: 2D matrix, each column is a pixel
% %   labels: superpixel label map
% 
% % ✅ Step 1: 支持 cell 输入
% if iscell(data3D)
%     data3D = data3D{1};  % 仅使用第一个模态
% end
% 
% % ✅ Step 2: 确保是 double 类型
% data3D = double(data3D);
% 
% % ✅ Step 3: reshape 并归一化
% [nRow, nCol, dim] = size(data3D);
% X = reshape(data3D, nRow * nCol, dim);
% X = double(X);                % <--- 强制转换
% [X, ~] = mapminmax(X);        % <--- 归一化
% 
% % ✅ Step 4: PCA 降维到1维，用于超像素分割
% p = 1;
% coeff = pca(X);
% Y_pca = X * coeff(:, 1:p);
% img = reshape(Y_pca, nRow, nCol);         % 变回图像
% img = mat2gray(img);                      % 缩放到[0,1]
% img = im2uint8(img);                      % 转为 uint8（ERS 需要）
% 
% % ✅ Step 5: 进行 ERS 超像素分割
% labels = mex_ers(double(img), num_Pixel); % mex_ers 要求 double
% labels = labels + 1;
% 
% % ✅ Step 6: 去噪处理
% tic;
% newData = LED(data3D, t, labels, dk);     % 使用 LED 去噪
% fprintf('denoising time = %f\n', toc);
% 
% % ✅ Step 7: reshape 去噪结果
% X = reshape(newData, nRow * nCol, dim);
% X = double(X);    % 加强鲁棒性
% X = X';           % 每列是一个样本
% end

%% 直接修改的led去噪
% function [X,labels] = preDataqvzao(data3D,t,dk,num_Pixel)
% %% HSI data preprocessing
% % Input: 
% %       data3D: 3D cube, HSI data.
% %       lambda :   the number of neighbors for denoising (parameter for manifold term )
% % Output:
% %       X:      new data, 2D matrix. each column is a pixel
% %       labels: superpixel labels
% %       num_ERS: the number of superpixel
% %%
% 
% [nRow,nCol,dim] = size(data3D);
% X = reshape(data3D,nRow*nCol,dim);
% [X,~] = mapminmax(X);
% 
% p = 1;
% coeff = pca(X);
% Y_pca = X*coeff(:,1:p);
% 
% img = im2uint8(mat2gray(reshape(Y_pca, nRow, nCol, p)));
% 
% % Tbase = 2000;
% % [num_Pixel] = pixelNum(img,Tbase);
% % fprintf('Superpixels number : %d\n',num_Pixel);
% 
% %num_Pixel = num_ERS;  %%%%% added 
% 
% % ERS super-pixel segmentation.
% labels = mex_ers(double(img),num_Pixel);
% labels = labels + 1;
% 
% tic;
% %% 不同的去噪方法
% % newData = S3_PCA(data3D,k,labels); % zhangxin's method fo
%   newData = LED(data3D,t,labels,dk);
% 
% time1 = toc;
% fprintf('denoising time = %f\n',time1);
% 
% X = reshape(newData,nRow*nCol,dim);
% X = X';
% end
% 
% %% 超像素块数量获取
% % function [num]=pixelNum(img,Tbase)
% % % Calculate the number of superpixels by RLPA
% % % https://github.com/junjun-jiang/RLPA
% % [m,n] = size(img);
% % % img =  rgb2gray(img);
% % BW = edge(img,'log');
% % % figure,imshow(BW);
% % ind = find(BW~=0);
% % Len = length(ind);
% % Ratio = Len/(m*n);
% % num = fix(Ratio * Tbase);
% % end