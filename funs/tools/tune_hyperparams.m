function [maxResult, maxParams] = tune_hyperparams(dataType, data3D, gt2D, iter, ...
    num_pixels, p_values, gammas, lambdas)


gt = gt2D(:);
ind = find(gt);
c = length(unique(gt(ind)));

maxResult = 0;
maxParams = [];

root_folder = ['./results/', dataType];
if ~exist(root_folder, 'dir')
    mkdir(root_folder);
end
filename_csv = [root_folder, '/tuning_results_',dataType, datestr(now, 'yyyy_mm_dd_HH_MM_SS'), '.csv'];

fid_csv = fopen(filename_csv, 'w');
if fid_csv == -1
    error('无法打开文件 %s 进行写入', filename_csv);
end
% fprintf(fid_csv,
% 'num_pixels,p_value,gamma,lambda,acc,kappa,NMI,Purity,ARI,Fscore\n');
fprintf(fid_csv, 'num_pixels,p_value,gamma,lambda,acc,kappa,NMI,Purity,ARI,Fscore,remark\n');

% 总轮数计数器
totalLoops = length(num_pixels) * length(p_values) * length(gammas) * length(lambdas);
currentLoop = 0;

% 调参主循环
for num_pixel = num_pixels
    [X, spLabel] = preData_normalization(data3D, num_pixel);
    for p_value = p_values
        for gamma = gammas
            for lambda = lambdas
                currentLoop = currentLoop + 1;

                remark = '';  % 初始化备注

                try
                    [y_pred, pred_length] = main(X, spLabel, num_pixel, c, p_value, lambda, gamma, iter);

                    if pred_length == c
                        results = evaluate_results_clustering(gt(ind), y_pred(ind));
                    else
                        results = -1 * ones(1, 6);  % 预测类别数不对
                        remark = 'wrong number of predicted classes';
                    end

                catch ME
                    warning('出错，跳过该组参数：num_pixels=%d, p_value=%.2f, gamma=%g, lambda=%g\n错误信息: %s', ...
                        num_pixel, p_value, gamma, lambda, ME.message);
                    results = -1 * ones(1, 6);  % 错误标记结果
                    remark = ME.message;        % 错误写入备注
                end

                % 打印当前调参状态
                fprintf('dataset:%s, Loop: %d/%d, num_pixels: %d, p_value: %.2f, gamma: %g, lambda: %g, acc: %.4f\n', ...
                    dataType, currentLoop, totalLoops, num_pixel, p_value, gamma, lambda, results(1));

                % 写入CSV一行
                fprintf(fid_csv, '%d,%.2f,%g,%g,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,"%s"\n', ...
                    num_pixel, p_value, gamma, lambda, ...
                    results(1), results(2), results(3), results(4), results(5), results(6), remark);

            end
        end
    end
end

% 关闭CSV文件
fclose(fid_csv);


end
