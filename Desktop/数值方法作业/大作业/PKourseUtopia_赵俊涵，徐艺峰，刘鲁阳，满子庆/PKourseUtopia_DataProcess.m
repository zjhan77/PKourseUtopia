clc; clear all; close all; format compact;
% ！！！注意这里的路径！！！
% 读入文件（这里依次修改对应的课程名），将所有的评价最终化为一个特征向量
name = "自然资源与社会发展"
id = "28";
A = readmatrix("raw_data/"+name+".xlsx", "OutputType", "string");
n = size(A); n = n(1);
A = A(2: n, :);
n = n - 1

% 分别是课程类别(string), 标题(n*1 string), 评分(n*5 double), 点赞数(n*1 double)和gpt处理得到的另外5维特征(n*5 double)
class_type = A(1, 1)
phrases = A(:, 7);
grade = str2double(A(:, 2: 5));
likes = str2double(A(:, 6));
feature_1 = str2double(A(:, 9: 11));
feature_2 = str2double(A(:, 12: 13));

% 点赞数归一化，作为将不同的评论打分加权平均的权重
likes = mapminmaxEx1(likes, 0, 1);
likes = likes ./ sum(likes);

grade = grade .* likes;
grade = sum(grade)

feature_1 = sum(feature_1) ./ n;
feature_1(1) = judgement(feature_1(1), 0.4);
feature_1(2) = judgement(feature_1(2), 0.6);
feature_1(3) = judgement(feature_1(3), 0.6);
feature_1

feature_2 = feature_2 .* likes;
feature_2 = sum(feature_2)

% 将name, class_type, grade, feature1, feature2拼成一行就是最终的课程名+特征向量
writematrix(name, 'data.xlsx', "FileType", "spreadsheet", "Range", "A"+id); 
writematrix(class_type, 'data.xlsx', "FileType", "spreadsheet", "Range", "B"+id); 
writematrix(grade, 'data.xlsx', "FileType", "spreadsheet", "Range", "C"+id); 
writematrix(feature_1, 'data.xlsx', "FileType", "spreadsheet", "Range", "G"+id); 
writematrix(feature_2, 'data.xlsx', "FileType", "spreadsheet", "Range", "J"+id); 

% 归一化函数
function B = mapminmaxEx1(A, lb, ub)
    max_A = max(A);
    min_A = min(A);
    B = (A - min_A) ./ (max_A - min_A) * (ub - lb) + lb;
end

% 判断是否有小组作业、考试、论文，给出一个0或1的值
function ans = judgement(ratio, threshold)
    if ratio > threshold
        ans = 1;
    else
        ans = 0;
    end
end

