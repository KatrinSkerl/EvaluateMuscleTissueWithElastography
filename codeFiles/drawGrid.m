function [imgGrid, locsHor, locsVer] = drawGrid(SWEImg, scaleFactorHeight, scaleFactorWidth, offsetX, offsetY)

% This is the function that draws a grid over the SWE image.
%
% It reads in the offset values aand starting from the offset, it 
% calculates the coordinates of the grid lines horizontally and vertically 
% while maintaining a 4mm distance between them. These lines are then
% plotted on the SWE image.
%
% Input: 
%         SWEImg - cropped SWE region, output of GetSWEImg_m()
%         scaleFactorHeight - scale factor for height, output of scale()
%         scaleFactorWidth -  scale factor for width, output of scale() 
%         offsetX - offset value in x-direction in mm
%         offsetY - offset value in y-direction in mm
%
% Output:
%         imgGrid - cell array containing analysis results
%                 - Used in: GUI to display grid image
%         locsHor - coordinates of horizontal lines
%                 - Used in: main_GridAnalysis()
%         locsVer - coordinates of vertical lines
%                 - Used in: main_GridAnalysis()
%
% Used functions:
%         
% % Function used in:
%       - main_GridAnalysis()
%
% author: Mehrin Azan, Katrin Skerl, HFU
% date: 10/02/2022



    [rows, columns, ~] = size(SWEImg); 

    % Convert offset from mm to cm
    offsetX = offsetX / 10;
    offsetY = offsetY / 10;
    
    % Default: First square center is 2 mm in from top and left
    % Check for 0 mm input
    if offsetX == 0
        gridStartRow = 1;
    else
        gridStartRow = 0 + (round(offsetX/scaleFactorHeight));
    end
    if offsetY == 0
        gridStartCol = 1;
    else
        gridStartCol = 0 + (round(offsetY/scaleFactorWidth));  
    end
    
    % Length of horizontal lines
    lenHor = columns;
    
    % Length of vertical lines
    lenVer = rows;
    
    m = 1;
    n = 1;
    
    % First vertical line
    locsVer(1, 1) =  gridStartRow;
    
    % First horizontal line
    locsHor(1, 1) = gridStartCol;
    
    % Matrix for vertical lines
    % Get x coordinates for vertical lines
    while locsVer(1, m) < lenHor
        % Keep adding 4 mm to previous line
        locsVer(1, m+1) = locsVer(1, m) + (round(0.4/scaleFactorHeight));
        m = m+1;
    end
    
    % Remove last cell if value goes above limit
    if locsVer(:,end) > lenHor
        locsVer(:,end) = [];
    end
    
    % Add length of vertical line to second row of matrix
    locsVer(2, :) = lenVer;
    
    % Matrix for horizontal lines
    % Get y coordinates for horizontal lines
    while locsHor(1, n) < lenVer
        % Keep adding 4 mm to previous line
        locsHor(1, n+1) = locsHor(1, n) + (round(0.4/scaleFactorWidth));
        n = n+1;
    end
    
    % Remove last cell if value goes above limit
    if locsHor(:,end) > lenVer
        locsHor(:,end) = [];
    end
    
    % Add length of horizontal line to second row of matrix
    locsHor(2, :) = lenHor;
    
    
    
    % locsHor = locs for horizontal lines
    % locsVer = locs for vertical lines
    
    i = 1;
    j = 1;
    
    imgGrid = SWEImg;
    
    % Draw horizontal lines on image
    %lenHorLocs = max(size(locsHor));
    %27/8/22
    lenHorLocs = size(locsHor,2);
    
    while i <= lenHorLocs
        imgGrid((locsHor(1, i): locsHor(1, i)), (1: locsHor(2)), :) = 255;
        i = i + 1;
    end
    
    
    % Draw vertical lines
    %lenVerLocs = max(size(locsVer));
    %27/8/22
    lenVerLocs = size(locsVer,2);

    while j <= lenVerLocs
        imgGrid((1 : locsVer(2)), (locsVer(1, j): locsVer(1, j)), :) = 255;
        j = j + 1;
    end

end
