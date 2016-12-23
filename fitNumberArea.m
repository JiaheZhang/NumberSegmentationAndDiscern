function [ newImage ] = fitNumberArea(image)
%FINDNUMBERAREA 此处显示有关此函数的摘要
%   输入参数为原图
%   输出为大小64 * 64的新图  数字位于最大可能的正中间
%   为了归一更准确的判断数字
rows = size(image,1);
cols = size(image,2);

x1 = cols;
x2 = cols;
y1 = rows;
y2 = rows;

%% 检测四个坐标
sumX = sum(image);
sumY = sum(image,2);

for i = 1:cols
    if(sumX(i) ~= rows)
        x1 = i;
        break;
    end
end

for i = cols: -1 :1
    if(sumX(i) ~= rows)
        x2 = i;
        break;
    end
end

for i = 1:rows
    if(sumY(i) ~= cols)
        y1 = i;
        break;
    end
end

for i = rows:-1:1
    if(sumY(i) ~= cols)
        y2 = i;
        break;
    end
end

newImage = image(y1:y2,x1:x2);

%% 图像补全

subY = y2 - y1 + 1;
subX = x2 - x1 + 1;

if(subY >= subX)
    disLeft = round((subY - subX) / 2);
    disRight = subY - subX - disLeft;
    
    makeupLeftMat = ones(subY,disLeft);
    makeupRightMat = ones(subY,disRight);
    
    newImage = [makeupLeftMat,newImage,makeupRightMat];
    
else
    disUp = round((subX - subY) / 2);
    disDown = subX - subY - disUp;
    
    makeupUpMat = ones(disUp,subX);
    makeupDownMat = ones(disDown,subX);
    
    newImage = [makeupUpMat;newImage;makeupDownMat];
    
end
[m,n] = size(newImage);

newImage = 255 - imresize(newImage,64 / m,'nearest') * 255;


end

