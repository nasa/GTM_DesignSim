%
%--------------- During 45 degree bank angle turn incur damage------------------ 
%
% Script trims to a climbing 45 degree bank angle turn then simulates 
% each preprogramed  failure condition.  


% $Id: example6.m 4852 2013-08-06 22:12:54Z cox $
% david.e.cox@.nasa.gov


% Load nominal starting parameter set
MWS_Nominal=init_design();

% Set nominal trim to climbing turn
MWS_Nominal.DamageCase=0;
MWS_Nominal.DamageOnsetTime=120;
loadmws(MWS_Nominal);
[MWS_Nominal,Xtrim,Fcond,Err]=trimgtm(struct('eas',95, 'gamma',3,...
                                             'yawrate',[],'roll',45));


% Simulate flight without damage
loadmws(MWS_Nominal);
fprintf(1,'Simulating...');
sim('gtm_design',[0 15]);
fprintf(1,'Done\n');
tout1=tout;Lon1=sout.eom.longitude*180/pi; Lat1=sout.eom.latitude*180/pi; Alt1=sout.eom.altitude; 
eas1=sout.aux.eas;alpha1=sout.aux.alpha; beta1=sout.aux.beta; gamma1=sout.aux.gamma; 
pqr1=180/pi*[sout.eom.pb sout.eom.qb sout.eom.rb];
phi1=180/pi*sout.eom.phi;
theta1=180/pi*sout.eom.theta;
psi1=180/pi*sout.eom.psi;

% Simlate each damage case and plot
for i=[1:length(MWSout.Aero.dC6_damage.cases)],
  % Simulate flight with Damage
  % Set Damage Conditions
  MWS_Damage=MWS_Nominal;
  MWS_Damage.DamageCase=i;
  MWS_Damage.DamageOnsetTime=10;
  %MWS_Damage.Aero.dC6_damage.ddscale.data=ones(18,6,3,6);
  loadmws(MWS_Damage);
  fprintf(1,'Simulating...');
  fprintf(1,'Done\n');
  sim('gtm_design',[0 15]);
  tout2=tout;Lon2=sout.eom.longitude*180/pi; Lat2=sout.eom.latitude*180/pi; Alt2=sout.eom.altitude; 
  eas2=sout.aux.eas;alpha2=sout.aux.alpha; beta2=sout.aux.beta; gamma2=sout.aux.gamma; 
  pqr2=180/pi*[sout.eom.pb sout.eom.qb sout.eom.rb];
  phi2=180/pi*sout.eom.phi;
  theta2=180/pi*sout.eom.theta;
  psi2=180/pi*sout.eom.psi;

  % Plot
  % ------------------------Plots---------------------------
  h=figure(1);,set(h,'Position',[20,20,1000,800]);clf
  % Alpha/Beta
  ax=axes('position',[.05 .70 .2 .2]);
  plot(tout2,[alpha2,beta2]);
  legend({'\alpha','\beta'},'Location','SouthWest');,grid on
  xlabel('time (sec)'),
  ylabel('\alpha (deg), \beta (deg)');
  %set(ax,'Ylim',[-10 20]);
  title('Alpha/Beta');
  
  % Flight Path Angle and Airspeed
  axes('position',[.05 .40 .2 .2]);
  [ax,h1,h2]=plotyy(tout2,gamma2,tout2,eas2);grid on
  xlabel('time (sec)'),
  ylabel(ax(1),'Flight Path,  \gamma (deg)');
  ylabel(ax(2),'Equivalent Airspeed (konts)')
  legend([h1;h2],{'\gamma','eas'},'Location','SouthWest');
  title('Flight Path Angle and Airspeed');
  
  % Angular Rates
  ax=axes('position',[.05 .10 .2 .2]);
  plot(tout2,pqr2);grid on
  legend({ 'p','q','r'},'Location','SouthWest');
  xlabel('time (sec)'),ylabel('angular rates (deg/sec)')
  %set(ax,'Ylim',[-15 15]);
  title('Angular Rates');
  
  % Euler Angles
  ax=axes('position',[.50 .70 .45 .2]);
  plot(tout2,[phi2,theta2,psi2]);
  legend({'roll','pitch','yaw'},'Location','SouthWest');,grid on
  xlabel('time (sec)'),
  ylabel('\phi (deg), \theta (deg), \psi (deg)');
  %set(ax,'Ylim',[-10 20]);
  title('Euler Angles');
  
  % Trajectory: 3D plot with orientated vehicle
  ax=axes('position',[.50,.1,.45,.45]);
  titlestr=sprintf('Nominal and DamageCase:%s',...
                   strrep(MWSout.Aero.dC6_damage.cases{MWSout.DamageCase},'_','\_'));;
  h1=plot3(Lat1,Lon1,Alt1','b'); grid on,hold on
  h2=plot3(Lat2,Lon2,Alt2','r'); 
  legend([h1 h2],{'Nominal Flight Path','Damage Flight Path'},...
         'Location','NorthWest');
  title(titlestr);
  xlabel('Latitude (deg)'),ylabel('Longitude (deg)'),zlabel('Altitude (ft)');
  view(-45,5);set(ax,'Zlim',[600 1000]);
  if (exist('AutoRun','var'))
     pause(.2);
     orient portrait
     eval(sprintf('print -dpng exampleplot06-%d',i));
  else
    fprintf(1,'Finished Damage Case %d, Hit Return to Continue...',i),pause,fprintf(1,'.\n');
  end
end




