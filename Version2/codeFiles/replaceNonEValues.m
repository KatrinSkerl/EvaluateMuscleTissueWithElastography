function [ SWEImg ] = replaceNonEValues( SWEImg )
% replaceNonEValues detects areas in SWE image that do not contain any
% elasticity values (grey through B-mode image) and sets them to 0 (black)
%
% As also grey values from underlaying B-mode image are transformed
% to elasticity values, a function is needed, which
% detects the grey areas and turn them to 0,0,0. This also eases the 
% further image processing.
% If the image is colour coded, one number of arrays seems to be always 
% >100. Therefore the first ablation of each pixel is calculated and if it 
% is <50 it's set to 0. In grey are all values in similar range.
%
% input arguments: SWEImg - SWE image
% output arguments: SWEImg - SWE image without grey parts
%
% used functions:
%
% author Katrin Skerl, University Dundee
% 5/8/13

Size = size(SWEImg);
nRows = round(Size(2));
nColoums = round(Size(1));
for r = 1:nRows
    for c = 1:nColoums
        v = zeros(1,3);
        for index = 1:3
            v(index) = SWEImg(c, r, index); 
        end
       diffVector = abs(diff(v));
       Max = max(diffVector);
       if Max < 50
           %if max(v)<100
                SWEImg(c, r, :) = 0; 
           %end
       end
    end
end 
 
end

