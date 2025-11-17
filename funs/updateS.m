function [S] = updateS(A,F,J,Y,W,beta,mu,gamma)
% A:d*m F:m*c

%% 基于原tensor 只改了k
% quadprog 需要double类型
A = cellfun(@gather, A, 'UniformOutput', false);
J = cellfun(@gather, J, 'UniformOutput', false);
Y = cellfun(@gather, Y, 'UniformOutput', false);
W = cellfun(@gather, W, 'UniformOutput', false);
F = gather(F);
beta = gather(beta);
mu = gather(mu);
gamma = gather(gamma);

% A = cellfun(@double, A, 'UniformOutput', false);  % 转换A为double类型
% J = cellfun(@double, J, 'UniformOutput', false);  % 转换J为double类型
% Y = cellfun(@double, Y, 'UniformOutput', false);  % 转换Y为double类型
% F = double(F);  % 转换F为double类型
% beta = double(beta);  % 转换beta为double类型
% mu = double(mu);  % 转换mu为double类型
% gamma = double(gamma);  % 转换gamma为double类型




[~,m] = size(A{1});
view_num = get_viewnum;
S = cell(1,view_num);
% H = cell(1,view_num);
K = cell(1,view_num);
Q = cell(1,view_num);

for v = 1:view_num
    S{v} = zeros(m, m); 
end

tmpS =  zeros(m, m);
distF = (pdist2(F,F)).^2; % pdist2计算的是每行之间的距离  bij
options = optimset( 'Algorithm','interior-point-convex','Display','off','TolFun',10^-1);
time1 = tic;
for v = 1:view_num
    %为每个 view 构造 QP 优化问题并用 quadprog 解出每列的 S
    K{v} = A{v}'* W{v} * W{v}' * A{v};
    Q{v} = J{v} - Y{v}/mu;
    H = mu*eye(m)+2*K{v}/beta(v);%第一项
    H = double(H);
%     H = cellfun(@gather, H, 'UniformOutput', false);
    H = (H+H')/2;%对称化
%     H = gpuArray(H);

%     for i = 1:m
    parfor i = 1:m %并行执行循环体
        ff = double((distF(:,i))'*gamma/beta(v)-2*K{v}(i,:)/beta(v)-mu*(Q{v}(:,i))');%第二项
%         ff = gpuArray(ff);
        
        tmpS(:,i)=quadprog(H, ff',[],[],ones(1,m),1,zeros(m,1),ones(m,1),tmpS(:,i),options);%quadprog带约束的二次规划
    end
     S{v} = tmpS;
%     S{v} = tmpS'; % 让其行和为1
end
S = cellfun(@gpuArray, S, 'UniformOutput', false);
fprintf("更新S耗时:%.2f\n",toc(time1));
end

