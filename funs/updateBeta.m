function [beta] = updateBeta(A,S,W)
%修改了norm
    view_num = get_viewnum;
    view_num = gpuArray(view_num);
    
    hv = gpuArray.zeros(1,view_num);
    for v = 1:view_num
        hv(v) = norm((W{v}'*A{v}-W{v}'*A{v}*S{v}),'fro'); % anchor 自表达残差       
    end

    beta = hv ./ sum(hv);
end

