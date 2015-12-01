function MWS = init_design(vehicle,noise_on,fuelburn_on)
%function MWS = init_design(vehicle);
%
% Creates Model Workspace Structure for gtm_design simulation.
%
% Inputs:
%   vehicle     - type of vehicle, currently only 'GTM_T2'  (default = 'GTM_T2')
%   noise_on    - flag for turning sensor noise models on  (default = 0)
%   fuelburn_on - flag for turning fuel burn model on  (default = 0)
%
% Outputs:
%   MWS     - Simulation parameters, to be loaded into Model Workspace
%             with loadmws(MWS) or appendmws(MWS).
%

% d.e.cox@larc.nasa.gov
% $Id: init_design.m 4852 2013-08-06 22:12:54Z cox $

if ~exist('vehicle','var') || isempty(vehicle)
    vehicle='GTM_T2';
end

if strcmp(vehicle,'GTM'),
    vehicle='GTM_T2';  % Backwards compatible
end

if ~exist('noise_on','var') || isempty(noise_on)
    noise_on = 0;
end

if ~exist('fuelburn_on','var') || isempty(fuelburn_on)
    fuelburn_on = 0;
end

% Initialize MWS structure
MWS=[];

% Winds
MWS.WindDir = 270;  %deg,   true heading wind is coming FROM
MWS.WindSpd = 0;    %kts,   wind speed
MWS.WindShearOn = 1;

% Sim timestep
MWS.Timestep = 1/200; % sec

% Initial Conditions
ini.Altitude =     800; % ft
ini.tas      =     75;      % knots
ini.alpha    =     3;        % deg
ini.gamma    =     1;        % deg
ini.stab     =     0;
% ini.lat      =     37.02814654;  %Smithfield, deg
% ini.lon      =    -76.58696588;  %Smithfield, deg
% Flying at Wallops
ini.lat        =  37.827926944;
ini.lon        = -75.494061666;
MWS.StatesInp  = SetICs(ini);
MWS.runway_alt = 12; %ft

MWS.fuel_in_use  = fuelburn_on; % fuel burn on/off


switch(upper(vehicle))
    case 'GTM_T2',
      %MWS.Aero=load('T2_restricted_aerodatabase');
      MWS.Aero=load('T2_polynomial_aerodatabase');

       % Load aircraft parameters and noise models
       MWS = AC_baseparams_T2(MWS);
       MWS = NoiseParams_T2(MWS,noise_on); % Second parameter is on/off

       % Generate Damage Models
       MWS = DamageModels_T2(MWS);
    otherwise,
       error('No Parameters defined for vehicles: %s',vehicle);
end

% Surface/Throttle Offsets for trim
MWS.bias.aileron    =0;
MWS.bias.speedbrake =0;
MWS.bias.elevator   =0;
MWS.bias.flaps      =0;
MWS.bias.rudder     =0;
MWS.bias.stabilizer =0;
MWS.bias.throttle   =20;
MWS.bias.geardown   =0;

% Basic Table Options
MWS.LinearizeModeOn=0;
MWS.TrimModeOn=0;
MWS.SurfaceDeadbandOn=0;
MWS.TrimWithStab=0;
MWS.symmetric_aero_on  = 1;
MWS.DamageCase = 0;
MWS.DamageOnsetTime=10; % In secs.

% Engine on/off parameters
MWS.LengON = 1;
MWS.RengON = 1;

%Engine Ram Drag Coefficient
MWS.ram_drag_coef = 0.010;

% Set turbulence model parameters
MWS = init_turbulence(MWS);

% The following increase asymetric response at stall and
% have been used for pilot training
MWS.stall_cl_asym_enabled         = 0;     % turn the Cl asymetry at stall on/off
%MWS.stall_cl_asym_add_uncertainty = 0;    % add random uncertainties to Cl
%MWS.stall_cl_asym_vary_sign       = 0;    % apply random +/-1 gain to Cl


%--------------------SubFunctions--------------------

function [StatesInp] = SetICs(ini)
StatesInp= zeros(12,1);

knots2fps = 1/0.592487;
d2r=pi/180;

ub = (knots2fps)*ini.tas*cos(ini.alpha*d2r);
wb = (knots2fps)*ini.tas*sin(ini.alpha*d2r);

theta    = ini.alpha + ini.gamma;

StatesInp(1)  = ub;              %  1 - ub (ft/s)
StatesInp(2)  = 0;		 %  2 - vb (ft/s)
StatesInp(3)  = wb;		 %  3 - wb (ft/s)
StatesInp(4)  = 0;		 %  4 - pb (rad/s)
StatesInp(5)  = 0;		 %  5 - qb (rad/s)
StatesInp(6)  = 0;		 %  6 - rb (rad/s)
StatesInp(7)  = ini.lat*d2r;	 %  7 - lat (rad), +north,
StatesInp(8)  = ini.lon*d2r;	 %  8 - lon (rad), +east,
StatesInp(9)  = ini.Altitude;	 %  9 - h (ft)
StatesInp(10) = 0;	             % 10 - phi (rad)
StatesInp(11) = theta*d2r;         % 11 - theta (rad)
StatesInp(12) = pi/2;	           % 12 - psi (rad)





