function [results] = main_GridAnalysis(inputFileName, filePath, outputPath, startFrame, endFrame, offsetX, offsetY, positionBmode, position, inputMax)

% main_GridAnalysis
% This is the main grid analysis file.
%
% It reads in a defined DICOM clip, crops out the SWE region, places a grid 
% over itin each frame, takes whole squares from the grid for each frame 
% within the given frame range, calculates the required elasticity values, 
% derives the according parameters and finally gives the results out on a 
% spread sheet.
%
% Input: 
%         inputFileName - DICOM input file name
%         filePath - Path of DICOM file
%         outputPath - Path where output .xlsx file will be saved
%         startFrame - Frame from which analysis should begin
%         endFrame - Frame where analysis should end
%         offsetX - Given offset in x-direction for where grid should begin in mm
%         offsetY - Given offset in y-direction for where grid should begin in mm
% Output:
%         results - cell array containing analysis results
%         'results' is additonally saved in an excel table
%
% Used functions:
%         segmentElastogram - segments the elastogram from the entire image
%         scale - segment scale and get scale factor for pixel-mm  conversion
%         drawGrid - specify grid coordinates and draw on image
%         replaceNonEValues - 
%         SWEtoKPa_muscles100 -
%         evalMuscleImgs -
%
% Function used in: GUI export function
%
% author: Mehrin Azan, Katrin Skerl, HFU
% date: 10/02/2022

fileNameXls = [outputPath, '\', inputFileName, '_Offset_XY_', num2str(offsetX), '_', num2str(offsetY), '_Frames_', num2str(startFrame), '-', num2str(endFrame), '.xlsx';];

% Input File
inputFile = [filePath, '\', inputFileName];

% Set coordinates
img1 = dicomread(inputFile, 'frames', 1);    

% Get scale factor
scaleFactor  = CalcScaleFactor( img1, positionBmode );
scaleFactorHeight = scaleFactor;
scaleFactorWidth = scaleFactor;

% Create empty cell array, this will contain all results
results = {};
% Frame number column heading
results(2,1) = {'Frame'};

% Parameters
params = {'Anteil E-Werte', 'Mean','Median', 'Std', 'IQR', 'Max', 'N >295kPa', 'Anteil N>295kPa', '---'};
lenParams = max(size(params));

% Counter for first row of boxes
iterColTit = 1;

% Counter for excel output
n = 1;

% Loop through all frames, fill array with results
for m = startFrame:endFrame
    % write ID into field A    
    frameName = {[inputFileName, '_', num2str(m)]};
    results((n+2),1) = frameName;    
    % Read in image
    img = dicomread(inputFile, 'frames', m);
    % Get US image
    croppedBmodeIm = img(positionBmode(1):positionBmode(2), positionBmode(3):positionBmode(4), :);
    % get elastogram
    SWEImg = croppedBmodeIm(position(1):position(2), position(3):position(4), :);
    % Get coordinates for grid
    [~, locsHor, locsVer] = drawGrid(SWEImg, scaleFactorHeight, scaleFactorWidth, offsetX, offsetY);
    % Number of vertical and horizontal lines
    lenVer = max(size(locsVer));
    lenHor = max(size(locsHor));
    % Calculate for all columns
    colBox = 1;
    % Loop through ALL boxes and calculate
    while colBox < lenHor
        rowBox = 1;
        % Calculate entire row of boxes
        while rowBox < lenVer
            % For naming headings, only during first iteration of frame
            if m == startFrame
            % Give letter to column
                switch colBox
                    case 1
                        boxLetter = 'A';
                    case 2
                        boxLetter = 'B';
                    case 3
                        boxLetter = 'C';
                    case 4
                        boxLetter = 'D';
                    case 5
                        boxLetter = 'E';
                    case 6
                        boxLetter = 'F';
                end
                boxName = {[boxLetter, num2str(rowBox)]};
                if boxLetter == 'A' && rowBox == 1
                    results(1, 2) = boxName; % name of square
                    % Parameters
                    results(2,2:(lenParams+1)) = params;
                else                        
                    endParams = colTitStart(iterColTit);
                    results(1, (endParams+1)) = boxName; % name of square
                    % Parameters
                    results(2, (1+endParams:endParams+lenParams)) = params;
                end
                % Find start of each new column
                resTitRow = results(2,:);
                colTitStart = find(contains(resTitRow, '---'));
            else
                resTitRow = results(2,:);
                colTitStart = find(contains(resTitRow, '---'));
            end
            % Define grid square
            SWEImgBlock = SWEImg((locsHor(1, colBox):(locsHor(1, colBox+1)-1)), ((locsVer(1, rowBox)):(locsVer(1, rowBox+1)-1)), :);
            % Calculate
            % get elasticity values 
            % As also grey values from the underlaying B-mode image are
            % transformed, a function is needed to turn them to 0,0,0.
            SWEImgBlock = replaceNonEValues(SWEImgBlock);
            % transform image into matrix containing elasticity values
            EMatrix = SWEtoKPa_muscles(SWEImgBlock);%change to SWEtoKPa_muscles100 if 100% opacity is chosen
            % convert colour scale to set maximum value
            EMatrix300 = (inputMax / 300)*EMatrix;
            Data = evalMuscleImgs(EMatrix300);
            Data = num2cell(Data);
            % Write into results cell array
            % First iteration for A
            if rowBox == 1 && boxLetter == 'A'
                % Parameters
                results(n+2,2:(lenParams)) = Data;
            else
                % Data
                endParams = find(~cellfun('isempty',results(n+2,:)), 1, 'last');
                if endParams == 1
                    results(n+2, (1+endParams:endParams+numel(Data))) = Data;
                else
                    endParams = colTitStart(iterColTit);
                    results(n+2, (1+endParams:endParams+numel(Data))) = Data;
                    iterColTit = iterColTit + 1;
                end
             end
            rowBox = rowBox + 1;
        end
        colBox = colBox + 1;
    end
    if iterColTit == max(size(colTitStart))
        iterColTit = 1;
    end
    n = n+1;
end

% Remove '---' from column headings
for iCol = 1:max(size(colTitStart))
    results(2, colTitStart(iCol)) = {''};
end

% Export to excel file
writecell(results,fileNameXls,'Sheet',1);
end
