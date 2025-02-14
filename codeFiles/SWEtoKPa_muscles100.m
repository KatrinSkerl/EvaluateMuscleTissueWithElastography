function [ EMatrix, SWEImg2 ] = SWEtoKPa_muscles100( SWEImg )
%Transforms the colour map to elasticity values in kPa.
%
%Update: 9/11/2020 
%This algorithm is adjusted to fit for an opacity of 100% with maximum of E
%= 300 kPa.
%
%This algorithm uses the colour map which I found out (paper
%'savingModes'). It is only suitable for an opacity of 50% of the SWE image
%at the device and only for the standard setting with an elasticity range
%from 0-180 kPa, red being the stiffest.
%
% input argument: SWEImg - SWE image
% output argument: EMatrix - elasticity matrix [kPa]
%
% used functions:
%
% author Katrin Skerl, HFU
% 09 November 2020

[ncoloum, nrow, rgb] = size(SWEImg);
SWEImg = double(SWEImg);
SWEImg2 = SWEImg;
EMatrix = zeros(ncoloum, nrow);
%exclude underlaying B-mode image
for c = 1:ncoloum
   for r = 1:nrow
      minValue = min(SWEImg(c,r,:));
      for ind = 1:3
         SWEImg2(c,r,ind) = SWEImg(c,r,ind)-minValue; 
      end
   end
end
%9/11/2020
% greyPixels = SWEImg(:,:,1)
% SWEImg((SWEImg(:,:,1)~=0) & (SWEImg(:,:,2)~=0) & (SWEImg(:,:,3)~=0))
%funktioniert so nicht

% %transform 50% opacity to 0%
% SWEImg2 = 2*SWEImg2;
%transfer SWE to kPa
%section1 = find((SWEImg(:,:,1)=0) & (SWEImg(:,:,2)=0) & (SWEImg(:,:,3)~=0));
noRed = SWEImg(:,:,1) < 10;
noGreen = SWEImg(:,:,2) < 10;
noBlue = SWEImg(:,:,3) < 10;
fullRed = SWEImg(:,:,1)>=SWEImg(:,:,2) & SWEImg(:,:,1)>SWEImg(:,:,3);%  >= 250; %== 255;
fullGreen = SWEImg(:,:,2)>SWEImg(:,:,1) & SWEImg(:,:,2)>SWEImg(:,:,3); %>= 250;
fullBlue = SWEImg(:,:,3)>=SWEImg(:,:,2) & SWEImg(:,:,3)>SWEImg(:,:,1); %>= 250;
%section1: E <37.5 kPa
section1 = SWEImg(:,:,3).*double(noRed).*double(noGreen);
EMatrix = double(section1 .* (37.5 / 255));
%section2: 37.5 < E < 112.5 kPa
section2 = SWEImg(:,:,2) .*double(fullBlue);% .* uint8(noRed);
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
%section5: E>262.5
% section5 = SWEImg(:,:,1).*uint8(noGreen) .* uint8(noBlue); %hier ist der Bug
% EM5 = (double(section5 .* (75 / 255)) + 262.5);
% EM5 = EM5 .*double(noGreen) .* double(noBlue);
darkRed = EMatrix > 260 & SWEImg(:,:,2) < 20 & SWEImg(:,:,3) < 20;
section5 = SWEImg(:,:,1) .* double(darkRed);
EM5 = (double(75 - (section5 .* (75 / 255)))).* double(darkRed);
EMatrix = EMatrix + EM5;
%Notiz: hier ist ein Bug durch das aufsummieren. Vermutlich muss ich es
%erst in Teilmatritzen unterteilen und dann zusammenfuegen



% for c = 1:ncoloum
%    for r = 1:nrow
%       if SWEImg2(c,r,1)<10 %at least <47.5kPa %<90
%           if SWEImg2(c,r,2)<10 %<22.5 kPa
%               colour = double(SWEImg2(c,r,3));
%               EMatrix(c,r) = double(colour/255*22.5);
%           else %22.5<x<90kPa
%               if SWEImg2(c,r,3)>250 %22.5<x<67.5 kPa
%                   colour = double(SWEImg2(c,r,2));
%                   EMatrix(c,r) = double(colour/255*45 + 22.5);
%               else %67.5<x<90 kPa
%                   %colour1 = double(SWEImg2(c,r,2));
%                   colour = double(SWEImg2(c,r,3));
%                   %colour = colour1-colour2;
%                   EMatrix(c,r) = double((1-colour/255)*22.5 + 67.5);
%               end
%           end
%       else
%           if SWEImg2(c,r,2)>10 %22.5<%90<x<157.5 kPa
%               if SWEImg2(c,r,1)<SWEImg2(c,r,2)%250 %90<x<112.5 kPa
%                   colour = double(SWEImg2(c,r,1));
%                   EMatrix(c,r) = double(colour/255*22.5 + 90);
% %                   EMatrix(c,r) = double(colour/255*45 + 67.5);
%               else %112.5<x<157.5
%                   colour = double(SWEImg2(c,r,2));
%                   EMatrix(c,r) = double((1-colour/255)*45 + 112.5);
%               end              
%           else %>157.5 kPa
%               colour = double(SWEImg2(c,r,1));
%               EMatrix(c,r) = double((1-colour/255)*45 + 157.5);
%               %23/10/2020
%               %adjustment to cut-off values above 180 kPa
%               if EMatrix(c,r) >= 180
%                   EMatrix(c,r) = 180;
%               end
%           end
%       end
%    end
% end

end

