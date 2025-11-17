clear; clc;
tic;
addpath(genpath('funs'));

% ========== 1. 加载配置 ==========
config = mail_config();  % 包含是否发送邮件、收发件人等

% ========== 2. 数据集选择与加载 ==========
dataType = 'Berlin';
set_viewnum(2);

addpath('/data/zhengkangyue/datasets/datasets_multi/Berlin');
load('data_HS_LR.mat'); % super:170 d:144
load('data_SAR_HR.mat'); % super:224 d:8
% load('Houston2013_DSM.mat');% 
% load('Berlin_GT.mat');

data3D{1} = data_HS_LR;
data3D{2} = data_SAR_HR;
load('TestImage.mat');
load('TrainImage.mat');
gt2D = TestImage + TrainImage;

% gt2D = GT;
% clear  HSI DSM data_MS_HR;
clear  data_HS_LR data_SAR_HR TestImage;

% ========== 3. 调参超参数设置 ==========
% iter = 10;
% num_pixels = 155:5:175; 
% p_values = 0.1:0.1:1;
% gammas = [1e-8, 1e-6, 1e-4, 1e-3, 1e-2, 1e-1, 1, 10, 1e2, 1e3];
% lambdas = [1e-8, 1e-6, 1e-4, 1e-3, 1e-2, 1e-2, 1, 50, 1e2, 1e3];
% projDim{1} = 61:5:122;
% projDim{2} = 1: 2: 4;
% t_values = 1e2 ; % 新增的t值

iter = 10;
num_pixels = 155; % 150开始
p_values = 0.3;
gammas = 1e-8;
lambdas = 0.01;
projDim{1} = 116;
projDim{2} = 1;
t_values = 1e2 ; % 新增的t值

gpuDevice(2);

% ========== 4. 主调参流程 ==========
try
    % 启动调参，包含t参数
    [maxResult, maxParams] = tune_hyperparams2wled5(dataType, data3D, gt2D, iter, ...
                                                      num_pixels, p_values, gammas, lambdas, t_values,projDim);

    % 格式化邮件正文
    emailBody = format_summary(dataType, maxResult, iter, ...
                               num_pixels, p_values, gammas, lambdas);

    % 发送成功邮件（可关闭）
    send_notification(['✅ 调参完成 - ', dataType], emailBody);

catch ME
    % 构造错误正文
    errorBody = ['调参失败，错误信息如下：', newline, ME.message];

    % 发送失败邮件（可关闭）
    send_notification(['❌ 调参失败 - ', dataType], errorBody);

    rethrow(ME);  % 保留错误栈
end

elapsedTime = toc;  % 结束计时，计算总运行时间
fprintf('Total runtime: %.2f seconds (%.2f minutes)\n', elapsedTime, elapsedTime/60);

