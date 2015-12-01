function MWS=DamageModels_T2(MWS);
%function MWS=DamageModels_T2(MWS);
   
% $Id: DamageModels_T2.m 4852 2013-08-06 22:12:54Z cox $

% Valid Fields are:
%    RUDU.gain
%    RUDL.gain
%    AILL.gain
%    AILR.gain
%    SPLLIB.gain
%    SPLRIB.gain
%    SPLLOB.gain
%    SPLROB.gain
%    STAB.gain
%    ELLOB.gain
%    ELLIB.gain
%    ELRIB.gain
%    ELROB.gain
%    FLAPLOB.gain
%    FALPLIB.gain
%    FLAPRIB.gain
%    FLAPROB.gain
%    GEAR.gain
%
%    Mass.dIxxIyyIzzIxyIyzIx(6)
%    Mass.dCG(3)
%    Mass.dWeight(1)
%


% Case-1: Rudder Off
% Surfaces
MWS.DamageModels{1}.RUDU.gain=0;
MWS.DamageModels{1}.RUDL.gain=0;
MWS.DamageModels{1}.Mass.dCG = [0.126, 0.000, 0.028]/12;
MWS.DamageModels{1}.Mass.dWeight = -0.13;	
MWS.DamageModels{1}.Mass.dIxxIyyIzzIxzIyzIxy = [-0.00346, -0.06698, -0.06352, -0.01409, 0.00001, 0.00003];


% Case-2: Vertical Tail Off
% Surfaces
MWS.DamageModels{2}.RUDU.gain=0;
MWS.DamageModels{2}.RUDL.gain=0;
MWS.DamageModels{2}.Mass.dWeight = -1.31;
MWS.DamageModels{2}.Mass.dCG = [1.166	0.000	0.277]/12;
MWS.DamageModels{2}.Mass.dIxxIyyIzzIxzIyzIxy = [-0.03507, -0.57604, -0.54102, -0.13113, 0.00006, 0.00024];


% Case-3:  Left Outboard Flap Off
% Surfaces
MWS.DamageModels{3}.FLAPLOB.gain=0;
MWS.DamageModels{3}.Mass.dWeight = -0.09;
MWS.DamageModels{3}.Mass.dCG = [0.014, 0.041, 0.001]/12;
MWS.DamageModels{3}.Mass.dIxxIyyIzzIxzIyzIxy = [-0.01018, -0.00120, -0.01137, -0.00009, -0.00027, -0.00347];


% Case-4: 25% Left Wing Off
% Surfaces
MWS.DamageModels{4}.AILL.gain=0;
MWS.DamageModels{4}.Mass.dWeight = -0.81;
MWS.DamageModels{4}.Mass.dCG = [0.148, 0.628, 0.032]/12;
MWS.DamageModels{4}.Mass.dIxxIyyIzzIxzIyzIxy = [-0.25821, -0.01727, -0.27400, -0.00295, -0.01346, -0.05998];


% Case-5:  Left Elevator Off
% Surfaces
MWS.DamageModels{5}.ELLOB.gain=0;
MWS.DamageModels{5}.ELLIB.gain=0;
MWS.DamageModels{5}.Mass.dWeight = -0.07;
MWS.DamageModels{5}.Mass.dCG =[0.065, 0.010, 0.004]/12;
MWS.DamageModels{5}.Mass.dIxxIyyIzzIxzIyzIxy = [-0.00097, -0.03391, -0.03467, -0.00188, -0.00029, -0.00510];


% Case-6:  Left Stab Off
% Surfaces
MWS.DamageModels{6}.STAB.gain=0;
MWS.DamageModels{6}.ELLOB.gain=0;
MWS.DamageModels{6}.ELLIB.gain=0;
MWS.DamageModels{6}.Mass.dWeight = -0.59;	
MWS.DamageModels{6}.Mass.dCG = [0.553, 0.088, 0.032]/12;
MWS.DamageModels{6}.Mass.dIxxIyyIzzIxzIyzIxy = [-0.00918, -0.27315, -0.28049, -0.01559, -0.00265, -0.04370];







