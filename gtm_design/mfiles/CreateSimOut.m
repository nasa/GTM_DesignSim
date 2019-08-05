function [SimOut] = CreateSimOut(logsout)
% Create structure from logged bus signal that is named SimOut.  All
% signals in SimOut must be the same sample time and rate.  SimOut signal
% must be inside a block on the top level of the diagram named
% "Format_Outputs".  

% $Id: CreateSimOut.m 2 2015-05-07 21:03:59Z cox $

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


if (isa(logsout,'Simulink.ModelDataLogs')==1),   % Old ModelDataLogs format for logsout
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
elseif (isa(logsout,'Simulink.SimulationData.Dataset')==1),  % New Dataset format for logsout
  tmp=logsout.getElement(1);  %Should only be one.
  SimOut_TS=tmp.Values;       %Already a data struct
  SimOut=ts2vec(SimOut_TS);   %Convert timeseries to simple vector/matrix, recursive function
end


function sout = ts2vec(sin);
%function sout = ts2vec(sin);

sout=sin;
fn=fieldnames(sin);
for i=1:length(fn),
    if (isa(sin.(fn{i}),'timeseries')==1),
        tstmp=sin.(fn{i});
        sout.(fn{i})=tstmp.Data;
    elseif (isa(sin.(fn{i}),'struct')==1),
        sout.(fn{i})=ts2vec(sin.(fn{i})); % Recursive voodoo...
    else
        fprintf(1,'WARNING: Action for class %s at field %s  is undefined, ignoring\n',class(sin.(fn{i})),fn{i});
    end
end
