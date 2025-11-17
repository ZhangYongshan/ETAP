clear; clc;
tic;
addpath(genpath('funs'));

% ========== 1. 加载配置 ==========
config = mail_config();  % 包含是否发送邮件、收发件人等

% ========== 2. 数据集选择与加载 ==========
dataType = 'MUUFL';
set_viewnum(2);

addpath('/data/zhengkangyue/datasets/datasets_multi/MUUFL');
load('HSI.mat'); % 325*220*64
load('LiDAR.mat'); % 325*220*2
load('gt.mat'); % 325*220
data3D{1} = double(HSI); % d=64
data3D{2} = double(LiDAR); % d=2
gt2D = gt;
clear HSI LiDAR gt;

gpuDevice(1); % 选择 GPU 设备

% ========== 3. 调参超参数设置 ==========
% iter = 10;  % 迭代次数
% num_pixels = 225:5:230;  % 超像素数
% p_values = 0.1:0.1:1;  % p 范数约束 0.6:0.1:1; 
% gammas =[1e-8, 1e-6, 1e-4, 1e-3, 1e-2, 1e-1, 1, 10, 1e2, 1e3];  % γ 参数
% lambdas =[1e-8, 1e-6, 1e-4, 1e-3, 1e-2, 1e-2, 1, 50, 100, 1000];  % λ
% 参数
% projDim{1} = 16:5:32;  % 第一个模态的投影维度
% projDim{2} = 2; % 第二个模态的投影维度
% t_values = 1e2;  % 超像素去噪参数

iter = 10;  % 迭代次数
num_pixels = 200;  % 超像素数
p_values = 0.9;  % p 范数约束 0.6:0.1:1; 
gammas = 0.0001;  % γ 参数
lambdas =1e-6;  % λ 参数
projDim{1} = 16;  % 第一个模态的投影维度
projDim{2} = 2; % 第二个模态的投影维度
t_values = 1e2;  % 超像素去噪参数


% ========== 4. 主调参流程 ==========
try
    % 启动调参
    [maxResult, maxParams] = tune_hyperparams2wled2(dataType, data3D, gt2D, iter, ...
                                              num_pixels, p_values, gammas, lambdas, t_values, projDim);

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
