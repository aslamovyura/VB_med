function [locs, toneFlag] = toneValidity(signal, t, config, locs)

%This function checks tones for validity, i.e. checks all tones to be
%similar "position" (if everywhere S1 and some where S2, S2 would be
%unvalid) and changes unvalid tones to nearest valid tones (S2 would be
%changed to S1);

%Chec is by looking 2 nearest peaks, from the left side from current peak
%and from the right side, after that calculates distances between current
%peak and 2 nearest peaks, and if left peak closer, it means that current
%peak is S2, otherwise - S1

% Developer : A. Bourak
% Date :      05/08/2017
% Modified:   A. Bourak 11/08/2017

%finding all peaks (S1 and S2)
[~, fullLocs] = findpeaks(signal, t, 'minPeakDistance', 0.2, 'minPeakHeight', 0.05);
fullLocs = fullLocs';

for i = 1:length(locs)
    for j = 1:length(fullLocs)
        if locs(i) == fullLocs(j)

            if j == 1
                if(fullLocs(j+1)-fullLocs(j)) > (fullLocs(j+2)-fullLocs(j+1))
                    toneFlag(i) = 2;
                    break;
                elseif (fullLocs(j+1)-fullLocs(j)) < (fullLocs(j+2)-fullLocs(j+1))
                    toneFlag(i) = 1;
                    break;
                else 
                    toneFlag(i) = 0;
                    break;
                end
            elseif j == length(fullLocs)
                 if(fullLocs(j)-fullLocs(j-1)) < (fullLocs(j-1)-fullLocs(j-2))
                    toneFlag(i) = 2;
                    break;
                elseif (fullLocs(j)-fullLocs(j-1)) > (fullLocs(j-1)-fullLocs(j-2))
                    toneFlag(i) = 1;
                    break;
                else 
                    toneFlag(i) = 0;
                    break;
                end
            else
                if (fullLocs(j) - fullLocs(j-1)) > (fullLocs(j+1)-fullLocs(j))
                    toneFlag(i) = 1;
                    break;
                elseif (fullLocs(j) - fullLocs(j-1)) < (fullLocs(j+1)-fullLocs(j))
                    toneFlag(i) = 2;
                    break;
                else 
                    toneFlag(i) = 0;
                    break;
                end
            end
        else 
%             locsTemp(j) = 0;
            toneFlag(i) = 0;
        end
    end
end

numOfTones1 = 0;
numOfTones2 = 0;
numOfTones0 = 0;
for i = 1:length(toneFlag)
    if toneFlag(i) == 1
        numOfTones1 = numOfTones1 + 1;
    elseif toneFlag(i) == 2
        numOfTones2 = numOfTones2 + 1;
    else
        numOfTones0 = numOfTones0 + 1; 
    end
end
if numOfTones1 > numOfTones2 
    for i = 1:length(toneFlag)
        if toneFlag(i) == 2
            for j = 1:length(fullLocs)
                if locs(i) == fullLocs(j)
                    locs(i) = fullLocs(j-1);
                    break;
                end
            end
        end
    end
elseif numOfTones1 < numOfTones2
    for i = 1:length(toneFlag)
        if toneFlag(i) == 1
            for j = 1:length(fullLocs)
                if locs(i) == fullLocs(j)
                    locs(i) = fullLocs(j+1);
                    break;
                end
            end
        end
    end
else
    disp('ERROR!');
end
end