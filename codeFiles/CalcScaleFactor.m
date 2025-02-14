function [ scaleFactor ] = CalcScaleFactor( img, BmodeStart )
% Calculates a scaling factor to convert pixel into depth [cm]
% 
% To calculate the scaleFactor, the scale on top of the upper B-mode image
% is evaluated. The first 3 markings are detected. As it's known that they
% have a distance of 10 mm, 'the scaleFactor' is calculated of the distance
% of the pixels.
%
% input arguments: img - entire anonymised image
%                  BmodeStart - position of start of B-mode image
% output arguments: scaleFactor
%
% author Katrin Skerl, University Dundee
% 6/8/13

%extract area with scale of image
startC = BmodeStart(1);
startR = BmodeStart(2);
scale = img(134:140, startR:end,:);
scaleVector = scale(6,:,1); 

thresScale = 100;
%find 3 points on scale which have a distance of 1 cm
StartScale = find(scaleVector>thresScale,1,'first');
MiddleScale = StartScale+find(scaleVector(StartScale+1:end)>thresScale,1,'first');
EndScale = MiddleScale+find(scaleVector(MiddleScale+1:end)>thresScale,1,'first');

%calculates distance in pixel
scaleDepth = EndScale - StartScale; 
scaleFactor = 1/scaleDepth;
end

