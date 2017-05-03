function [L,pca_para] = myTDL(x,CountOfSampleEachClass,pars)

alpha = pars.alpha;
lambda = 1e-3;
rou = 1;

d = pars.dem_pca;
[transMatrix,x] = dims_reduce(x,d);
M = eye(d);
t = 0;
y = get_label(CountOfSampleEachClass);
nc = length(CountOfSampleEachClass); % c for classes
max_iterator_times = pars.maxiter;
firstime = 1;
loss0 = Inf;
lossf = Inf;
while t < max_iterator_times && abs(lossf - loss0) < 0.001
    
    %% 1. 根据式(3)寻找最小类内距离
    i = zeros(1,nc);
    j = zeros(1,nc);
    k = zeros(1,nc);
    
    for c = 1:nc
        min_intra_dis = Inf;
        iend = find(y==c,1,'last');
        idx = find(y==c,1,'first');
        while idx < iend
            idxx = idx + 1;
            while idxx <= iend
                x_x = x(:,idx) - x(:,idxx);
                intra_dis = x_x' * M * x_x;
                if intra_dis < min_intra_dis
                    min_intra_dis = intra_dis;
                    i(c) = idx;
                    j(c) = idxx;
                end
                idxx = idxx + 1;
            end
            idx = idx + 1;
        end
    end
    
    %% 2. 根据式(4)第二项构建 triggered set
    for c = 1:nc
        min_inter_dis = Inf;
        for idx = 1:length(x)
            if y(idx) ~= y(i(c))
                x_x = x(:,idx) - x(:,i(c));
                inter_dis = x_x' * M * x_x;
                if inter_dis < min_inter_dis
                    min_inter_dis = inter_dis;
                    k(c) = idx;
                end
            end
        end
    end
    
    %% 3. 计算G
    G1 = zeros(d);
    G2 = zeros(d);
    for c = 1:nc
        xr = x(:,i(c)) - x(:,j(c));
        xi = x(:,i(c)) - x(:,k(c));
        G1 = G1 + xr * xr';
        G2 = G2 + xr * xr' - xi * xi';
    end
    G = (1 - alpha) * G1 + alpha * G2;
    M = M - lambda * G;
    
    %% 4. 使G保持正半定
    [V,D] = eig(M,'vector');
    D(D<0) = 0.0001;
    M = V * diag(D) * V';
    
    %% 5. 计算loss function
    L1 = 0;
    L2 = 0;
    for c = 1:nc
        xr = x(:,i(c)) - x(:,j(c));
        xi = x(:,i(c)) - x(:,k(c));
        L1 = L1 + trace(M * (xr * xr'));
        L2 = L2 + max(trace(M * (xr * xr')) - trace(M * (xi * xi')) + rou, 0);
    end
    lossf = (1 - alpha) * L1 + alpha * L2;
    
    %% 6.
    if ~firstime
        if lossf < loss0
            lambda = lambda + 1.01;
        elseif lossf > loss0
            lambda = lambda - 0.5;
        end
    else
        firstime = 0;
    end
    loss0 = lossf;
    t = t + 1;
end

L = chol(M);
L = L(1:pars.outdim,:);
pca_para.projection = transMatrix;
pca_para.dim = d;
end

function [transMatrix,after_pca] = dims_reduce(x,dims_remain)
[eigenVectors,score,eigenValues,tsquare] = pca(x');
transMatrix = eigenVectors(:,1:dims_remain);
after_pca = transMatrix' * x;
end