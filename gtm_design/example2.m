%
%--------------- Calculate set of level flight trim conditions ----------------
%
% Script calculates a set of level flight trim condtions for different
% calibrated airspeeds and angles-of-attack.  Plots trim conditions as
% a function of specified target condition

% $Id: example2.m 4852 2013-08-06 22:12:54Z cox $
% d.e.cox@larc.nasa.gov

% -------------eas plot----------------
% Trim to set of equivalent air speeds
speeds=[[46:2:58],[60:10:130]];

% Allocate variables to plot
alpha=zeros(length(speeds),1);
elevator=zeros(length(speeds),1);
throttle=zeros(length(speeds),1);

% Compute trim points
MWS=init_design();
fprintf('\nLevel Flight Trim\n  Trimming at eas:\n');
for trimpt=[1:length(speeds)],
  fprintf(1,'     %3.2f,',speeds(trimpt));
  loadmws(MWS,'gtm_design'); 
  [MWS,Xt,Tc,Err]=trimgtm(struct('eas',speeds(trimpt),'gamma',0), 'elev', 0);
  if (Err>1e-3),  % try again, different starting poing
      loadmws(init_design(),'gtm_design');
      fprintf('   Poor convergence, trying again. ');
      [MWS,Xt,Tc,Err]=trimgtm(struct('eas',speeds(trimpt),'gamma',0), 'elev', 0);
      if (Err>1e-3)  % No joy, skip point.
          Tc=struct('alpha',NaN,'elevator',NaN,'throttle',NaN);
          fprintf(1,'Failed to Trim  ');
          else fprintf(1,'Done  ');
      end
  end
  fprintf(1,' Residual=%3.2e\n',Err);
  alpha(trimpt)   =Tc.alpha;   
  elevator(trimpt)=Tc.elevator;
  throttle(trimpt)=Tc.throttle;
end
fprintf(' Done\n');

% Make eas trim point plot
figure(1),clf
subplot(121),
[ax,h1,h2]=plotyy(speeds,[elevator,alpha],speeds,throttle); grid on
set(ax,{'YColor'},{'blue';'red'});
set([h1;h2],{'Color'},{'blue';'blue';'red'});
set([h1;h2],{'Marker'},{'o';'s';'>'})
set([h1;h2],{'MarkerFaceColor'},{'blue';'none';'red'});
title('Trimmed level flight by eas');
legend([h1;h2], { 'elevator','alpha','throttle'} );  
set([h1;h2],{'Marker'},{'o';'s';'>'});
ylabel(ax(1),'Elevator(deg),  alpha(deg)');
ylabel(ax(2),'Throttle(%)');
xlabel('eas (knots)')


%----------AOA plot---------------

%% Trim to set of angles of attack
AOA=[2:2:28];

% Variables to plot
eas=zeros(length(AOA),1);
elevator=zeros(length(AOA),1);
throttle=zeros(length(AOA),1);
fprintf('  Trimming at alpha:\n');

% Comute Trim poin
MWS=init_design();
for trimpt=[1:length(AOA)],
  fprintf(1,'      %3.2f,',AOA(trimpt));
  loadmws(MWS,'gtm_design');
  [MWS,Xt,Tc,Err]=trimgtm(struct('alpha',AOA(trimpt),'gamma',0), 'elev', 0);
  if (Err>1e-3),  % try again, different starting poing
      loadmws(init_design(),'gtm_design');
      fprintf('   Poor convergence, trying again. ');
      [MWS,Xt,Tc,Err]=trimgtm(struct('alpha',AOA(trimpt),'gamma',0), 'elev', 0);
      if (Err>1e-3)  % No joy, skip point.
          Tc=struct('eas',NaN,'elevator',NaN,'throttle',NaN);
          fprintf(1,'Failed to Trim  ');
          else fprintf(1,'Done  ');
      end
  end
  fprintf(1,' Residual=%3.2e\n',Err);
  eas(trimpt)   =Tc.eas;
  elevator(trimpt)=Tc.elevator;
  throttle(trimpt)=Tc.throttle;
end
fprintf(' Done\n');

% Make alpha trim point plot
subplot(122),
[ax,h1,h2]=plotyy(AOA,elevator,AOA,[eas,throttle]); grid on
set(ax,{'YColor'},{[0 0 1];[1 0 0]});
set([h1;h2],{'Color'},{'blue';'red';'red'});
set([h1;h2],{'Marker'},{'o';'s';'>'})
set([h1;h2],{'MarkerFaceColor'},{'blue';'none';'red'});
title('Trimmed level flight by AOA');
legend([h1;h2],{ 'elevator','eas','throttle'});  
ylabel(ax(1),'Elevator(deg)');
ylabel(ax(2),'eas(knots) and throttle(%)');
xlabel(ax(1),'alpha (deg)');

if (exist('AutoRun','var'))
    pause(.2);
    orient portrait; print -dpng exampleplot02;
end
