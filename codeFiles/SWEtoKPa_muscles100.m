function [ EMatrix, SWEImg2 ] = SWEtoKPa_muscles100( SWEImg )
%Transforms the colour map to elasticity values in kPa if opacity is set 
% to 100.
%
%This algorithm uses the colour map which I found out in previous work [1]. 
%It is only suitable for an opacity of 100% of the SWE image
%at the device and only for the standard setting with an elasticity range
%from 0-300 kPa, red being the stiffest.
% 
% [1] Skerl, K., Cochran, S., & Evans, A. (2017). First step to facilitate 
% long-term and multi-centre studies of shear wave elastography in solid 
% breast lesions using a computer-assisted algorithm. International Journal
% of Computer Assisted Radiology and Surgery, 12, 1533-1542.
%
% input argument: SWEImg - SWE image
% output argument: EMatrix - elasticity matrix [kPa]
%
% used functions:
%
% author Katrin Skerl, HFU
% 09 November 2020

[ncoloum, nrow] = size(SWEImg);
SWEImg = double(SWEImg);
SWEImg2 = SWEImg;
%exclude underlaying B-mode image
for c = 1:ncoloum
   for r = 1:nrow
      minValue = min(SWEImg(c,r,:));
      for ind = 1:3
         SWEImg2(c,r,ind) = SWEImg(c,r,ind)-minValue; 
      end
   end
end
noRed = SWEImg(:,:,1) < 10;
noGreen = SWEImg(:,:,2) < 10;
fullRed = SWEImg(:,:,1)>=SWEImg(:,:,2) & SWEImg(:,:,1)>SWEImg(:,:,3);%  >= 250; 
fullGreen = SWEImg(:,:,2)>SWEImg(:,:,1) & SWEImg(:,:,2)>SWEImg(:,:,3); %>= 250;
fullBlue = SWEImg(:,:,3)>=SWEImg(:,:,2) & SWEImg(:,:,3)>SWEImg(:,:,1); %>= 250;
%section1: E <37.5 kPa
section1 = SWEImg(:,:,3).*double(noRed).*double(noGreen);
EMatrix = double(section1 .* (37.5 / 255));
%section2: 37.5 < E < 112.5 kPa
section2 = SWEImg(:,:,2) .*double(fullBlue);
EM2 = double((section2 .* (75 / 255))+37.5);
EM2 = EM2 .*double(fullBlue); %.* double(noRed);
EMatrix = EMatrix + EM2;
%section3: 112.5<E<187.5
section3 = SWEImg(:,:,1).*double(fullGreen);
EM3 = (double(section3 .* (75 / 255)) + 112.5);
EM3 = EM3 .*double(fullGreen);
EMatrix = EMatrix + EM3;
%section4: 187.5<E<262.5
section4 = SWEImg(:,:,2) .* double(fullRed);
EM4 = (double(75 - (section4 .* (75 / 255))) + 187.5);
EM4 = EM4 .* double(fullRed);
EMatrix = EMatrix + EM4;
darkRed = EMatrix > 260 & SWEImg(:,:,2) < 20 & SWEImg(:,:,3) < 20;
section5 = SWEImg(:,:,1) .* double(darkRed);
EM5 = (double(75 - (section5 .* (75 / 255)))).* double(darkRed);
EMatrix = EMatrix + EM5;
EMatrix(EMatrix>300) = 300;

end

