function MWS = grabmws(model);
%function MWS = grabmws(model);
%
% Grabs current model workspace and returns as
% fields in a strucure
% 
% Inputs:
%    model  - name of model, defaults to 'gtm_design'
% 
% Outputs:
%    MWS    - simlation parameters from the model workspace
% 

% d.e.cox@larc.nasa.gov
% $Id: grabmws.m 4852 2013-08-06 22:12:54Z cox $

% By default use the bdroot model
if ( ~exist('model','var') || isempty(model) ),
  model=bdroot;
end

mws=get_param(model,'modelworkspace');
mws_vars=mws.whos;
for i=[1:length(mws_vars)],
  MWS.(mws_vars(i).name)=mws.evalin(mws_vars(i).name);
end


