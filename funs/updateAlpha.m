%% 和fpfc的mu一样
function [alpha] = updateAlpha(W,X,A,Z)

view_num = get_viewnum;
alpha= ones(1,view_num)/view_num;
hv_sum = 0;
hv = zeros(1,view_num);
for v = 1:view_num
    H2 = X{v}*Z{v}*A{v}';
    H3 = H2+H2';
    Q =  X{v}*X{v}' - H3 + A{v}*diag(sum(Z{v}))*A{v}';
    hv(v) = trace(W{v}'*Q*W{v});
    hv_sum = hv_sum+sqrt(hv(v));
end

for v = 1:view_num
    alpha(v) = sqrt(hv(v))/hv_sum;
end
end









% 
% 
% function [alpha] = updateAlpha(X,A,Z)
% view_num = get_viewnum;
% view_num = gpuArray(view_num);
% alpha= (gpuArray.ones(1,view_num))/view_num;
% hv_sum = 0;
% 
% hv_sum = gpuArray(hv_sum);
% hv = gpuArray.zeros(1,view_num);
% for v = 1:view_num
%     H2 = X{v}*Z{v}*A{v}';
%     H3 = H2+H2';
%     Q =  X{v}*X{v}' - H3 + A{v}*diag(sum(Z{v}))*A{v}';%D呢，D是单位矩阵
%     hv(v) = trace(Q);
%     hv_sum = hv_sum+sqrt(hv(v));
% end
% 
% for v = 1:view_num
%     alpha(v) = sqrt(hv(v))/hv_sum;
% end
% 
% 
% 
% end
% 
