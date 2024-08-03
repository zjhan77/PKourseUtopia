clc; clear all; close all; format compact;
%%读取excel并摘出名称供后续使用
name = readmatrix("data.xlsx", "OutputType", "string");
name = name(:,1);

%%读取excel并对数据部分操作
data = readmatrix("data.xlsx", "OutputType", "double");
A = data(:,3:11);%%将除去名字与类别之外的十一列拿出来

%%PCA降维
%%将A做标准化
A_avg = mean(A);
A_std = std(A);
std_A = (A-A_avg)./A_std;

%%计算协方差矩阵并把特征值降序排列，取前两维/三维
cov_matrix = cov(std_A);
[V,D] = sort_eig(cov_matrix);
m = 3;    
V_m = V(:,1:m);
projected_A = std_A * V_m;

%%展示kmeans结果
TOL = 0.0004;
ITER = 100;
kappa = 6;
[C,I,iter] = MyKmeans(projected_A, kappa, ITER, TOL);
color = {'r','g','b','k','c','m','y'};

%%考察每一类都有哪些课程
for i = 1:kappa
    fprintf('%d:\n',i);
    for j = 1:max(size(projected_A))
        if I(j) == i
            fprintf('%s\n',name(j));
        end
    end
end


%%第一种展示方法：只展示聚类图
for i = 1:kappa       
   hold on 
    %plot(projected_A(find(I == i),1),projected_A(find(I == i),2),'.','MarkerSize',30,'color',color{i});
    plot3(projected_A(find(I == i),1),projected_A(find(I == i),2),projected_A(find(I == i),3),'.','MarkerSize',30,'color',color{i});
    %%text(projected_A(i,1),projected_A(i,2),name(i));
    %%text(projected_A(i,1),projected_A(i,2),projected_A(i,3),name(i));
    %%scatter(projected_A(find(I == i),1),projected_A(find(I == i),2),projected_A(find(I == i),3),300,color{i},'filled');
end
    
        
%%第二种展示方法：展示聚类图且表明课程名
%bug1：这么写输出的图像只展示一门课程，原因未知    
%for i = 1:max(size(projected_A))
%    scatter(projected_A(i,1),projected_A(i,2),100,color{I(i)},'filled');
%    text(projected_A(i,1),projected_A(i,2),name(i));
%end        
    
%%kmeans函数
%%参数含义：X为数据，K为聚类中心个数，maxIter为最大迭代次数，TOL为忍量
function [C,I,iter] = MyKmeans(X, K, maxIter, TOL)
    [vectors_num, dim] = size(X);
    R = randperm(vectors_num);
    %%记录80个向量分别属于哪个类
    I = zeros(vectors_num,1);
    %%记录上一次迭代的I
    Ilast = zeros(vectors_num,1);
    %%K个聚类中心的坐标
    C = zeros(K,dim);
    %%随机选择K个点作为中心
    for j = 1:K
        C(j,:) = X(R(j),:);
    end
    iter = 0;
    while 1
        %%对每个点找最近的中心
        Ilast = I;
        for n = 1:vectors_num
            %%minIdx为最近中心的序号
            minIdx = 1;
            %%minVal为该点距离最近中心的距离
            minVal = norm(X(n,:) - C(minIdx,:),2);
            cnt = 0;
            for j = 1:K
                cnt = cnt + 1;
                dist = norm(C(j,:) - X(n,:),2);
                if dist < minVal
                    minIdx = cnt;
                    minVal = dist;
                end
            end
            %%第n个点属于哪个中心
            I(n) = minIdx;
        end
        %%bug2：经过上述二重循环后加断点输出结果发现所有点都被判定属于第一个中心点或者第四个中心点
        %%但是过程中可以看到有些点是距离第二或者第三中心点更近的，但仍会被判断为距离第一或第四中心点更近
        %%从而导致第二第三中心点区域内点数为0，导致后续程序出现错误，结果图只有两种分类，原因未知
        
        %%用属于该中心的点的坐标平均值作为新的聚类中心
        for k = 1:K
            C(k,:) = sum(X(find(I == k), :));
            C(k,:) = C(k,:) / length(find(I == k));
        end
        %%这里的RSS_error是路条视频中的一种误差计算方法，但是卢眺老师表示不能理解，希望同学们可以自己写误差函数
        %%我们可以采用聚类中心偏移量之和来度量误差，但从结果上来看这个误差计算方法暂时可行，
        %%因此暂时不改动这个误差计算方法，先解决上面两个bug更为要紧
        RSS_error = 0;
        for idx = 1:vectors_num
            RSS_error = RSS_error + norm(X(idx,:) - C(I(idx),:),2);
        end
        RSS_error = RSS_error / vectors_num;
        %%迭代次数+1
        iter = iter + 1;
        %%如果改变量小于忍量则结束
        %if 1/RSS_error < TOL
        %    break;
        %end
        %%如果每个点的中心相比上次迭代的中心不再变化则结束
        change = false;
        for idx = 1:vectors_num
            if I(idx) != Ilast(idx)
                change = true;
            end
        end
        if change == false
            iter = iter - 1;
            break;
        end
        %%如果超过最大迭代次数则停止
        if iter > maxIter
            iter = iter - 1;
            break;
        end
    end
    %%显示通过多少次迭代完成分类任务
    disp(['k-means took ' num2str(iter) ' steps to converge']);
end
        
%%将矩阵特征值降序排列供后续降维使用
function [VV,DD] = sort_eig(A)
    [V,D] = eig(A);
    d = diag(D);
    [dd,ii] = sort(d,"descend");
    DD = diag(dd);
    VV = V(:,ii);
end