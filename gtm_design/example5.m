%
%------------------ Trim to Steady Spin Condition------------------ 
%
% Script trims to a targeted spin condition, simulates from that condition
% and plots trajectory.
%
% alpha,beta,p,q,r, are all steady non-zero values.
%

% $Id: example5.m 4852 2013-08-06 22:12:54Z cox $
% d.e.cox@larc.nasa.gov


% Target conditions taken from Austin Murch's piloted spin data,
% done after sign-error correction of revision 296.
target=[];  %clear target variable
target.eas = 70.66;
target.alpha= 21.34;
target.beta = -1.33;
target.pdeg = -6.61*180/pi;
target.qdeg = 0.827*180/pi;
target.rdeg = -2.58*180/pi;

% Allow yawrate to be free variable
target.yawrate=[];

% Start with some altitude,otherwise nominal init
loadmws(seteomic(init_design(),'alt',4000),'gtm_design'); 

% Trim to spiral for initial guess
% This is *very* sensitive, if spin does not have constant parameters
% then try changing this initial guess
 MWS=trimgtm(struct('gamma',-5,'yawrate',30));
% MWS=trimgtm(struct('gamma',0,'yawrate',30));
%MWS=trimgtm(struct('gamma',-10,'beta',0,'alpha',20)); 
loadmws(MWS,'gtm_design');

% Trim to spin conditions
[MWS,Xt,Tc,Err]=trimgtm(target);
loadmws(MWS,'gtm_design');

% Simulate
[t,x,y]=sim('gtm_design',[0 10]); 

% Convert from lat/lon to ft (Calibrated at Smithfield)
Xeom=y(:,7:18);
dist_lat=(Xeom(:,7)-Xeom(1,7)) * 180/pi*364100.79;
dist_lon=(Xeom(:,8)-Xeom(1,8)) * 180/pi*291925.24;
alt=Xeom(:,9);

% Define simple airplane shape
scale=.30;
x1=scale*([0.0,-.5, -2.0, -3.0,-4.0, -3.25, -5.5, -6.0, -6.0]+3.0);
y1=scale*[0.0, 0.5,  0.5, 4.25, 4.5,  0.5,   0.5,  1.5,  0.0];
Vehicletop=[ [x1,fliplr(x1)]; [y1,fliplr(-y1)]; -.01*ones(1,2*length(x1))];
Vehiclebot=[ [x1,fliplr(x1)]; [y1,fliplr(-y1)];  .01*ones(1,2*length(x1))];


% ------------------------Plots---------------------------
h=figure(1);,set(h,'Position',[20,20,1000,800]);clf

% Alpha/Beta
axes('position',[.1 .70 .2 .2])
plot(t,[sout.aux.alpha,sout.aux.beta]);
legend({'\alpha','\beta'},'Location','SouthEast');,grid on
xlabel('time (sec)'),
ylabel('\alpha (deg), \beta (deg)');
title('Alpha/Beta');

% Flight Path Angle and Airspeed
axes('position',[.1 .40 .2 .2])
[ax,h1,h2]=plotyy(t,sout.aux.gamma,t,sout.aux.eas);grid on
xlabel('time (sec)'),
ylabel(ax(1),'Flight Path,  \gamma (deg)');
ylabel(ax(2),'Equivalent Airspeed (konts)')
legend([h1;h2],{'\gamma','eas'},'Location','SouthEast');
title('Flight Path Angle and Airspeed');

% Angular Rates
axes('position',[.1 .10 .2 .2])
plot(t,Xeom(:,4:6)*180/pi);grid on
legend({ 'p','q','r'},'Location','SouthEast');
xlabel('time (sec)'),ylabel('angular rates (deg/sec)')
title('Angular Rates');

% Trajectory: 3D plot with orientated vehicle
axes('position',[.45,.1,.45,.8])
plot3(dist_lat,dist_lon,alt);grid on, axset=axis; % Just get axis limits
%cnt=0;
% resample at equally spaced points for animation plot
tplot=[0:.1:max(t)];
X_ani=interp1(t,Xeom,tplot);
lat_ani=interp1(t,dist_lat,tplot);
lon_ani=interp1(t,dist_lon,tplot);
alt_ani=interp1(t,alt,tplot);
tic
for i=[1:length(tplot)]
  plot3(dist_lat,dist_lon,alt);grid on
  Offset=repmat([lat_ani(i);lon_ani(i);alt_ani(i)],1,size(Vehicletop,2));
  Ptmp=diag([1,1,-1])*transpose(euler321(X_ani(i,10:12)))*Vehicletop + Offset;
  patch(Ptmp(1,:),Ptmp(2,:),Ptmp(3,:),'g');
  Ptmp=diag([1,1,-1])*transpose(euler321(X_ani(i,10:12)))*Vehiclebot + Offset;
  patch(Ptmp(1,:),Ptmp(2,:),Ptmp(3,:),'c');
  view(25,10),axis(axset),hold off
  xlabel('Lat. Crossrange(ft)');
  ylabel('Long. Crossrange(ft)');
  zlabel('Altitude(ft)');
  title('Simulation Trajectory and Orientation');
  pause(.1);  % Adjust to get plotting close to real-time
  % cnt=cnt+1;M(cnt)=getframe;
end
toc
if(exist('AutoRun','var'))
    pause(.2);
    orient portrait; print -dpng exampleplot05;
end
%movie(gca,M,3,4);
