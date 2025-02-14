function [results] = main_ROIAnalysis(inputFileName, filePath, outputPath, startFrame, endFrame, roiLocs, positionBmode, position, inputMax)

% main_ROIAnalysis
% This is the main ROI analysis file.
%
% It reads in a defined DICOM clip, takes the defined ROI for each frame 
% within the given frame range, calculates the required elasticity 
% values, derives the according parameters and finally gives the results 
% out on a spread sheet.
%
% Input: 
%         inputFileName - DICOM input file name
%         filePath - Path of DICOM file
%         outputPath - Path where output .xlsx file will be saved
%         startFrame - Frame from which analysis should begin
%         endFrame - Frame where analysis should end
%         roiLocs - Coordinates of selected region (firstRow:lastRow,
%                   firstColumn:lastColumn) --> if roiLocs == 1, analyse
%                   entire SWE region!
% Output:
%         results - cell array containing analysis results
%         'results' is additionally saved in an excel table
%
% Used functions:
%         segmentElastogram - segments the Elastogram from the entire image
%         replaceNonEValues - 
%         SWEtoKPa_muscles100 -
%         evalMuscleImgs -
%
% Function used in: GUI export function
%
% author: Mehrin Azan, Katrin Skerl, HFU
% date: 10/02/2022


fileNameXls = [outputPath, '\', inputFileName, '_ROI_Frames_', num2str(startFrame), '-', num2str(endFrame), '.xlsx';];
% Input File
inputFile = [filePath, '\', inputFileName];
% Find coordinates
img1 = dicomread(inputFile, 'frames', 1);
% [positionBmode, ~ , position, SWEImg] = segmentElastogram(img1);
BmodeImg = img1(positionBmode(1):positionBmode(2),positionBmode(3):positionBmode(4),:);
SWEImg = BmodeImg(position(1):position(2), position(3):position(4),:);

[rowImg, colImg, ~] = size(SWEImg);

% roiLocs = 1 if entire SWE image is to be analysed
if roiLocs == 1
    roiLocs = [1, rowImg, 1, colImg];
end

% Create empty cell array, this will contain all results
results = {};

% Parameters
params = {'Frame', 'Anteil E-Werte', 'Mean','Median', 'Std', 'IQR', 'Max', 'N >295kPa', 'Anteil N>295kPa'};
lenParams = max(size(params));
results(1:lenParams) = params;

% Counter for excel output
m = 1;

% Loop through all frames, fill array with results
for n = startFrame:endFrame
    % write ID into field A    
    frameName = {[inputFileName, '_', num2str(n)]};
    results((m+1),1) = frameName;
    % Read in image
    img = dicomread(inputFile, 'frames', n);
    % Get US image
    croppedBmodeIm = img(positionBmode(1):positionBmode(2), positionBmode(3):positionBmode(4), :);
    % get elastogram
    SWEImg = croppedBmodeIm(position(1):position(2), position(3):position(4), :);
    % Get ROI
    imShapeSelected = SWEImg(roiLocs(1):roiLocs(2), roiLocs(3):roiLocs(4), :);
    % Calculate
    % get elasticity values 
    % As also grey values from the underlaying B-mode image are
    % transformed, a function is needed to turn them to 0,0,0.
    SWEImgBlock = replaceNonEValues(imShapeSelected);    
    % transform image into matrix containing elasticity values
    EMatrix = SWEtoKPa_muscles100(SWEImgBlock);
    % convert colour scale to set maximum value, due to later use convert
    % to basis of 300 kPa (current possible max value for muscle tissue)
    EMatrix300 = (inputMax / 300)*EMatrix; 
    Data = evalMuscleImgs(EMatrix300);
    Data = num2cell(Data);
    % Add to results matrix
    results((m+1), (2:lenParams)) = Data;
    m = m+1;
end

% Export to excel file
writecell(results,fileNameXls,'Sheet',1);
end