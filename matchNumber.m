function [ number ] = matchNumber( inputImage )
%UNTITLED �˴���ʾ�йش˺�����ժҪ
%   
global templateNumber;
global subAll;
sumY = sum(inputImage,2);

for i = 1:10
    subAll(i) = sum(abs(sumY - templateNumber(:,i)));
end

number = find(subAll == min(subAll),1) - 1;

end

