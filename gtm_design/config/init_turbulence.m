function [ mws ] = init_turbulence( mws )
% Adds the Dryden turbulence model gain parameters as variables in the 
% Model Workspace Structure for gtm_design simulation.
%
% Inputs:
%   mws - the existing model workspace structure
%
% Outputs:
%   mws - the updated model workspace structure

% $Id: init_turbulence.m 4852 2013-08-06 22:12:54Z cox $


% The u, v, and w gust velocities are calculated using the Dryden Model and
% data obtained from NASA Tm-4511. For altitudes less than 1000 m, the
% model contains only severe data from Tm-4511. As a result, all turbulence
% conditions are calculated using the severe parameters and the resulting
% gusts are passed through gain blocks which can be manipulated to produce
% a variety of turbulence levels. Analysis of flight data yielded the
% following gain settings to simulate the levels of turbulence experienced 
% at Fort Pickett.

% Light turbulence (no turbulence)

mws.u_gain_light = 0.2;
mws.v_gain_light = 0.2;
mws.w_gain_light = 0.17;

% Moderate turbulence

mws.u_gain_moderate = 0.4;
mws.v_gain_moderate = 0.4;
mws.w_gain_moderate = 0.34;

% Severe turbulence

mws.u_gain_severe = 0.4;
mws.v_gain_severe = 1.152;
mws.w_gain_severe = 0.34;

% Simulation turbulence settings:

mws.ugain = 0;
mws.vgain = 0;
mws.wgain = 0;

% This switch enables the turbulence model subsystem.
% To turn on turbulence, set the switch to 1. 
mws.DrydenModelSwitch = 0;

end

