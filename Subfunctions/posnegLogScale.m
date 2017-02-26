function [ output_args ] = posnegLogScale( hax, symAx )
%SYMMETRICLOGSCALE Create a symmetric logarithmic axis for the supplied
%axis object, along the directions specified in symAx

%% Determine which axes to symmetrize
symmetric = zeros(3,1); %array indiciating which axes (x,y,z) to symmetrize
symmetricString = {'x';'y';'z'};
for i = 1:numel(symAx)
    symmetric(strcmp(symmetricString,symAx{i}))=1;
end

%% Load data from figure
h = hax.Children;

%% Log Scale Data
for i = 1:numel(h)
    logScale(h(i),symmetric)
end

end


%% Subfunction
function logScale(h,flag)
% for each input line handle, log scale the desired data

for i = 1:numel(flag)
    %% Get initial data
    switch flag(i)
        case 1
            
            switch i
                case 1
                    dat = h.XData;
                case 2
                    dat = h.YData;
                case 3
                    dat = h.ZData;
            end
            
            
            %% Logarithmically scale the desired axis
            
            % Initialize data
            datNeg = zeros(size(dat));
            datPos = datNeg;
            
            % Seperate into positive and negative data
            datNeg(dat<0) = dat(dat<0);
            datPos(dat>=0) = dat(dat>=0);
            
            % Log scale
            datNegLog = -log10(-datNeg);
            datPosLog = log10(datPos);
            
            % Correct for infinities
            datNegLog(isinf(datNegLog))=0;
            datPosLog(isinf(datPosLog))=0;
            
            datLog = datNegLog + datPosLog;
            
            %% Update plot data and legend
            hax = gca;
            switch i
                case 1
                    h.XData = datLog;
                    hax.XTickLabel = logLabels(hax.XTick);      

                case 2
                    h.YData = datLog;                    
                    hax.YTickLabel = logLabels(hax.YTick);      
                case 3
                    h.ZData = datLog;                                       
                    hax.ZTickLabel = logLabels(hax.ZTick);                                       
            end
            
        case 0
            
            
    end
end

end


function newLabel = logLabels(ticks)

%Sign of tick labels
signTicks = sign(ticks');

newLabel = cell(1,numel(ticks));

for j = 1:numel(ticks)
    S = num2str(signTicks(j));
    S = strrep(S,'1','');
    S = strrep(S,'0','');
    newLabel{j} = [S,'10^{',num2str(abs(ticks(j))),'}'];
    if ticks(j) ==0
        newLabel{j} = '0';
    end
end

end
