clc; clear all; close all; format compact;
% 读入数据，n为行数即课程门数
data = readmatrix("data.xlsx", "OutputType", "string");
n = size(data); n = n(1);
    
 
name = data(:, 1);

x = zeros(1, 8);
/*输入处理*/
fprintf("请从以下八个维度描绘你心仪的通选课程：\n");
x(1) = input("知识学习体验（由1至5，5为体验最佳）：");
x(2) = input("工作量友好程度（由1至5，5为最友好）：");
x(3) = input("考核友好程度（由1至5，5为最友好）：");
x(4) = input("课堂有趣程度（由1至5，5为最有趣）：");
x(5) = input("社交程度（由1至5，5非常需要社交）：");
x(6) = input("是否有小组作业（1代表有，0代表无，-1代表无所谓）：");
x(7) = input("是否考试（1代表有，0代表无，-1代表无所谓）：");
x(8) = input("是否有论文（1代表有，0代表无，-1代表无所谓）：");

for i = 1:5
    if x(i) < 1 || x(i) > 5
        fprintf("输入格式错误，请重新输入\n");
        error;
    end
end

for i = 6:8
    if x(i) ~= 1 && x(i) ~= 0 && x(i) ~= -1
       fprintf("输入格式错误，请重新输入\n");
        error;
    end
end 

/*从读入数据中构造用于筛选课程的矩阵*/

M = zeros(n, 9);
for i = 1:n
    M(i, 1) = i;
end
M(:, 2:4) = str2double(data(:, 4:6));
M(:, 5:6) = str2double(data(:, 10:11));
M(:, 7:9) = str2double(data(:, 7:9));

/*筛选课程*/

M_size = size(M);
Cand = zeros(M_size);
Cand_column = 1;
column = M_size(1);
Err_value = zeros(1, column);

for i = 1:column
    if M(i, 7) == x(6) || x(6) == -1
        if M(i, 8) == x(7) || x(7) == -1
            if M(i, 9) == x(8) || x(8) == -1
                Cand(Cand_column,:) = M(i,:);
                Err_value(Cand_column) = Calculate(Cand(Cand_column,:), x);
                Cand_column = Cand_column + 1;
            end
        end
    end
end

Cand_column = Cand_column - 1;
Cand = Cand(1:Cand_column, :);
Err_value = Err_value(1: Cand_column);

/*产生推荐列表*/
[~, sortIndex] = sort(Err_value); 
sortedCand = Cand(sortIndex, :);

recommend_list = sortedCand(:, 1);
R_size = size(recommend_list);
if R_size(1) > 15
    recommend_list = recommend_list(1:15);
end
    
for i = 1:length(recommend_list)
    courseName = name(recommend_list(i));
    fprintf("%s\n", courseName);
end

function num = Calculate(X,Y)
    num = 0;
    for i = 2:6
        num = num + (X(i) - Y(i - 1))^2;
    end
    num = sqrt(num);
end    

