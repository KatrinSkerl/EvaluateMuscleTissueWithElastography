function [ EMatrix, SWEImg2 ] = SWEtoKPa_muscles( SWEImg )
%Transforms the colour map to elasticity values in kPa.
%
%This algorithm uses the colour map which I found out in previous work [1]. 
%It is only suitable for an opacity of 50% of the SWE image
%at the device and only for the standard setting with an elasticity range
%from 0-180 kPa, red being the stiffest.
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
% author Katrin Skerl, University of Dundee, HFU
% 11 December 2013, updated on 23 October 2020

[ncoloum, nrow, ~] = size(SWEImg);
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
%transform 50% opacity to 0%
SWEImg2 = 2*SWEImg2;
%transfer SWE to kPa
for c = 1:ncoloum
   for r = 1:nrow
      if SWEImg2(c,r,1)<10 %at least <47.5kPa %<90
          if SWEImg2(c,r,2)<10 %<22.5 kPa
              colour = double(SWEImg2(c,r,3));
              EMatrix(c,r) = double(colour/255*22.5);
          else %22.5<x<90kPa
              if SWEImg2(c,r,3)>250 %22.5<x<67.5 kPa
                  colour = double(SWEImg2(c,r,2));
                  EMatrix(c,r) = double(colour/255*45 + 22.5);
              else %67.5<x<90 kPa
                  %colour1 = double(SWEImg2(c,r,2));
                  colour = double(SWEImg2(c,r,3));
                  %colour = colour1-colour2;
                  EMatrix(c,r) = double((1-colour/255)*22.5 + 67.5);
              end
          end
      else
          if SWEImg2(c,r,2)>10 %22.5<%90<x<157.5 kPa
              if SWEImg2(c,r,1)<SWEImg2(c,r,2)%250 %90<x<112.5 kPa
                  colour = double(SWEImg2(c,r,1));
                  EMatrix(c,r) = double(colour/255*22.5 + 90);
%                   EMatrix(c,r) = double(colour/255*45 + 67.5);
              else %112.5<x<157.5
                  colour = double(SWEImg2(c,r,2));
                  EMatrix(c,r) = double((1-colour/255)*45 + 112.5);
              end              
          else %>157.5 kPa or blue-violet
              if SWEImg2(c,r,1) > SWEImg2(c,r,3)
                  colour = double(SWEImg2(c,r,1));
                  EMatrix(c,r) = double((1-colour/255)*45 + 157.5);
                  %23/10/2020
                  %adjustment to cut-off values above 180 kPa
                  if EMatrix(c,r) >= 180
                      EMatrix(c,r) = 180;
                  end
              else %<22.5 kPa - blue-violet
                  colour = double(SWEImg2(c,r,3));
                  EMatrix(c,r) = double(colour/255*22.5);
              end
          end
      end
   end
end

end

