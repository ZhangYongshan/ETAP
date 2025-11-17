clear; clc;
tic;
addpath(genpath('funs'));

% ========== 1. 加载配置 ==========
config = mail_config();            % 邮件收发配置

% ========== 2. 数据集选择与加载 ==========
dataType = 'MDASled1e4';
set_viewnum(4);

addpath('/data/zhengkangyue/datasets/datasets_multi/MDAS');
load('MDAS-Sub1-HSI.mat');
load('MDAS-Sub1-MSI.mat');
load('MDAS-Sub1-SAR.mat');
load('MDAS-Sub1-DSM.mat');
load('MDAS-Sub1-GT.mat');

data3D{1} = double(Data_HSI);
data3D{2} = double(Data_MSI);
data3D{3} = double(Data_SAR);
data3D{4} = double(Data_DSM);
gt2D      = GT;

% ========== 3. 调参超参数设置 ==========
% iter        = 10;
% num_pixels  = 150:5:250;
% p_values    = 0.1:0.1:1;
% gammas      = [1e-8, 1e-6, 1e-4];
% lambdas     = [1e-3, 1e-2, 1e-1, 1, 50];   %%% CHANGED: 去掉重复 1e-2
% t_values = 1e4;%超像素去噪参数
% projDim{1}  = 60:5:121;
% projDim{2}  = 1:2:12;
% projDim{3}  = 2;
% projDim{4}  = 1;

iter        = 10;
num_pixels  = 200;
p_values    = 0.4;
gammas      = 1000;
lambdas     = 0.001;   
t_values = 1e4;    %超像素去噪参数
projDim{1}  = 95;
projDim{2}  = 5;
projDim{3}  = 2;
projDim{4}  = 1;

gpuDevice(1);


% ========== 4. 主调参流程 ==========
try
    %%% CHANGED: 把 t_values 插到 lambdas 与 projDim 之间
    [maxResult, maxParams] = tune_hyperparams4wled( ...
            dataType, data3D, gt2D, iter, ...
            num_pixels, p_values, gammas, lambdas, ...
            t_values, ...                % 传入 t 范围
            projDim);

    %%% CHANGED: 在邮件正文里也加入 t_values
    emailBody = format_summary(dataType, maxResult, iter, ...
                               num_pixels, p_values, gammas, lambdas);                 % 新增 t_values

    send_notification(['✅ 调参完成 - ', dataType], emailBody);

catch ME
    errorBody = ['调参失败，错误信息如下：', newline, ME.message];
    send_notification(['❌ 调参失败 - ', dataType], errorBody);
    rethrow(ME);
end
elapsedTime = toc;  % 结束计时，计算总运行时间
fprintf('Total runtime: %.2f seconds (%.2f minutes)\n', elapsedTime, elapsedTime/60);
