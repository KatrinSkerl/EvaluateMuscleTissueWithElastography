function [positionBmode,threshBW, position, SWEImg] = segmentElastogram(img1)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


[Bimg, positionBmode, positionBmodeBottom, ~, threshBW] = segmentBmodeNew(img1);
%BimgButtom = img1(imgBmodeBottomStartRow: imgBmodeBottomEndRow, imgBmodeStartCol: imgBmodeEndCol,:);
BimgButtom = img1(positionBmodeBottom(1): positionBmodeBottom(2), positionBmodeBottom(3): positionBmodeBottom(4),:);
[SWEImg,position] = GetSWEImg_orange(Bimg,BimgButtom);
end