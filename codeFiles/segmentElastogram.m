function [positionBmode,threshBW, position, SWEImg] = segmentElastogram(img1)
% This is the function that segments the elastogram from the SWE image.
%
% Input: 
%         img - input image
%
% Output:
%         positionBmode - position of the B-mode image within entire image
%         threshBW - binarisation threshold
%         position - position of SWE image
%         SWEImg - segmented SWE image
%
% Used functions:
%         
%
% author: Mehrin Azan, Katrin Skerl, HFU
% date: 10/02/2022

[Bimg, positionBmode, positionBmodeBottom, ~, threshBW] = segmentBmodeNew(img1);
BimgButtom = img1(positionBmodeBottom(1): positionBmodeBottom(2), positionBmodeBottom(3): positionBmodeBottom(4),:);
[SWEImg,position] = GetSWEImg_orange(Bimg,BimgButtom);
end