function Data = evalMuscleImgs(EMatrix300)
% This is the function that evalutes the SWE image and returns the
% statistical parameters as a data array.
% 
% ! Although the input matrix and the values here are referring to 300 kPa
% the maximum value is adjustable in the GUI and the values are adjusted
% directly in the main program. The adjustement of the maximum value was 
% added later on in the project and we didn't want to change too much.!
% Never disturb a running system. :)
%
% It calculates: 
%         rateSWE(1) - the number of pixels with elasticity values
%         mean(ENon0) - the mean of all elasticity values, excluding 0s
%         median(ENon0) - the median of all elasticity values, excluding 0s
%         std(ENon0) - the standard deviation of all elasticity values, 
%                      excluding 0s
%         iqr(ENon0) - the interquartile range
%         max(ENon0) - the maximum value
%         nCut(1) - the number of pixels larger than 295 kPa, or actually
%                   larger than 295/300 of the chosen maximum value
%         rateCut - the rate of pixels larger than 295 kPa
%
% Input: 
%         EMatrix300 - elasticity matrix with 300 kPa as maximum
%
% Output:
%         Data - array of calculated parameters
%
% Used functions:
%         
% %
% author: Mehrin Azan, Katrin Skerl, HFU
% date: 10/02/2022

% evaluate images 
idxN0 = find(EMatrix300);
nRelevant = size(idxN0);
ENon0 = EMatrix300(idxN0);
nCut = size(find(ENon0>295));
nTotal = size(EMatrix300,1)*size(EMatrix300,2);
rateSWE = nRelevant/nTotal*100;
rateCut = nCut/nRelevant *100;
Data = [rateSWE(1), mean(ENon0), median(ENon0), std(ENon0), iqr(ENon0), max(ENon0), nCut(1), rateCut];
end

