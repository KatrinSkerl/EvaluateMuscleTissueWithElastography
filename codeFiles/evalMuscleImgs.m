function Data = evalMuscleImgs(EMatrix300)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


  % evaluate images 
   idxN0 = find(EMatrix300);
    nRelevant = size(idxN0);
    ENon0 = EMatrix300(idxN0);
    nCut = size(find(ENon0>295));
    nTotal = size(EMatrix300,1)*size(EMatrix300,2);
    rateSWE = nRelevant/nTotal*100;
    rateCut = nCut/nRelevant *100;
%    meanSWE = sum(sum(EMatrix300))/nRelevant;
%    medianSWE = median(EMatrix300, 'all');
%    %std without 0 elements
%    %create a mask that is 1 for all nonzero values
%    mask = imbinarize(EMatrix300,1);
%    EMatrixStd = mask * (EMatrix300 - meanSWE);
%    stdSWE = sum(EMatrixStd.^2,'all')/nRelevant;
    Data = [rateSWE(1), mean(ENon0), median(ENon0), std(ENon0), iqr(ENon0), max(ENon0), nCut(1), rateCut];
end

