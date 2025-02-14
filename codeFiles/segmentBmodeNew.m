function [BmodeImg, positionBmode, positionBmodeBottom, noUltrasound, threshBW] = segmentBmodeNew(im)
%
% This is a function that segments the top and bottom Bmode image from the
% entire SWE ultrasound image. It does so by binarising the image and
% finding abrupt changes in blob sizes and image values to detect where the
% B-Mode images lie.
% Input: 
%         im - entire SWE ultrasound image containing two B-Mode images in
%         a top-and-bottom layout
% Output:
%         BmodeImg - Top image containing SWE
%                  - Used in: getSWEImg()
%         positionBmode - Position of upper B-Mode image (row1:, row2,
%                         col1, col2)
%                       - Used in: scale()
%         positionBmodeBottom - Position of lower B-Mode image (row1:, row2,
%                               col1, col2)
%                             - Can be used to segment lower B-Mode image
%                               (not required for this application)
%         noUltrasound - To check whether ultrasound is detectable in image
%
%         threshBW - threshold to binarise image
%                  - Used in: scale()
%
% Used functions:
%         
% Function used in:
%       - main_GridAnalysis()
%       - main_ROIAnalysis()
%       
%
%
% author: Katrin Skerl, Mehrin Azan, HFU
% date: 23/06/22 based on version from 10/02/2022
% comment new version to evaluate derivative of sum vector

noUltrasound = 0;

[rowImg, colImg, ~] = size(im);
imgray = rgb2gray(im); % Convert image to grayscale

% Find threshold to binarise
imgArea = rowImg*colImg;
BWtemp = imbinarize(imgray);
sumBW = sum(sum(BWtemp));
areaBW = sumBW/(imgArea/100); % Find how many % pixels in foreground

% Lower threshold if fewer pixels in foreground (= darker image)
% Higher threshold if more pixels in foreground (= brighter image)
if areaBW < 20
    threshBW = 0.001;
elseif areaBW > 45
    threshBW = 0.1;
else
    threshBW = 0.05;
end
BW = imbinarize(imgray,threshBW); % Binarise image

% Find start and end of Bmode image colums 
sumRows = sum(BW, 2); % Sum rows 

% Fill top and bottom black if white strip where headings etc are
if sumRows(1) > (colImg*0.7)
    cropWhiteTop = find(sumRows<(colImg*0.1), 1, 'first');
    BW(1:cropWhiteTop+1, :) = 0;
end
if sumRows(end) > (colImg*0.7)
    cropWhiteBottom = find(sumRows<(colImg*0.1), 1, 'last');
    BW(cropWhiteBottom-1:end, :) = 0;
end

% Find largest objects based on area of blobs
blobAreas = regionprops(BW, 'Area');
objectAreas = [blobAreas.Area];
[sortedAreas, ~] = sort(objectAreas, 'descend'); % Sort in descending order
d = diff(sortedAreas); % Find differences between areas
d = abs(d);

% Find maximum difference to separate largest objects from smaller ones
maxDiff = max(d);
objectsToKeep = find(d==maxDiff, 1, 'first');

% Only keep largest objects
BW2 = bwareafilt(BW,objectsToKeep);


% Find start and end of Bmode image rows --------------
sumRows = sum(BW2, 2);  
slopesRows = diff(sumRows); % Find derivative to find changes in values
slopesRows = abs(slopesRows);
thRows = 80; %edit 20220902 set to 80 instead of 100 eidt 20220621 as error with: mean(sumRows)/2;
slopesRows(slopesRows<thRows) = 0;

% Find local maxima
[~,locsRows] = findpeaks(slopesRows);

% There should only be 4 maximas indicating the start and end of both
% B-Mode images. 

if max(size(locsRows)) == 4

    % Bmode images, rows only
    imgBmodeTopStartRow = locsRows(1); % Start of top Bmode image
    imgBmodeTopEndRow = locsRows(2); % End of top Bmdoe image
    imgBmodeBottomStartRow = locsRows(3); % Start of bottom Bmode image
    imgBmodeBottomEndRow = locsRows(end); % End of bottom Bmode image
    
  

else 
    %noUltrasound = 1;
    %positionBmode = 0;
    %positionBmodeBottom = 0;
    imgBmodeTopStartRow = find(slopesRows(1:400)==max(slopesRows(1:400)),1,'first');
    %find(slopesRows>thRows,1,'first');
    imgBmodeTopEndRow = imgBmodeTopStartRow+100 + find(slopesRows(imgBmodeTopStartRow+100:end)>thRows,1,'first');
    imgBmodeBottomStartRow = 0;%set to 0 as not used in the furthcomming 
    imgBmodeBottomEndRow = 0;
end

% Find start and end of Bmode image colums --------------
sumCols = sum(BW2, 1);  
sumCols = abs(diff(sumCols));
imgBmodeStartCol = find(sumCols(1:700)==max(sumCols(1:700)));
imgBmodeEndCol = 700 + find(sumCols(700:end)==max(sumCols(700:end)));

% %  Find where 0.05*maximum of column sum begins and ends
% thCol = 0.05*max(sumCols);
% imgBmodeStartCol = find(sumCols > thCol, 1, 'first');
% imgBmodeEndCol = find(sumCols > thCol, 1, 'last');

% Output
BmodeImg = im(imgBmodeTopStartRow:imgBmodeTopEndRow, imgBmodeStartCol:imgBmodeEndCol, :);
positionBmode = [imgBmodeTopStartRow, imgBmodeTopEndRow, imgBmodeStartCol, imgBmodeEndCol];
positionBmodeBottom = [imgBmodeBottomStartRow, imgBmodeBottomEndRow, imgBmodeStartCol, imgBmodeEndCol];

% Check to ensure ultrasound image is visible
% Largest blob must make up more than 15% of image area
% If not, ultrasound was not detected, noUltrasound = 1.
perc1 = imgArea/100; 
regionArea = sortedAreas(1);
percRegion = regionArea/perc1;

if percRegion < 15
    noUltrasound = 1;
    BmodeImg = im;

end

end