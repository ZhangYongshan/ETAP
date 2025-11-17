function [A] = updateA(X,Z,S,alpha,beta)
view_num = get_viewnum;
A = cell(1,view_num);
%%和之前一样没有改变
for v = 1:view_num

    alpha_v = alpha(v);
    beta_v = beta(v);
    Xv = X{v};
    Sv = S{v};

    % 计算 Dz_col 对角矩阵，其中每个元素是 Zv 的对应列之和
    Dz_col = diag(sum(Z{v}));
    m = size(Z{v}, 2); 
    I = eye(m);      

    % 计算 A^v 
    inverse_term = beta_v * Dz_col + alpha_v * I - alpha_v * Sv - alpha_v * Sv' + alpha_v * (Sv * Sv');
    A{v} = (beta_v * Xv * Z{v}) / inverse_term;
end


end

