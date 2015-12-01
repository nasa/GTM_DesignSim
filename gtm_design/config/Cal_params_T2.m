function [MWS] = Cal_params_T2(MWS)
%function [MWS] = Cal_params_T2(MWS)
%
% $Id: Cal_params_T2.m 4852 2013-08-06 22:12:54Z cox $

% ************** engine identification ******************
MWS.EngineID   = 3;                  % 3 or 7

% ************** Downlink Calibration *******************
RefGainBias=Cal_T2_Downlink();
MWS.RefGainBias_Vec=cell2mat(struct2cell(RefGainBias));

% ************** Uplink Calibration *********************
[DnCals, UpCals]=Cal_T2_Uplink(); 
MWS.UpCals_Eng=cell2mat(struct2cell(DnCals))';
MWS.UpCals_Pwm=cell2mat(struct2cell(UpCals))';

% *************** Surface limits ************************
[lo,hi,SurfaceLimits]=Cal_T2_Limits();
MWS.UplinkHiLimit = cell2mat(struct2cell(hi));
MWS.UplinkLoLimit = cell2mat(struct2cell(lo));
MWS.SurfaceLimits = cell2mat(struct2cell(SurfaceLimits)');

%**************** PWM JR Calibration ********************
JRCals_Eng.throttle_cmd   = DnCals.ENGTL;
JRCals_Eng.ail_cmd        = DnCals.AILR; 
JRCals_Eng.ele_cmd        = DnCals.ELLOB;
JRCals_Eng.rud_cmd        = DnCals.RUDU;
JRCals_Eng.gear_cmd       = DnCals.GEAR;
JRCals_Eng.flap_cmd       = DnCals.FLAPLOB;
JRCals_Eng.spllob_cmd     = DnCals.SPLLOB;
JRCals_Eng.splrob_cmd     = DnCals.SPLROB;
JRCals_Eng.handoff_switch = [0:.1:1]; 
JRCals_Eng.brake_cmd      = DnCals.BRAKE;
JRCals_Eng.spdbrake_cmd   = DnCals.SPLLIB; % Use left inboard spoiler
JRCals_Eng.steer_trim_cmd = DnCals.STEER;

JRCals_Pwm.throttle_cmd   = UpCals.THROTLC;
JRCals_Pwm.ail_cmd        = UpCals.AILRC; 
JRCals_Pwm.ele_cmd        = UpCals.ELLOBC;
JRCals_Pwm.rud_cmd        = UpCals.RUDUPC;
JRCals_Pwm.gear_cmd       = UpCals.GEARC;
JRCals_Pwm.flap_cmd       = UpCals.FLAPLOC;
JRCals_Pwm.spllob_cmd     = UpCals.SPLLOBC;
JRCals_Pwm.splrob_cmd     = UpCals.SPLROBC;
JRCals_Pwm.handoff_switch = [0:10]*40 + 1500;   
JRCals_Pwm.brake_cmd      = UpCals.BRAKEC;
JRCals_Pwm.spdbrake_cmd   = UpCals.SPLLIBC;  % Use left inboard spoiler
JRCals_Pwm.steer_trim_cmd = UpCals.STEERC;

MWS.JRCals_Eng=cell2mat(struct2cell(JRCals_Eng))';
MWS.JRCals_Pwm=cell2mat(struct2cell(JRCals_Pwm))';

% MAG3 Temperature Compensation parameters
% Per Murch e-mail, 12/11/09
% Swapped X/Y axes, negated Y axis, negated Z accel to change from Memsense
% axes to aircraft body-axes
MAG3TempComp.XGYRO  = 4.9745e-03;  % deg/sec/deg 
MAG3TempComp.YGYRO  = 4.3213e-02;  % deg/sec/deg
MAG3TempComp.ZGYRO  = -4.2256e-02; % deg/sec/deg
MAG3TempComp.XACCEL = -2.0895e-04; % g/deg C
MAG3TempComp.YACCEL = -1.1745e-04; % g/deg C
MAG3TempComp.ZACCEL = 1.1716e-05;  % g/deg C

MWS.MAG3TempComp = cell2mat(struct2cell(MAG3TempComp)');

