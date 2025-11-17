function [maxResult, maxParams] = tune_hyperparams4wled( ...
        dataType, data3D, gt2D, iter, ...
        num_pixels, p_values, gammas, lambdas, ...
        t_values, ...              %%% NEW/CHANGED ①：t 的搜索列表
        projDim)
% 函数：超参数调节（含超像素去噪参数 t）
%--------------------------------------------------------------------------
% 输入：
%   dataType   : 数据集名称 (string)
%   data3D     : 各模态数据 cell，形如 {HS, LiDAR, …}
%   gt2D       : 真值标签二维矩阵
%   iter       : 迭代上限
%   num_pixels : 超像素数搜索列表               e.g. [100 150 200]
%   p_values   : p 范数约束搜索列表             e.g. 0.05:0.05:0.20
%   gammas     : γ 参数搜索列表                 e.g. logspace(-8,-2,4)
%   lambdas    : λ 参数搜索列表                 e.g. [1e-8 1e-6 1e-4 1e-2 1]
%   t_values   : 超像素去噪参数 t 搜索列表      e.g. [5e3 1e4 2e4]
%   projDim    : 每模态投影维度 cell            e.g. {{60:5:80} {1:4} …}
%
% 输出：
%   maxResult  : 最优 ACC（或其它第一列指标）
%   maxParams  : struct，保存得到 maxResult 的超参数
%--------------------------------------------------------------------------

    %=============== 基本信息 & 结果文件 ===============
    gt          = gt2D(:);
    ind         = find(gt);
    c           = length(unique(gt(ind)));

    maxResult   = -inf;
    maxParams   = struct();

    root_folder = ['./results/', dataType];
    if ~exist(root_folder, 'dir'); mkdir(root_folder); end
    filename_csv = [root_folder, '/tuning_results_' , dataType , ...
                    datestr(now, 'yyyy_mm_dd_HH_MM_SS'), '.csv'];
    fid_csv = fopen(filename_csv, 'w');
    if fid_csv == -1; error('无法打开文件 %s', filename_csv); end

    %%%% NEW/CHANGED ②：CSV 表头增加 t
%     fprintf(fid_csv, ...
%         't,num_pixels,p_value,gamma,lambda,projDim1,projDim2,projDim3,projDim4,' + ...
%         'acc,kappa,NMI,Purity,ARI,Fscore,remark\n');
    fprintf(fid_csv, "t,num_pixels,p_value,gamma,lambda,projDim1,projDim2,projDim3,projDim4," + ...
                 "acc,kappa,NMI,Purity,ARI,Fscore,remark\n");


    view_num = get_viewnum(); %#ok<NASGU> % 仅提醒可能被外部函数使用

    %=============== 预估循环总数（便于进度显示） ===============
    totalLoops = length(t_values)  * ...
                 length(num_pixels)* length(p_values) * length(gammas) * ...
                 length(lambdas)  * length(projDim{1}) * length(projDim{2}) * ...
                 length(projDim{3}) * length(projDim{4});
    currentLoop = 0;
    dk          = 5;   % 固定邻域数（不是 k）

    %=============== 网格搜索主循环 ===============
    for t = t_values                              %%% NEW/CHANGED ③
        for num_pixel = num_pixels
            % 数据预处理（含超像素去噪参数 t）
            [X, spLabel] = preDataqvzao(data3D, t, dk, num_pixel);

            for p_value = p_values
                for gamma = gammas
                    for lambda = lambdas
                        for proj1 = projDim{1}
                            for proj2 = projDim{2}
                                for proj3 = projDim{3}
                                    for proj4 = projDim{4}
                                        currentLoop = currentLoop + 1;
                                        remark      = '';
                                        currProjDim = {proj1, proj2, proj3, proj4};

                                        try
                                            [y_pred, pred_length] = ...
                                                main(X, spLabel, num_pixel, c, ...
                                                     p_value, lambda, gamma, ...
                                                     iter, currProjDim);

                                            if pred_length == c
                                                results = evaluate_results_clustering( ...
                                                            gt(ind), y_pred(ind));
                                            else
                                                results = -1 * ones(1,6);
                                                remark  = 'wrong number of classes';
                                            end
                                        catch ME
                                            warning('跳过: t=%g, num_pixels=%d, p=%.2f, γ=%g, λ=%g\n%s', ...
                                                    t, num_pixel, p_value, gamma, lambda, ME.message);
                                            results = -1 * ones(1,6);
                                            remark  = ME.message;
                                        end

                                        % 进度与实时 ACC
                                        fprintf(['dataset:%s, Loop:%d/%d, t:%g, num_pixels:%d, ' ...
                                                 'p_value:%.2f, γ:%g, λ:%g, projDim:%d/%d/%d/%d, ' ...
                                                 'ACC:%.4f\n'], ...
                                                 dataType, currentLoop, totalLoops, ...
                                                 t, num_pixel, p_value, gamma, lambda, ...
                                                 proj1, proj2, proj3, proj4, results(1));

                                        %%%% NEW/CHANGED ④：写 CSV 时包含 t
                                        fprintf(fid_csv, ...
                                            '%g,%d,%.2f,%g,%g,%d,%d,%d,%d,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,"%s"\n', ...
                                            t, num_pixel, p_value, gamma, lambda, ...
                                            proj1, proj2, proj3, proj4, ...
                                            results(1), results(2), results(3), ...
                                            results(4), results(5), results(6), remark);

                                        % 更新最优
                                        if results(1) > maxResult
                                            maxResult = results(1);
                                            maxParams = struct( ...
                                                't',          t, ...
                                                'num_pixels', num_pixel, ...
                                                'p_value',    p_value, ...
                                                'gamma',      gamma, ...
                                                'lambda',     lambda, ...
                                                'projDim',    currProjDim );
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    %=============== 收尾 ===============
    if fclose(fid_csv) == -1
        warning('结果文件未能正常关闭');
    end
end
