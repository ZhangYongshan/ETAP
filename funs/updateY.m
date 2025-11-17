function [Y] = updateY(Y,S,J,rho)
%% 没有改变
view_num = get_viewnum;
for v=1:view_num
    Y{v} = Y{v} + rho*(S{v}-J{v});
end
end