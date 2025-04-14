function [SWEImg,position] = GetSWEImg_orange(BmodeImg, BmodeImgButtom)

% This is a function that segments the SWE image from the segmented
% B-Mode image. The SWE image is surrounded by an orange frame. This is
% easiest to be detected in the buttom B-mode image where no other colours
% are included in the image. Orange is characterised by high values on the
% R-map and low values on the B-map, whereas grey and white have similar
% values on all three colourmaps. Thus, the difference between the R-map
% and the B-map are calculated and then the frame is detected. The position
% of the SWE image within the B-mode image is identical in the upper and
% the lower image and thus the SWE image cam be segmented.
%
% Input: 
%         BmodeImg - upper B-Mode image containing SWE, output of function 
%                    segmentBmodeNew()
%         BmodeImgButtom - buttom B-mode image
%         
% Output:
%         SWEImg - Cropped SWE region
%         position - coordinates of SWE region (rowStart, rowEnd, colStart,
%         colEnd)
%
% Used in: drawGrid()                 
%
% Used functions:
%         
% Function used in:
%       - main_GridAnalysis()
%       - main_ROIAnalysis()
%
% author: Katrin Skerl, HFU
% date: 28/08/22 based on the function GetSWEImg_m by Mehrin Azan

%calculate the difference between the R and B images
diffImg = abs(BmodeImgButtom(:,:,1)-BmodeImgButtom(:,:,3));
%convert into logical image which includes only the frame
diffImg = imbinarize(diffImg,0.2); 
%calculate the sum of the rows and coloums of the image
sumRows = sum(diffImg,2);
sumCols = sum(diffImg,1);
   
% Find start and end row of SWE image
rowLocs(1) = find(sumRows > 10, 1, 'first');
rowLocs(2) = find(sumRows > 10, 1, 'last');
colLocs(1) = find(sumCols > 10, 1, 'first');
colLocs(2) = find(sumCols > 10, 1, 'last');

SWEImg = BmodeImg(rowLocs(1):rowLocs(2), colLocs(1):colLocs(2), :);
position = [rowLocs(1),rowLocs(2), colLocs(1),colLocs(2)];
end