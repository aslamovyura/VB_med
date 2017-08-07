function [locs, toneFlag] = toneValidity(signal, t, config, locs)

[~, fullLocs] = findpeaks(signal, t, 'minPeakDistance', 0.2, 'minPeakHeight', 0.05);
fullLocs = fullLocs';
% locsTemp = zeros(length(fullLocs));
for i = 1:length(locs)
    for j = 1:length(fullLocs)
        if locs(i) == fullLocs(j)
%             locsTemp(j) = locs(i);
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