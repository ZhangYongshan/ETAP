function W = updateW(X,A,Z,S,alpha,beta,r)
%% 基于FPFC只修改了Q,去掉了原来的U，修改权重 alpha改成beta。beta改成beta

% U = U.^expo;
view_num = get_viewnum;
W = cell(1,view_num);
for v = 1:view_num
    W{v} = updateW_detail(X{v}, A{v},Z{v},S{v},alpha(v),beta(v),r{v});
end
end

function newW = updateW_detail(X,A,Z,S,alpha,beta,r)
St = X*X';
H2 = X*Z*A';
H3 = H2+H2';
P = St - H3 + A*diag(sum(Z))*A';
temp1 = P;
P = (P + P')/2;
P = P/alpha;
temp1 = temp1/alpha;%Pv p和fpfc是一样的不用修改

Q1 = A* S'*A';
Q2 = Q1+Q1';
Q = A*A' - Q2 + A* S *S'*A';
% temp2 = Q;
Q = (Q + Q')/2;
Q = Q/beta;%Qv
% temp2 = temp2/beta;

% temp3 = temp1+temp2;
% temp4 = (temp3+temp3')/2;
T = P + Q;
T = (T+T')/2;%正交
H = St\T;

W = eig1(H,r,0,0);
W = real(W);
newW = W*diag(1./sqrt(diag(W'*W)));
end