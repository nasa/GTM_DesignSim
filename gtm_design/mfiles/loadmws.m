function loadmws(MWS,model);
%function loadmws(MWS,model);
%
% Clears model workspace and replaces with variables 
% given by the fields of the structure MWS
%
% Inputs:
%  MWS   - Model Workspace Structure, contains simulation parameters
%  model - Name of model to load into, default is 'gtm_design'
%

% d.e.cox@larc.nasa.gov
% $Id: loadmws.m 4852 2013-08-06 22:12:54Z cox $

% By default use the bdroot model
if ( ~exist('model','var') || isempty(model) ),
  model=bdroot;
end

mws=get_param(model,'modelworkspace');

if ( ~exist('MWS') || isempty(MWS) ),
  mws.clear;
  return
else
  mws.clear;
  fn=fieldnames(MWS);
  for i=[1:length(fn)],
    mws.assignin(fn{i},MWS.(fn{i}));
  end
end




  
