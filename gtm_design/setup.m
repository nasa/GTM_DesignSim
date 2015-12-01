% d.e.cox@larc.nasa.gov
% $Id: setup.m 4852 2013-08-06 22:12:54Z cox $

% Add mat file directory
addpath(genpath('./config/'));

% Add mfiles directories.
addpath('./mfiles');

% Add compilex code directory
addpath('./obj');

% Add libriary directory
addpath('./libs');

rehash path


% Close model if open, prompt if changed.
if  not(isempty(find_system('SearchDepth',0,'Name','gtm_design')))
    if strcmp(get_param('gtm_design','Dirty'),'on');
        savechanges=input('  gtm_design model has been changed, save changes (y/N) ?','s');
        if ~isempty(savechanges) && strcmpi(savechanges(1),'y');
	  fprintf(1,'Saving System...');
	  clearmws % Suppreses warning mesage about model workspace
	  clear savechanges % clear temporary response variable
	  save_system('gtm_design');
	  fprintf(1,' Done.\n');
        end
    end
    % terminate if left in paused state. matlab will not close paused model.
    if strcmp(get_param('gtm_design','SimulationStatus'),'paused'),
        gtm_design([],[],[],'term');
    end
    bdclose('gtm_design');
end

% Clear simout* variables to ensure clean initialization
clear simout simout_names SimWSout

% Clear precompiled functions, required to reflect changes in mfiles
% that exist outside working directory.
clear functions

% Open block diagram
warning('off','Simulink:SL_MdlFileNotOnPath'); % Suppress spurious warnings
open_system('gtm_design');  

% load nominal starting point
loadmws(init_design('GTM'),'gtm_design');

% Trim model, and load trimmed conditions
appendmws(trimgtm(struct('eas',75, 'gamma',0)));

warning('on','Simulink:SL_MdlFileNotOnPath');





