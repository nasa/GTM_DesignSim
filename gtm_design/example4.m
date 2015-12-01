%
%------------------ Trim to climbing turn------------------ 
%
% Script trims to a climbing turn and linearizes
% Runs three simulations and plots comparison
%   Sim-1:  Nonlinear sim starting from trim condition
%   Sim-2:  Nonlinear sim starting from perturbed trim condition
%   Sim-3:  Linear sim starting from perturbed trim condition

% $Id: example4.m 4852 2013-08-06 22:12:54Z cox $
% d.e.cox@larc.nasa.gov

% Load nominal starting parameter set
loadmws(init_design(),'gtm_design');
% Retrim vehicle into climbing turn
[MWS,Xtrim,Fcond,Err]=trimgtm( struct('eas',95, 'gamma',3,  'yawrate',10),'elev',1 );

% Get linear model of system in climbing turn
fprintf(1,'Linearizing...')
loadmws(MWS,'gtm_design');
sys_clbtrn=linmodel(MWS);
fprintf(1,' Done\n');

% Simulate and plot
figure(1),clf
fprintf(1,'Simulating...');
tic;sim('gtm_design',[0 60]);realdt=toc; 
tout1=tout;Lon1=sout.eom.longitude*180/pi; Lat1=sout.eom.latitude*180/pi; Alt1=sout.eom.altitude;
fprintf(1,' Done, Running at %6.2f times real-time\n',60/realdt)

% Tweak initial conditions (+2 step in angle of attack)
MWS_off=seteomic(MWS,'alpha', Fcond.alpha+2 );
loadmws(MWS_off,'gtm_design');

% Simulate nonlinear model
fprintf(1,'Simulating...');
tic;sim('gtm_design',[0 60]);realdt=toc;
tout2=tout;Lon2=sout.eom.longitude*180/pi; Lat2=sout.eom.latitude*180/pi; Alt2=sout.eom.altitude;
fprintf(1,' Done, Running at %6.2f times real-time\n',60/realdt)

% Simulate linear model, tweaked initial conditions
Xo=MWS_off.StatesInp(1:12)-Fcond.Xo(1:12);
tlin=[0:0.00463:max(tout)]';
y=lsim(sys_clbtrn,zeros(length(tlin),size(sys_clbtrn,2)),tlin,Xo);

% Plot
h1=plot3(Lon1,Lat1,Alt1'); grid on,hold on
h2=plot3(Lon2,Lat2,Alt2','r'); 
axlim=axis;
h3=plot3(interp1(tout1,Lon1,tlin,'linear')+y(:,7)*180/pi,...
         interp1(tout1,Lat1,tlin,'linear')+y(:,8)*180/pi,...
	 interp1(tout1,Alt1,tlin,'linear')+y(:,9),'g');
axis(axlim);
legend([h1 h2 h3],'IC on trim point', 'IC off trim point','IC-off, Linear Model');
title({'Trimmed to climbing turn, 60 sec run', 'Off Initial Condition: +2deg step in angle of attack'});
xlabel('Longitude (deg)'),ylabel('Latitude (deg)'),zlabel('Altitude (ft)');
 
if(exist('AutoRun','var'))
    pause(.2);
    orient portrait; print -dpng exampleplot04;
end





