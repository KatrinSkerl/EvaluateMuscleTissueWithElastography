function [scaleFactorHeight, scaleFactorWidth] = scale(im, positionBmode, threshBW) 

% This function finds the pixel height in each image in cm.
% It uses the coordinates of the Bmode image.
% The pixel height is the scale factor used to convert results in pixels to
% cm.
%
% Input values: im - Full original image  
%               positionBmode - Bmode image coordinates in original image,
%                               output of function segmentBmodeNew()
%              
% Output values: scaleFactorHeight -  pixel height
%                                  - Used in: drawGrid()
%                scaleFactorWidth - pixel width
%                                  - Used in: drawGrid()
%
% Function used in:
%       - main_GridAnalysis()
%
% Author: Mehrin Azan, Hochschule Furtwangen  
% date: 10/02/2022
              
    imgray = rgb2gray(im); % Convert image to grayscale
    threshBW = 0.5; %24/05/2022 set to a constant value. We might need to change this later on again.
    BW = imbinarize(imgray,threshBW); % Binarise image
    
    % HEIGHT ----------------------------------------
    scaleH = BW(positionBmode(1)+20:positionBmode(2), positionBmode(4)+1:positionBmode(4)+3);
    
    sumRows = sum(scaleH, 2);          % Find the sum of each row in binary image
    linesH = find(sumRows>0, 2);             % Find two lines
    
    % Check if two lines are next to each other
    % If so, take next line
    if linesH(2) - linesH(1) <=5
    
        % Replace first value with max value
        if linesH(2) > linesH(1)
            linesH(1) = linesH(2);
        end
    
        % For second value, find next line
        fac = 6;
        linesHNew = find(sumRows((linesH(1)+fac):end)>0, 1);
        linesH(2) = linesH(1)+(fac-1)+linesHNew;
    end
    
    firstLineH = linesH(1);
    nextLineH = linesH(2);
    
    distLinesH = nextLineH - firstLineH;       % Subtract second line from first to get distance
    
    % Height of 1 pixel in cm returns scale factor:
    scaleFactorHeight = 0.5 / distLinesH; 
    
    
    % WIDTH ---------------------------------------------------
    scaleW = BW(positionBmode(1)-4:positionBmode(1)-1, positionBmode(3)+20:positionBmode(4));
    
    sumCols = sum(scaleW, 1);          % Find the sum of each row in binary image
    
    linesW = find(sumCols>0, 2);             % Find two lines
    
    % Check if two lines are next to each other
    % If so, take next line
    if linesW(2) - linesW(1) <= 5
    
        % Replace first value with max value
        if linesW(2) > linesW(1)
            linesW(1) = linesW(2);
        end
    
        % For second value, find next line
        fac = 6;
        linesWNew = find(sumCols((linesW(1)+fac):end)>0, 1);
        linesW(2) = linesW(1)+(fac-1)+linesWNew;
    end
    
    firstLineW = linesW(1);
    nextLineW = linesW(2);
    
    distLinesW = nextLineW - firstLineW;       % Subtract last line from first to get distance
    
    % Height of 1 pixel in cm returns scale factor:
    scaleFactorWidth = 0.5 / distLinesW; 

    %26/8/22 to test
    scaleFactorWidth = scaleFactorHeight;


end

