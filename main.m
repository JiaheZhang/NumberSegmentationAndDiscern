clear all;
close all;
%% ����ƥ��ģ��
global templateNumber;
load('templateNumber.mat')
%% ��ֵ�� 
image = imread('testAll.jpg');
se=strel('line',2,2);
image=imdilate(image,se);
bImage = im2bw(image,graythresh(image)); %��ֵ��

%% ������
sumY = sum(bImage,2);
[rows,cols] = size(bImage);


newNumberFlag = 1;
findNumberFlag = 0;
numberRows = 0; %����

for i = 1:rows
    if(newNumberFlag == 1)
        if(sumY(i) ~= cols)%�����ַ�
            findNumberFlag = 1;
            numberRows = numberRows + 1;
            rowsStartAndEnd(numberRows,1) = i;%�����i������ʼ��
            newNumberFlag = 0;
        end
    end
    if(findNumberFlag == 1)
        if(sumY(i) == cols)%�ַ�����
            rowsStartAndEnd(numberRows,2) = i;%�����i���Ľ�����
            findNumberFlag = 0;
            newNumberFlag = 1;
        end
    end
end

newNumberFlag = 1;
findNumberFlag = 0;

j = 1;

while(j <= numberRows)
    numberCols = 0; %����
    m = rowsStartAndEnd(j,1);
    n = rowsStartAndEnd(j,2);
    sumX = sum(bImage(m:n,:));
    
    for i = 1:cols
        if(newNumberFlag == 1)
            if(sumX(i) ~= n - m + 1)
                findNumberFlag = 1;
                numberCols = numberCols + 1;
                colsStartAndEnd(j,2 * numberCols - 1) = i;%�����i������ʼ��
                newNumberFlag = 0;
            end
        end

        if(findNumberFlag == 1)
            if(sumX(i) == n - m + 1)%�ַ�����
                colsStartAndEnd(j,2 * numberCols) = i;%�����i���Ľ�����
                findNumberFlag = 0;
                newNumberFlag = 1;
            end
        end
    end
    j = j + 1;
end
%% ͳ������ �����������pos
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
    everyRowCnt(i) = everyRowNumberCnt;%��¼ÿ�еĸ���
end

%% ��ÿ��Ԥ�ָ��������з�Χ��С
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

%% ��ԭͼ�ϻ��ָ��ַ�
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
%% ��ÿ���ַ������ж� ����ÿ�еĸ�������
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

%% �ļ�д��txt
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



