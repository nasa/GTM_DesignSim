function [sys,londyn,latdyn] = linmodel(MWS,vabflag,use_all_inputs,Ts)
%function [sys,londyn,latdyn] = linmodel(MWS,vabflag,use_all_inputs,Ts)
%
% Linearize gtm_design simulation at the current trim point.  The
% linear model is continuous by default, discrete if the 'Ts' argument
% is non-zero.
%
% Inputs:
%   MWS    - simulation parameters, defaults to pre-loaded model workspace
%   vabflag - flag to get linear models in terms of V, alpha, beta (0 default)
%   use_all_inputs -for using full set of inputs rather than groups (0 default)
%   Ts      - Timestep for generating a discrete linear model (0 default)
%
% Outputs:
%   sys    - 6dof system with control surface inputs/state outputs
%   londyn - Approximate (4th order) longitudinal dynamics
%   latdyn - Approximate (4th order) lateral dynamics
%

% d.e.cox@larc.nasa.gov
% $Id: linmodel.m 4852 2013-08-06 22:12:54Z cox $

%% Parse Input Arguments
% Load new model workspace if supplied
if (exist('MWS','var') && ~isempty(MWS))
    if isstruct(MWS)
        loadmws(MWS,'gtm_design');
    else
        error('MWS input must be a data structure')
    end
end

% Set optional flags
if ~exist('vabflag','var') || isempty(vabflag),
    vabflag = 0;
end

if ~exist('use_all_inputs','var') || isempty(use_all_inputs)
    use_all_inputs = 0;
end

Args = [];
if ~exist('Ts','var') || isempty(Ts) || Ts <= 0
    Ts   = 0;
    Args = 'IgnoreDiscreteStates';
end

%% Initializations and sim setup
% Set Inline Params to off.
% If not "off", trim results degrade (why??)
dirtyflag =get_param('gtm_design','Dirty');
inlineflag=get_param('gtm_design','InlineParams');
set_param('gtm_design','InlineParams','off');

% Grab state names
[tmp1,tmp2,Statename]=gtm_design;

% Get index for Equations of Motion states
EOM =find(strcmp(Statename,['gtm_design/GTM_T2/EOM/Integrator'])==1);

% Set LinearizationFlag
appendmws(struct('LinearizeModeOn',1),'gtm_design');

%% Run sim for 0.1 seconds.
% This initializes some states that are not set by trimgtm, e.g.
% memory blocks, filter states, etc.
[t,Xtime,y]=sim('gtm_design',[0 0.1]);
Xo=Xtime(end,:);

%% Check to ensure non-accelerating set point
tol=1e-3;
delta_vel=Xtime(1,EOM(1:6))-Xtime(end,EOM(1:6));
if max(abs(delta_vel))>tol,
    fprintf(1,'\n  at t=%3.2f sec Xvel=[%5.2e %5.2e %5.2e %5.2e %5.2e %5.2e]',t(1),  Xtime(1,EOM(1:6)));
    fprintf(1,'\n  at t=%3.2f sec Xvel=[%5.2e %5.2e %5.2e %5.2e %5.2e %5.2e]\n',t(end),Xtime(end,EOM(1:6)));
    warning('Model does not appear to be at a stationary point, deltaV=%3.2f',max(abs(delta_vel)));
end

%% Extract the Linear Model using dlinmod.  For Ts > 0, the model is discrete.
warning('off','Simulink:tools:dlinmodIgnoreDiscreteStates');
[a,b,c,d]=dlinmod('gtm_design',Ts,Xo,Args);
sys=ss(a,b,c,d,Ts);
warning('on','Simulink:tools:dlinmodIgnoreDiscreteStates');

% Define states to retain, remove others
keep=EOM(1)+[0:11]';
elim=setdiff([1:length(a)]',keep);
sys=modred(sys,elim,'del');

% Remove some of the outputs that are used for trim only
% First 6 are from AUX, last 12 are from the EOM
sys=sys([2:4,7:18],:);

% Remove firsst four inputs (trim inputs)
sys=sys(:,[5:23]);

% Convert units on selected outputs
sys.c(1,:) = sys.c(1,:)*1.6878; % convert tas to feet per second
sys.c(2,:) = sys.c(2,:)*pi/180; % convert alpha to radians
sys.c(3,:) = sys.c(3,:)*pi/180; % convert beta to radians

% Set names, hardwired from ordering in block diagram

Inames={'ElevLOB','ElevLIB','ElevROB','ElevRIB',              ...%  1  2  3  4
        'AileronL',   'AileronR',                             ...%  5  6
        'RudderUpper','RudderLower',                          ...%  7  8
        'SpoilerLIB', 'SpoilerLOB', 'SpoilerRIB','SpoilerROB',...%  9 10 11 12
        'FlapsLIB',   'FlapsLOB',   'FlapsRIB',  'FlapsROB',  ...% 13 14 15 16
        'Stabilizer',                                         ...% 17
        'L Throttle', 'R Throttle'}; 		                 % 18 19

Snames={'u',   'v',     'w',    ... %  1  2  3
        'p',   'q',     'r',    ... %  4  5  6
        'Lat', 'Lon',   'Alt',  ... %  7  8  9
        'phi', 'theta', 'psi'};     % 10 11 12

Onames={'tas', 'alpha', 'beta', ... %  1  2  3
        'u',   'v',     'w',    ... %  4  5  6
        'p',   'q',     'r',    ... %  7  8  9
        'Lat', 'Lon',   'Alt',  ... % 10 11 12
        'phi', 'theta', 'psi'};     % 13 14 15

set(sys,'Statename',Snames,'Outputname',Onames,'Inputname',Inames);

% Create 4th order longitudinal/lateral models
Xlon=[1 3 5 11]; % States to keep (u,w,q,theta)
Xlat=[2 4 6 10]; % States to keep (v,p,r,phi)


if use_all_inputs

  % Keep the inputs using indices for the full set of control surface inputs
  Ilon=[1 2 3 4 9 10 11 12 18 19]; % inputs to keep: elev, spoilers, thrott
  Ilat=[5 6 7 8 9 10 11 12];       % inputs to keep: ail, rudder, spoilers

else

  % Keep the inputs using indices for a subset of control surface inputs

  % Model inputs are: elevator, aileron, rudder, LSpoiler, RSpoiler, 
  %                   Flap, Stab, LThrottle, RThrottle
  % 
  % Reduce/group the full set of control surfaces into the subsets:
  %
  sys.b(:,1) = sys.b(:,1)  + sys.b(:,2) + sys.b(:,3) + sys.b(:,4);    %1 elev
  sys.b(:,2) = sys.b(:,5)  + sys.b(:,6);                              %2 ail
  sys.b(:,3) = sys.b(:,7)  + sys.b(:,8);                              %3 rud
  sys.b(:,4) = sys.b(:,9)  + sys.b(:,10);                             %4 Lspoil
  sys.b(:,5) = sys.b(:,11) + sys.b(:,12);                             %5 Rspoil
  sys.b(:,6) = sys.b(:,13) + sys.b(:,14) + sys.b(:,15) + sys.b(:,16); %6 flap
  sys.b(:,7) = sys.b(:,17);                                           %7 stab
  sys.b(:,8) = sys.b(:,18);                                           %8 Lthrot
  sys.b(:,9) = sys.b(:,19);                                           %9 Rthrot

  sys.d(:,1) = sys.d(:,1)  + sys.d(:,2) + sys.d(:,3) + sys.d(:,4);    %1 elev  
  sys.d(:,2) = sys.d(:,5)  + sys.d(:,6);			      %2 ail   
  sys.d(:,3) = sys.d(:,7)  + sys.d(:,8);			      %3 rud   
  sys.d(:,4) = sys.d(:,9)  + sys.d(:,10);			      %4 Lspoil
  sys.d(:,5) = sys.d(:,11) + sys.d(:,12);			      %5 Rspoil
  sys.d(:,6) = sys.d(:,13) + sys.d(:,14) + sys.d(:,15) + sys.d(:,16); %6 flap  
  sys.d(:,7) = sys.d(:,17);					      %7 stab  
  sys.d(:,8) = sys.d(:,18);					      %8 Lthrot
  sys.d(:,9) = sys.d(:,19);					      %9 Rthrot

  Ilon=[1 4 5 8 9];    % inputs to keep: elev, spoilers, throttle
  Ilat=[2 3 4 5];      % inputs to keep: aileron, rudder, spoilers

  sys(:,10:19) = []; % Remove the unused inputs
  
  Inames={'Elevator',  'Aileron','Rudder',... % 1 2 3
          'L Spoiler', 'R Spoiler',       ... % 4 5
          'Flaps',     'Stabilizer',      ... % 6 7
          'L Throttle','R Throttle'};         % 8-9

  set(sys,'Inputname',Inames);

end


if vabflag
    Ylon = [1 2 8 14]; % outputs to keep (tas,alpha,q,theta)
    Ylat = [3 7 9 13]; % outputs to keep (beta,p,r,phi)
    londyn=modred(sys(Ylon,Ilon),setdiff(1:12,Xlon),'del');
    londyn.a = londyn.c*londyn.a*inv(londyn.c);
    londyn.b = londyn.c*londyn.b;
    londyn.c = eye(4);
    set(londyn,'Statename',Onames([1 2 8 14]))
    
    latdyn=modred(sys(Ylat,Ilat),setdiff(1:12,Xlat),'del');
    latdyn.a = latdyn.c*latdyn.a*inv(latdyn.c);
    latdyn.b = latdyn.c*latdyn.b;
    latdyn.c = eye(4);
    set(latdyn,'Statename',Onames([3 7 9 13]))
    
    sys = sys([1:3, 7:15],:);
    sys.a = sys.c*sys.a*inv(sys.c);
    sys.b = sys.c*sys.b;
    sys.c = eye(12);
    set(sys,'Statename',Onames([1:3, 7:15]))    
    
else
    Ylon = [4 6 8 14]; % outputs to keep (u,w,q,theta)
    Ylat = [5 7 9 13]; % outputs to keep (v,p,r,phi)  
    londyn=modred(sys(Ylon,Ilon),setdiff(1:12,Xlon),'del');
    latdyn=modred(sys(Ylat,Ilat),setdiff(1:12,Xlat),'del');
    sys = sys(4:15,:);
end

%% Return to initial parameters
set_param('gtm_design','InlineParams',inlineflag);
set_param('gtm_design','Dirty',dirtyflag);

% reset Linearization Flag
appendmws(struct('LinearizeModeOn',0),'gtm_design');



