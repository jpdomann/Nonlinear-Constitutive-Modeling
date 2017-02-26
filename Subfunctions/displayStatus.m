function [ output_args ] = displayStatus( t, nPoints, idx )
%DISPLAYSTATUS Summary of this function goes here
%   Detailed explanation goes here

t = t(t~=0);

%Average loop time
avgt = mean(t(t~=0));

%Remaning points
pointsLeft = nPoints - idx;

%Estimated remaining time 
tRemaining = pointsLeft*avgt;%seconds

days = tRemaining/(60*60*24);
hours = (days-floor(days))*24;
minutes = (hours - floor(hours))*60;
seconds  = (minutes-floor(minutes))*60;

format = '%02i';
str = ['Remaining: ',num2str(pointsLeft),...
    ' - Elapsed Time (sec): ',num2str(t(end),'%10.2f'),...
    ' - Time Remaining:',[...
    num2str(floor(days),format),':',...
    num2str(floor(hours),format),':',...
    num2str(floor(minutes),format),':',...
    num2str(floor(seconds),format)]];
disp(str)

end

