function appendmws(MWS,model)
%function appendmws(MWS,model)
%
% Appends model workspace with variables 
% given by the fields of the structure MWS.  
%
% ! Warning !  Will overwrite indentically named variables without warning!
%
% Inputs:
%  MWS   - Model Workspace Structure, contains simulation parameters
%  model - Name of model to load into, default is 'gtm_design'
%

% $Id: appendmws.m 4852 2013-08-06 22:12:54Z cox $
% Author: Austin Murch (Austin.M.Murch@nasa.gov)
% Adpated from code by Dave Cox (d.e.cox@larc.nasa.gov)


% By default use the bdroot model
if ( ~exist('model','var') || isempty(model) ),
  model=bdroot;
end

mws=get_param(model,'modelworkspace');

fn=fieldnames(MWS);
for i=1:length(fn)
    mws.assignin(fn{i},MWS.(fn{i}));
end





  
