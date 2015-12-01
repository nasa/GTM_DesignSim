function [SimOut] = CreateSimOut(logsout)
% Create structure from logged bus signal that is named SimOut.  All
% signals in SimOut must be the same sample time and rate.  SimOut signal
% must be inside a block on the top level of the diagram named
% "Format_Outputs".  

% $Id: CreateSimOut.m 4852 2013-08-06 22:12:54Z cox $

% Paste the commented code below into the Model StopFcn callback:

% if SimIn.Switches.LogData
%     if exist('logsout','var')
%         clear SimOut
%         SimOut = CreatSimOut(logsout);
%     else
%         Disp('No Log Data Variable')
%     end
% end
% clear logsout

% Eugene Heim, NASA Langley Research Center
% Modified, david.e.cox NASA Langley Research Center

temp = logsout.whos('all');% Get all field names
index = find(strcmp('Timeseries',{temp(:).simulinkClass}));% Find signals
for ii = 1:length(index)
     % Remove blockname hierarchy. Cut string before first occurance of SimOut 
    tmpstr=temp(index(ii)).name;
    VariableName = tmpstr([min(strfind(tmpstr,'SimOut')):end]);
    % Grab TimeSeries data, remove singletons and make time vector first dimension, if necessary
    eval(sprintf('data = squeeze(logsout.%s.Data);', temp(index(ii)).name));
    eval(sprintf('timelen = length(logsout.%s.Time);',temp(index(ii)).name))
    if ndims(data) > 2 && timelen>1 % for N-D matrices time is last dim, unless time is singleton.
        eval([VariableName, ' = permute(data,[ndims(data),[1:ndims(data)-1]]);'])
    else
        eval([VariableName,' = data;']);
    end
 end

