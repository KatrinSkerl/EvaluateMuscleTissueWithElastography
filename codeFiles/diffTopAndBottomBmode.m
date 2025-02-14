% This is the function that calculates the difference between the top and 
% the bottom image.
%
%
% Input: 
%         
%
% Output:
%         
%
% Used functions:
%         
% % Function used in:
%       - main_GridAnalysis()
%
% author: Mehrin Azan, Katrin Skerl, HFU
% date: 10/02/2022



BmodeImgTop = im(imgBmodeTopStartRow:imgBmodeTopEndRow, imgBmodeStartCol:imgBmodeEndCol, :);
BmodeImgBottom = im(imgBmodeBottomStartRow:imgBmodeBottomEndRow, imgBmodeStartCol:imgBmodeEndCol, :);



figure; imshow(BmodeImgBottom)
figure; imshow(BmodeImgTop)
Bsub = BmodeImgTop - BmodeImgBottom;
figure; imshow(Bsub)
