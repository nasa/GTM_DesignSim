function [MWS] = AC_calcparams_T2(MWS)
% Additional aircraft parameters for T2
% Needed only in AirSTARsim, mostly calculated parameters
%$Id: AC_calcparams_T2.m 4852 2013-08-06 22:12:54Z cox $

% Fuel parameters
MWS.fuel_init  = 11.52; % lbs,  initial fuel weight
MWS.joker_fuel = 4.7;   % lbs,  joker fuel (weight remaining)
MWS.bingo_fuel = 4.2;   % lbs,  bingo fuel (weight remaining)
MWS.time_init  = 16;    % min,  initial fuel time
MWS.joker_time = 3;     % min,  joker fuel (time remaining)
MWS.bingo_time = 1.5;   % min,  bingo fuel (time remaining)

% Filtering parameters
MWS.tau_press   = 0;      % nd,   filter time constant for pressures
MWS.tau_rates   = 0;      % nd,   filter time constant for angular rates
MWS.tau_vanes   = 0.1;    % nd,   filter time constant for alpha/beta vanes
MWS.tau_accel   = 0.1;    % nd,   filter time constant for accelerometers
MWS.tau_display = 0.3;    % nd,   filter time constant for display variables


% T2 Sensor Geometry: Measured, 7/8/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alpha offsets are geometric angle offsets plus nominal upwash correction.
MWS.alphavl_offset =  -0.7 - 0.55;   %deg, boom angle offset plus upwash correction of left alpha vane, boom angled down = '+' correction
MWS.alphavr_offset =  -0.1 + 0.54;   %deg, boom angle offset plus upwash correction of right alpha vane, boom angled down = '+' correction
MWS.betavl_offset  =  -0.6 - 0.48;   %deg, boom angle offset plus upwash correction of left beta vane, boom angled right/inwards = '+' correction
MWS.betavr_offset  =   0.0 + 0.68;    %deg, boom angle offset plus upwash correction of right beta vane, boom angled right/outwards = '+' correction

MWS.alphavl_pos    = [-58.37  -42.35 -14.26]/12;    % ft,   location of left alpha vane
MWS.alphavr_pos    = [-58.32   42.40 -14.04]/12;    % ft,   location of right alpha vane
MWS.betavl_pos     = [-60.87  -40.93 -12.73]/12;    % ft,   location of left beta vane
MWS.betavr_pos     = [-60.82   40.88 -12.57]/12;    % ft,   location of right beta vane 
MWS.MIDG_pos       = [-53.92    0.00 -10.73]/12;    % ft,   location of MIDG
MWS.MAG3_pos       = [-53.35    0.00  -9.33]/12;    % ft,   location of MAG3 sensor 

% Alpha/Beta upwash/sidewash
MWS.alphavr_upwash  = [0 1;0 1];    %deg,   2-D table of upwash values (row 2) corresponding to alpha (row 1)
MWS.betavr_sidewash = [0 1;0 1];    %deg,   2-D table of sidewash values (row 2) corresponding to beta (row 1)
MWS.alphavl_upwash  = [0 1;0 1];    %deg,   2-D table of upwash values (row 2) corresponding to alpha (row 1)
MWS.betavl_sidewash = [0 1;0 1];    %deg,   2-D table of sidewash values (row 2) corresponding to beta (row 1)

% Navigation Parameters
MWS.mag_var    = 9.733;     % deg,  variation between true and magnetic north for Fort Pickett(BKT) 
% 11.4; WFF (37.824525,-75.497123), from http://www.ngdc.noaa.gov/geomagmodels/Declination.jsp
% 9.7;  BKT (37.073026	-77.952019), from http://www.ngdc.noaa.gov/geomagmodels/Declination.jsp

MWS.wgs84_bias = 32.97 ;  % m,    Bias between WGS84 ellipse and mean sea level (MSL) for Fort Pickett(BKT)
% 37.975; WFF (37.824525,-75.497123) (sign swapped), from http://earth-info.nga.mil/GandG/wgs84/gravitymod/wgs84_180/intptW.html
% 32.97;  BKT (37.073026	-77.952019) (sign swapped), from http://earth-info.nga.mil/GandG/wgs84/gravitymod/wgs84_180/intptW.html

% Stall speed estimation Parameters, updated 3/31/09
MWS.wt_ref = 49.6;                  %lbs,   reference weight for stall speeds
MWS.vs1g   = [51.6  46.1   40.6];   %kts,   stall speeds as a function of flap position (0, 15, 30)

% Engine Parameters- NOTE: Pump voltage/fuel flow tables (here and in
% engine_JetCatP70_lib.mdl) need to be updated with engine bench test data,
% when available. (3/31/09)
MWS.rpm_reference = 123000; %RPM,   reference RPM for normalizing
MWS.fflow_RPM_poly=[5.51350196e-007 -6.88734724e-005 6.27511799e-003 0.00000000e+000]; %lbs/min,    reduced fuel flow 3rd order polynomial fit using reduced RPM, based on T1_engines_7-25-09.xlsx, with revised fflow cal, 9/2/09
  
MWS.thrust_model = [[31.519,38.3721,44.6665,51.361,55.7506,60.6258,62.9154,65.8268,69.2567,73.098,76.9685,80.0465,83.2392,86.3014,92.2054,100.1233;];... % percent of reference RPM - updated with preliminary Jetcat P70 data
    [0.877577128039901,1.25154799079791,1.73579024647613,2.42433109574678,2.98545444575323,3.72114226762550,4.11032206326126,4.64776836008787,5.34487096479714,6.21192179998671,7.18276297471701,8.02789361647789,8.97593452341355,9.95620410254875,12.0519157523107,15.3152443615613;];...%lbs,   2-D table of thrust values (row 2) corresponding to power settings
    [0.00 6.00 12.00 19.00 24.00 30.00 33.00 37.00 42.00 48.00 54.50 60.00 66.00 72.00 84.00 100.00]];% percent handle corresponding to percent of reference RPM (row 1)

%Ram Drag Coefficient
MWS.ram_drag_coef = 0.010;

% OFFSET LANDING ---------------------------------------------------------
% The initial conditions of the offset landing function are specified in
% the vector below.  Initial heading and altitude are fairly
% self-explanatory.  The reference point, reference heading, and offsets
% are used to specify initial position, and require a little explanation.  
% Imagine a typical Cartesian coordinate plane with its origin at the
% reference latitude and longitude, and with its positive Y-axis extending
% away from the origin in the direction of the reference heading.  In this
% representation, the initial lateral and longitudinal offsets are a
% coordinate pair that specify X and Y directions in this coordinate
% plane.  The initial offset landing position of the model is determined by
% starting from the reference position and applying the specified offsets.
MWS.offset_landing = [44, ...         % Initial heading (deg from magnetic north) of model
                      48, ...         % Initial barometric altitude (ft) of model
                      -94, ...        % Initial lateral position (ft) of the model, specified as an offset from the reference point/heading
                      -567, ...       % Initial longitudinal position (ft) of the model, specified as an offset from the reference point/heading
                      37.068706, ...  % Reference point latitude (deg)
                      -77.956996, ... % Reference point longitude (deg)
                      44];            % Reference heading (deg from magnetic north) from the reference point