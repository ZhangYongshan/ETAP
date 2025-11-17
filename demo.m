clear; close all; clc;
addpath(genpath('funs'));

% dataType = 'Berlin'; dk = 5; set_viewnum(2);
dataType = 'MUUFL'; dk = 1; set_viewnum(2);
% dataType = 'MDAS';dk = 5;set_viewnum(4);

iter = 10;
%%
data3D = cell(1,get_viewnum);
projDim = cell(1,get_viewnum);
switch dataType
    case 'Houston3M'
        addpath('/data/zhengkangyue/datasets/datasets_multi/Houston2013');
        load('Houston2013_HSI.mat'); % super:170 d:144
        load('Houston2013_MS.mat'); % super:224 d:8
        load('Houston2013_DSM.mat');% 
        load('GT.mat');
        data3D{1} = HSI;
        data3D{2} = data_MS_HR;
        data3D{3} = DSM;
        gt2D =GT;
        num_pixel = 150;
        p_value = 0.1; % 控制在0到1之间
        gamma = 1e-8;
        lambda = 1e-8;
        clear  HSI DSM data_MS_HR;
     case 'MDAS'
        addpath('/data/zhengkangyue/datasets/datasets_multi/MDAS');
        load('MDAS-Sub1-HSI.mat'); 
        load('MDAS-Sub1-DSM.mat'); 
        load('MDAS-Sub1-GT.mat'); 
        data3D{1} = double(Data_HSI); 
        data3D{2} = double(Data_DSM);
        gt2D = GT;
        num_pixel = 235;
        p_value = 0.1; % 控制在0到1之间
        gamma = 1e-8;
        lambda = 1e-8;
        
        clear  Data_HSI Data_DSM GT;
    case 'Houston2'
        addpath('/data/yanshuaikang/datasets/datasets_multimodal/Houston2013_3M/')
        load('Houston2013_HSI.mat'); % super:170 d:144
        load('Houston2013_DSM.mat'); % super:224 d:1
        load('Houston2013_TE.mat');
        load('Houston2013_TR.mat');
        Houston_Test = TE_map;
        Houston_Train = TR_map;
        data3D{1} = HSI;
        data3D{2} = DSM;
        gt2D =Houston_Test + Houston_Train;
        clear  HSI DSM TE_map TR_map;
    case 'MUUFL'
        addpath('E:\projects\MatlabProject\ETAP\ETAP1\data\MUUFL');
        load('HSI.mat'); % 325*220*64
        load('LiDAR.mat'); % 325*220*2
        load('gt.mat'); % 325*220
        data3D{1} = double(HSI); % d=63
        projDim{1} = 16;
        data3D{2} = double(LiDAR); % d=1
        projDim{2} = 2;
        gt2D = gt;
        num_pixel = 200;%modify hyperparams to exam if it can run properly
        p_value = 0.9; % 控制在0到1之间
        gamma = 0.0001;
        lambda = 1e-6;
        t = 1e2;  % 超像素去噪参数
        clear  HSI LiDAR gt;
    case 'Augsburg'
        addpath('/data/yanshuaikang/datasets/datasets_multimodal/HS-SAR-DSM Augsburg');
        load('data_DSM.mat');%super:196
        load('data_HS_LR.mat');
        load('data_SAR_HR.mat');
        load('TestImage.mat');
        load('TrainImage.mat');
        data3D{1} = data_DSM; % d=
        data3D{2} = data_HS_LR; % d=180
        data3D{3} =data_SAR_HR; % d=4
        gt2D =TestImage+TrainImage;
         num_pixel = 150;
        p_value = 0.8; % 控制在0到1之间
        gamma = 1;
        lambda = 0.001;
        clear  data_DSM data_HS_LR data_SAR_HR TestImage;
    case 'Trento'
       addpath('/data/yanshuaikang/datasets/datasets_multimodal/HS-DAR Trento');
        load('trento_data.mat'); % 166*600
        data3D{1} = HSI_data; % d=63
        data3D{2} = LiDAR_data; % d=1
        gt2D = ground;
        clear  HSI_data LiDAR_data ground;
    case 'Berlin'
        set_viewnum(2);
        addpath('/data/yanshuaikang/datasets/datasets_multimodal/HS-SAR Berlin');
        load('data_HS_LR.mat');% super:184 d:244
        load('data_SAR_HR.mat');% super:249 d:4
        load('TestImage.mat');
        load('TrainImage.mat');
        data3D{1} = data_HS_LR;
        data3D{2} = data_SAR_HR;
        gt2D =TestImage+TrainImage;
        num_pixel = 155;
        p_value = 0.2; % 控制在0到1之间
        gamma = 1;
        lambda = 0.001;
        clear  data_HS_LR data_SAR_HR TestImage;
    case 'Houston'
        set_viewnum(2);
        addpath('/data/yanshuaikang/datasets/datasets_multimodal/HS-MS Houston2013');
        load('data_HS_LR.mat'); % super:170 d:144
        load('data_MS_HR.mat'); % super:224 d:8
        Houston_Test = double(imread('2013_IEEE_GRSS_DF_Contest_Samples_VA.tif'));
        Houston_Train = double(imread('2013_IEEE_GRSS_DF_Contest_Samples_TR.tif'));
        data3D{1} = data_HS_LR;
        data3D{2} = data_MS_HR;
        gt2D =Houston_Test + Houston_Train;
        clear  data_HS_LR data_MS_HR Houston_Test Houston_Train;
end

gt = double(gt2D(:));
ind = find(gt);
c = length(unique(gt(ind)));
% HSI data preprocessing
start_demo=tic;

% 去噪
% [X,spLabel] = preData_normalization(data3D,num_Pixel,dk);

% 参数设置 
% 来源：Structured Graph Learning for Scalable Subspace Clustering
% gamma = [0.001, 0.01, 0.1, 1, 10, 50];


[X, spLabel] = preDataqvzao(data3D, t, dk, num_pixel);
% [X,spLabel] = preData_normalization(data3D,num_Pixel);
[y_pred,pred_length] = main(X, spLabel, num_pixel, c,p_value,lambda,gamma,iter,projDim);

results = evaluate_results_clustering(gt(ind),y_pred(ind));

fprintf("total time:%.2f\n",toc(start_demo));
fprintf("pred_len:%d\n",pred_length);
results4 = round(results',4);
fprintf("ACC:%.4f",results(1));
% save("mdas_4365.mat","y_pred");





