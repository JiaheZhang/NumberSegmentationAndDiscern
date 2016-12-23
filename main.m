clear all;
close all;
%% 载入匹配模板
global templateNumber;
load('templateNumber.mat')
%% 二值化 
image = imread('testAll.jpg');
se=strel('line',2,2);
image=imdilate(image,se);
bImage = im2bw(image,graythresh(image)); %二值化

%% 求坐标
sumY = sum(bImage,2);
[rows,cols] = size(bImage);


newNumberFlag = 1;
findNumberFlag = 0;
numberRows = 0; %行数

for i = 1:rows
    if(newNumberFlag == 1)
        if(sumY(i) ~= cols)%存在字符
            findNumberFlag = 1;
            numberRows = numberRows + 1;
            rowsStartAndEnd(numberRows,1) = i;%储存第i个的起始行
            newNumberFlag = 0;
        end
    end
    if(findNumberFlag == 1)
        if(sumY(i) == cols)%字符结束
            rowsStartAndEnd(numberRows,2) = i;%储存第i个的结束行
            findNumberFlag = 0;
            newNumberFlag = 1;
        end
    end
end

newNumberFlag = 1;
findNumberFlag = 0;

j = 1;

while(j <= numberRows)
    numberCols = 0; %列数
    m = rowsStartAndEnd(j,1);
    n = rowsStartAndEnd(j,2);
    sumX = sum(bImage(m:n,:));
    
    for i = 1:cols
        if(newNumberFlag == 1)
            if(sumX(i) ~= n - m + 1)
                findNumberFlag = 1;
                numberCols = numberCols + 1;
                colsStartAndEnd(j,2 * numberCols - 1) = i;%储存第i个的起始列
                newNumberFlag = 0;
            end
        end

        if(findNumberFlag == 1)
            if(sumX(i) == n - m + 1)%字符结束
                colsStartAndEnd(j,2 * numberCols) = i;%储存第i个的结束列
                findNumberFlag = 0;
                newNumberFlag = 1;
            end
        end
    end
    j = j + 1;
end
%% 统计字数 并将坐标存入pos
row = size(colsStartAndEnd,1);
col = size(colsStartAndEnd,2) / 2;
numberCnt = 0;
for i = 1:row
    everyRowNumberCnt = 0;
    for j = 1:col
        if(colsStartAndEnd(i,j * 2) ~= 0)
            numberCnt = numberCnt + 1;
            everyRowNumberCnt = everyRowNumberCnt + 1;
            pos(numberCnt,1) = colsStartAndEnd(i,j * 2 - 1);
            pos(numberCnt,2) = colsStartAndEnd(i,j * 2);
            pos(numberCnt,3) = rowsStartAndEnd(i,1);
            pos(numberCnt,4) = rowsStartAndEnd(i,2);
        else
            break;
        end
    end
    everyRowCnt(i) = everyRowNumberCnt;%记录每行的个数
end

%% 将每个预分割的坐标进行范围缩小
for i = 1:numberCnt
    x1 = pos(i,1);
    x2 = pos(i,2);
    y1 = pos(i,3);
    y2 = pos(i,4);
    sumY = sum(bImage(y1:y2,x1:x2),2);
    
    for j = y1:y2
        if(sumY(j - y1 + 1) ~= x2 - x1 + 1)
            pos(i,3) = j;
            break;
        end
    end
    
    for j = y2:-1:y1
        if(sumY(j - y1 + 1) ~= x2 - x1 + 1)
            pos(i,4) = j;
            break;
        end
    end
    
end

%% 在原图上画分割字符
for i = 1:numberCnt
    x1 = pos(i,1);
    x2 = pos(i,2);
    y1 = pos(i,3);
    y2 = pos(i,4);
    image(y1:y2,x1,2) = 0;
    image(y1:y2,x2,2) = 0;
    image(y1,x1:x2,2) = 0;
    image(y2,x1:x2,2) = 0;

end
figure
imshow(image);
%% 对每个字符进行判定 根据每行的个数分行
row = 0;
for i = 1:numberCnt
    if(i > sum(everyRowCnt(1:row + 1)))
        finalNumber(i + row) = 55; 
        row = row + 1;
    end
    col = col + 1;
    x1 = pos(i,1);
    x2 = pos(i,2);
    y1 = pos(i,3);
    y2 = pos(i,4);
    numberImage = fitNumberArea(bImage(y1:y2,x1:x2));
    finalNumber(i + row) = matchNumber(numberImage);
end

%% 文件写入txt
 fid = fopen('number.txt','w');
 for i = 1:size(finalNumber,2);
     temp = finalNumber(i);
     if(temp == 55)
         fprintf(fid,'\n');
     else
        fprintf(fid,'%g\t',temp);
     end
 end

 fclose(fid);



