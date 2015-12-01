%
%----------- Frequency/Damping for level-flight trim conditions ------------
%
% Script calculates frequency and damping of approximate 4th order models over 
% a set of level flight trim condtions.

% $Id: example3.m 4852 2013-08-06 22:12:54Z cox $
% d.e.cox@larc.nasa.gov



%% Trim to set of angles of attack
AOA=[2,4,6,8,  10,11,12,13,14,  16,18,20];
%AOA=[2:3:20];

% Allocate memory
shortperiod = zeros(length(AOA),2);
phugiod     = zeros(length(AOA),2);

% Comute Trim points
loadmws(init_design(),'gtm_design');
fprintf('  Trimming/Linearizing at alpha:\n');
for trimpt=[1:length(AOA)],
  fprintf(1,'      %3.2f,',AOA(trimpt));
  [MWS,Xt,Tc,Err]=trimgtm( struct('alpha',AOA(trimpt),'gamma',0),[],0);
  fprintf(1,' Residual=%3.2e\n',Err);
  loadmws(MWS,'gtm_design'); 
  [sys,lon,lat]=linmodel(MWS);
  [wn,z]=damp(lon);
  % Just assuming frequency seperation here...
  phugoid(trimpt,:)     = [wn(1)/2/pi,z(1)];
  shortperiod(trimpt,:) = [wn(3)/2/pi,z(3)];
end
fprintf(' Done\n');

% Make alpha trim point plot
figure(1),clf
subplot(221),plot(AOA,phugoid(:,1),'-s'),grid on
title('Phugoid Mode by AOA');ylabel('Frequency (Hz)');xlabel('alpha (deg)');

subplot(223),plot(AOA,phugoid(:,2),'-s'),grid on
title('Phugoid Mode by AOA');ylabel('Damping');xlabel('alpha (deg)');

subplot(222),plot(AOA,shortperiod(:,1),'-s'),grid on
title('Short-Period Mode by AOA');ylabel('Frequency (Hz)');xlabel('alpha (deg)');

subplot(224),plot(AOA,shortperiod(:,2),'-s'),grid on
title('Short-Period Mode by AOA');ylabel('Damping');xlabel('alpha (deg)');

if (exist('AutoRun','var'))
    pause(.2);
    orient portrait; print -dpng exampleplot03;
end

