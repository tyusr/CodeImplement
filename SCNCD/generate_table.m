close all; clear;
%% NAME：16种颜色， K：k-nn中的邻居数
NAME = [
    255,000,255; 000,000,255; 000,255,255; 000,255,000;
    255,255,000; 255,000,000; 128,000,128; 000,000,128;
    000,128,128; 000,128,000; 128,128,000; 128,000,000;
    000,000,000; 128,128,128; 192,192,192; 255,255,255; ] / 255;
K = 5;

%% cube和cube_end分别是所有颜色区间的左边界和右边界
% 想象一个立方体，它的x/y/z坐标轴分别是r/g/b值，
% 所有颜色组合都对应这个立方体里面的一个点，
% cube里面的值就是从这个立方体里面取到的。
% cube存储的就是所有index
cube = zeros(32768,3);
% point >>> line
for i = 2:32
    cube(i,:) = [8*(i-1) 0 0];
end
% line >>> surface
for i = 2:32
    q = (i-1) * 32 + 1;
    cube(q:q+31,:) = bsxfun(@plus, cube(1:32,:), [0 8*(i-1) 0]);
    %上一句等价于：
    %cube(q:q+31,:) = cube(1:32,:) + repmat([0 8*(i-1) 0], [32 1]);

end
% surface >>> cube
for i = 2:32
    q = (i-1) * 1024 + 1;
    cube(q:q+1023,:) = bsxfun(@plus, cube(1:1024,:), [0 0 8*(i-1)]);
    %上一句等价于：
    %cube(q:q+1023,:) = cube(1:1024,:) + repmat([0 0 8*(i-1)], [1024 1]);
end

cube_end = cube + 7;

%% normalize 归一化到[0 1]区间
cube = cube / 255;
cube_end = cube_end / 255;
cube_mean = (cube + cube_end) / 2;

P = zeros(32768,16);

tic;
for z = 1:16
    name = NAME(z,:);
    disp([num2str(z) '/16']);
    parfor i = 1:32768
        P(i,z) = pzd(name, get_color(cube(i,:), cube_end(i,:)), NAME, K);
    end
end
toc;
disp('done');
save P P.mat;