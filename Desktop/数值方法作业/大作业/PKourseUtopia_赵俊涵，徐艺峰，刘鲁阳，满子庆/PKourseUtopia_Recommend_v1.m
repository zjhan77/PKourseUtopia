clc; clear all; close all; format compact;
% 读入数据，n为行数即课程门数
data = readmatrix("data.xlsx", "OutputType", "string");
n = size(data); n = n(1);

name = data(:, 1);
score_1 = str2double(data(:, 3: 6));
feature_1 = str2double(data(:, 7: 9));
score_2 = str2double(data(:, 10));
feature_2 = str2double(data(:, 11));
% score用于排序（5个指标都是越高越好），feature用于多准则决策（这4个指标因人而异，根据用户的需求来推荐）
score = [score_1, score_2];
feature = [feature_1, feature_2];
    
% 输入用户对指标两两比较的矩阵，输出这四个指标的权重分布
%A = [1   7   3   1/5;
%     1/7 1   1/3 1/3;
%     1/3 3   1   1;
%     5   3   1   1];
%A = [1   1/5 1   7;
%     5   1   5   5;
%     1   1/5 1   3;
%     1/7 1/5 1/3 1];
    
%对用户的输入进行处理
x = zeros(1, 6);
fprintf("请回答以下六个问题以便给出针对你的最佳课程，务必谨慎选择：\n");
fprintf("！！！请注意以下几个陈述句均有七个回答选项：分别是：\n");
fprintf("1/7：非常不同意；1/5：不同意；1/3：有点不同意；1：二者差不多\n");
fprintf("3：有点同意；5：同意；7：非常同意\n");
x(1) = input("相比于小组作业，您更倾向于考试：");
x(2) = input("相比于小组作业，您更倾向于论文：");
x(3) = input("相比于小组作业，您更倾向于多社交：");
x(4) = input("相比于考试，您更倾向于论文：");
x(5) = input("相比于考试，您更倾向于多社交：");
x(6) = input("相比于论文，您更倾向于多社交：");

% 输入用户对指标两两比较的矩阵，输出这四个指标的权重分布
A = [1, x(1), x(2), x(3);
     1/x(1), 1, x(4), x(5);
     1/x(2), 1/x(4),1,x(6);
     1/x(3), 1/x(5), 1/x(6), 1];
B = Multi_criteria(A);
argminB = 0;
minB = min(B);
for i = 1: 4
    if B(i) == minB
        argminB = i;
        B(i) = 1;
        break;
    end
end
for i = 1: 4
    if B(i) == min(B)
        B(argminB) = -minB;
        B(i) = -B(i);
        break;
    end
end
B
% 将这四个指标对应的特征标准化，保证每个指标的影响一致
feature = [feature(: , 1: 3) .* (1/4), mapminmaxEx1(feature(: , 4), 0, 0.5)];

X = zeros(1, 80);
for i = 1: 80
    X(i) = B * feature(i, :).';
end
X;

[~, sortIndex] = sort(X, 'descend');
%for i = 1:20
%    disp(name(sortIndex(i)));
%end
top20 = sortIndex(1: 20);

% 利用score对所有课程做排序，最后从top20这符合条件的20门当中推荐最靠前的4门。
score = (score - mean(score)) ./ std(score);
scores = zeros(1, 80);
for i = 1: 80
    scores(i) = sum(score(i, :));
end
[~, sortIndex] = sort(scores, 'descend');

disp("为您推荐的4门课程如下：")

cnt = 0;
for i = 1: 80
    if cnt >= 4
        break;
    end
    if ismember(sortIndex(i), top20) == true
        disp(name(sortIndex(i)))
        % 词云
        words = readmatrix("raw_data/"+name(sortIndex(i))+".xlsx", "OutputType", "string");
        size_w = size(words);
        size_w = size_w(1);
        words = words(:, 6:7);
        likes = str2double(words(:, 1));
        likes = mapminmaxEx1(likes, 7, 18);
        %likes = likes ./ sum(likes);
        words(:, 1) = likes;
        % 删去无标题的
        words(find(words(:, 2)=="无标题"), :) = [];
        size_w = size(words); size_w = size_w(1);
        words(size_w+1, :) = [25, name(sortIndex(i))];
        % 作“词云图”
        %subplot(2, 2, cnt+1);
        figure;
        axis equal;
        axis([-50 50 -50 50]);
        x = linspace(0, 2*pi, size_w+1);
        [X,Y] = pol2cart(x, 30);
        
        for j = 1:size_w
            color = rand(1,3);
            text(X(j), Y(j), words(j, 2),'Color',color, 'Fontsize', str2double(words(j, 1)) );
        end
        text(-2.5, 0, words(size_w+1, 2), 'Fontsize', str2double(words(size_w+1, 1)));
        cnt = cnt + 1;
    end
end

function B = Multi_criteria(A)
    A = A.';
    for j = 1: 4
        A(:, j) = A(:, j) / norm(A(:, j), 1);
    end
    [V, D] = eig(A);
    v1 = real(V(:, 1));
    v1 = v1 / norm(v1, 1);
    if v1(1) < 0
        v1 = -v1;
    end
    B = v1.';
end

function B = mapminmaxEx1(A, lb, ub)
    max_A = max(A);
    min_A = min(A);
    B = (A - min_A) ./ (max_A - min_A) * (ub - lb) + lb;
end