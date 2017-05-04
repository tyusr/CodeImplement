function r = pzd(z,d,NAME,K)
% z：当前计算的color name
% d：当前计算的index
% NAME： 所有16种color name
r = 0;
d_mean = mean(d);

s = sum(exp(-eu_dist(d, d_mean)));

for m = 1:512
    %% calculate knn
    knn = eu_dist(NAME, d(m,:));
    [~, ki] = sort(knn);
    knn = NAME(ki(1:K),:);
    
    %% check whether z is in knn
    z_k = 0;
    for j = 1:K
        if isequal(knn(j,:), z)
            z_k = j;
            break;
        end
    end
    if z_k == 0
        continue;
    end
    
    %% pwd
    p_wd = exp(-(eu_dist(d(m,:), d_mean))) / s;
    
    %% pzw
    k_i = 1:K;
    knn_dist = eu_dist(knn, d(m,:));
    
    pzw_sum = @(x) exp(-(knn_dist(x) * (K-1) / sum(knn_dist(k_i(k_i~=x)))));
    p_zw_bottom = 0;
    for i = 1:K
        p_zw_bottom = p_zw_bottom + pzw_sum(i);
    end
    p_zw = pzw_sum(z_k) / p_zw_bottom;
  
    r = r + p_zw * p_wd;
end
end

function D = eu_dist(A,B)
    D = bsxfun(@minus, A, B);
    D = sum(bsxfun(@power, D, 2), 2);
    % 求欧式距离。为了省时间，没有开根号。正规写法如下：
    % D = sqrt(sum(bsxfun(@power, D, 2), 2));
end
