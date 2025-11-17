function [F,ev] = updateF(S,beta,c)
%保持不变
view_num = get_viewnum;

Ls = cell(1,view_num);
S = cellfun(@gather, S, 'UniformOutput', false);
beta = gather(beta);
c = gather(c);
for v = 1: view_num
    S{v} = (S{v}+S{v}')/2;
    Ds = diag(sum(S{v}));
    Ls{v} = Ds - S{v};
end

Ls_sum = (1/beta(1))*Ls{1};
for v = 2: view_num
    Ls_sum = Ls_sum + (1/beta(v))*Ls{v};
end

[F, ~, ev]=eig1(Ls_sum, c, 0);
% F= real(F);
F = gpuArray(F);
end

