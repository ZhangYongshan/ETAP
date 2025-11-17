function [J,Y] = updateJ(S,Y,p,rho,lambda)
%% 保持不变
%%  solve J{v}
%初始化
view_num = get_viewnum;

% the defult weight_vector of tensor Schatten p-norm
[~,m] = size(S{1});
sX = [m, m, view_num];

weight_vector = ones(1,view_num)';

%转换为张量
S = cellfun(@gather, S, 'UniformOutput', false);
Y = cellfun(@gather, Y, 'UniformOutput', false);
p = gather(p);
rho = gather(rho);
lambda = gather(lambda);

S_tensor = cat(3,S{:,:});
Y_tensor = cat(3,Y{:,:});
s = S_tensor(:);
y = Y_tensor(:);

%sp范数约束
[myj, ~] = wshrinkObj_weight_lp(s+y/rho, weight_vector*lambda./rho,sX, 0,3,p);
% if all(myj(:) == 0)
%     disp('myj矩阵是全零矩阵。');
% else
%     disp('myj矩阵不是全零矩阵。');
% end
J_tensor = reshape(myj, sX);
Y_tensor = reshape(y,sX);


for v = 1:view_num
    J{v} = J_tensor(:,:,v);
    Y{v} = Y_tensor(:,:,v);
end
J = cellfun(@gpuArray, J, 'UniformOutput', false);
Y = cellfun(@gpuArray, Y, 'UniformOutput', false);
end