function MWS_out = seteomic(MWS,varargin);
%function MWS_out = seteomic(MWS,statename,value,statename,value,...)
%
% This function allows the initial condtions of the gtm_design simulation's 
% equation of motion (MWS.StatesInp) to be specified by named values. 
%
% Specifically statename is one of:
%     tas   - total airspeed (knots)
%     alpha - angle of attack (deg)
%     beta  - sideslip (deg)
%     p     - body rate (deg/sec)
%     q     - body rate (deg/sec)
%     r     - body rate (deg/sec)
%     lat   - latitude (deg)
%     lon   - longitude (deg)
%     alt   - altitude (ft)
%     phi   - Euler angle (deg)
%     theta - Euler angle (deg)
%     psi   - Euler angle (deg)
%
% Values not explictly specified remain at the value they had in MWS
%
% Examples: 
%     MWS=seteomic(init_design(),'alt',3000);
%     MWS=seteomic(MWS,'tas',90,'beta',3,'p',15);  
%

% d.e.cox@larc.nasa.gov
% $Id: seteomic.m 4852 2013-08-06 22:12:54Z cox $

% Constants
fps2knots = 0.592487;
knots2fps = 1/fps2knots;
d2r=pi/180;
r2d=180/pi;

% default to incoming parameters
MWS_out=MWS;

% put named IC values into a structure
ini=struct(varargin{:});


% Only set these if one of tas/alpha/beta is being specified
fn=fieldnames(ini);
if ~isempty(strmatch('tas',fn)) || ~isempty(strmatch('alpha',fn))|| ~isempty(strmatch('beta',fn)),
  V=MWS.StatesInp(1:3);
  Vt=sqrt(sum(V.^2));
  % For unspecified but coupled parameters, preserve incoming condition.
  if ~isfield(ini,'alpha'), ini.alpha=atan2(V(3),V(1))*r2d; end
  if ~isfield(ini,'beta');  ini.beta =atan2(V(2)*cos(ini.alpha),V(1))*r2d;  end
  if ~isfield(ini,'tas'),   ini.tas=Vt/knots2fps; end
end

% Error Check input, kick out on unknown names
fn=fieldnames(ini); 
knownames={ 'alpha','beta','tas','p','q','r','alt','lat','lon','phi','theta','psi'};
for i=[1:length(fn)],
  if isempty(strmatch(fn{i},knownames,'exact')),
    error(sprintf('Unknown name: %s\n',fn{i}));
  end
end

for i=[1:length(fn)],
  switch(fn{i})
    case {'alpha','beta','tas'},  % coupled params, this sets IC multiple times,... inefficient but harmless
      ub = (knots2fps)*ini.tas*cos(ini.alpha*d2r)*cos(ini.beta*d2r);
      vb = (knots2fps)*ini.tas*sin(ini.beta*d2r);
      wb = (knots2fps)*ini.tas*sin(ini.alpha*d2r)*cos(ini.beta*d2r);
      MWS_out.StatesInp(1)  = ub;        %  1 - ub (ft/s)                       
      MWS_out.StatesInp(2)  = vb;	  %  2 - vb (ft/s)                  
      MWS_out.StatesInp(3)  = wb;	  %  3 - wb (ft/s)                  
      
    case 'p'
      MWS_out.StatesInp(4)=ini.p*d2r;
    case 'q'
      MWS_out.StatesInp(5)=ini.q*d2r;
    case 'r'
      MWS_out.StatesInp(6)=ini.r*d2r;
      
    case 'lat'
      MWS_out.StatesInp(7)=ini.lat*d2r;
    case 'lon'
      MWS_out.StatesInp(8)=ini.lon*d2r;
    case 'alt'
      MWS_out.StatesInp(9)=ini.alt;
      
    case 'phi',
      MWS_out.StatesInp(10)=ini.phi*d2r;
    case 'theta',
      MWS_out.StatesInp(11)=ini.theta*d2r;
    case 'psi',
      MWS_out.StatesInp(12)=ini.psi*d2r;

  end
end











