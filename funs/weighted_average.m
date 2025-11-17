function Final = weighted_average(data_cell, weights)
%对不同模态的Z\S进行加权得到统一的Z、S
    % data_cell: 一个元胞数组，包含所有视图的 S 或 Z
    % weights: 一个向量，包含每个视图的权重（如 alpha、beta 等）
    % Final: 加权平均后的结果

    % 检查输入参数的维度是否一致
    if length(data_cell) ~= length(weights)
        error('输入参数的维度不一致：data_cell 和 weights 的长度必须相同。');
    end

    % 初始化 Final
    Final = (1 / weights(1)) * data_cell{1};
    
    % 遍历所有视图，计算加权和
    for v = 2:length(data_cell)
        Final = Final + (1 / weights(v)) * data_cell{v};
    end
    
    % 计算权重的总和
    sum_weights = sum(1 ./ weights);
    
    % 计算加权平均
    Final = Final ./ sum_weights;
end