% Calculates the difference between top and bottom image.
% Mainly for testing only. 
% 
%
% author Mehrin Azan, HFU
% 



BmodeImgTop = im(imgBmodeTopStartRow:imgBmodeTopEndRow, imgBmodeStartCol:imgBmodeEndCol, :);
BmodeImgBottom = im(imgBmodeBottomStartRow:imgBmodeBottomEndRow, imgBmodeStartCol:imgBmodeEndCol, :);



figure; imshow(BmodeImgBottom)
figure; imshow(BmodeImgTop)
Bsub = BmodeImgTop - BmodeImgBottom;
figure; imshow(Bsub)
