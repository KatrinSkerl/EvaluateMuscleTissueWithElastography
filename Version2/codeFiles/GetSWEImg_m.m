function [SWEImg,position] = GetSWEImg_m(BmodeImg)

% This is a function that segments the SWE image from the segmented upper
% B-Mode image. It does so by detecting brighter pixels, which indicate the
% bright rectangular border surrounding the SWE region.
% It uses the cropped upper BMode image from the output of
% the function segmentBmodeNew.
%
% Input: 
%         BmodeImg - upper B-Mode image containing SWE, output of function 
%                    segmentBmodeNew()
%         
% Output:
%         SWEImg - Cropped SWE region
%                - Used in: drawGrid()
%         position - coordinates of SWE region (rowStart, rowEnd, colStart,
%         colEnd)
%                  - Used in: 
%
% Used functions:
%         
% Function used in:
%       - main_GridAnalysis()
%       - main_ROIAnalysis()
%
% author: Mehrin Azan, HFU
% date: 10/02/2022

% Input: single bmode image
thresh = 1;
% Subtract colour channels
idx = abs(BmodeImg(:,:,1)-BmodeImg(:,:,2))<=thresh & abs(BmodeImg(:,:,2)-BmodeImg(:,:,3))<=thresh;
inv2 = imcomplement(idx); % Invert image
inv = bwpropfilt(inv2,'perimeter',1); % Only keep object with largest perimeter (SWE image)

sumRows = sum(inv, 2); % Sum vector for rows 
maxRow = max(sumRows);
imLimRow = maxRow * 0.75; % Find 75% value of rows

sumCols = sum(inv, 1);  % Sum vector for colums
maxCol = max(sumCols);
imLimCol = maxCol * 0.75; % Find 75% value of columns

% Find start and end row of SWE image
rowLocs(1) = find(sumRows > imLimRow, 1, 'first');
rowLocs(2) = find(sumRows > imLimRow, 1, 'last');
colLocs(1) = find(sumCols > imLimCol, 1, 'first');
colLocs(2) = find(sumCols > imLimCol, 1, 'last');

SWEImg = BmodeImg(rowLocs(1):rowLocs(2), colLocs(1):colLocs(2), :);
position = [rowLocs(1),rowLocs(2), colLocs(1),colLocs(2)];
end