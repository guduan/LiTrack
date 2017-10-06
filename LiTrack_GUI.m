function varargout = LiTrack_GUI(varargin)
% LiTrack_GUI M-file for LiTrack_GUI.fig
%      LiTrack_GUI, by itself, creates a new LiTrack_GUI or raises the existing
%      singleton*.
%
%      H = LiTrack_GUI returns the handle to a new LiTrack_GUI or the handle to
%      the existing singleton*.
%
%      LiTrack_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LiTrack_GUI.M with the given input arguments.
%
%      LiTrack_GUI('Property','Value',...) creates a new LiTrack_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LiTrack_GUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LiTrack_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help LiTrack_GUI

% Last Modified by GUIDE v2.5 10-Aug-2012 13:11:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LiTrack_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @LiTrack_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before LiTrack_GUI is made visible.
function LiTrack_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LiTrack_GUI (see VARARGIN)
handles.output = hObject;
handles.inp_struc.Ne		= 1E10*str2double(get(handles.Nelectrons,'String'));
handles.inp_struc.E0		= str2double(get(handles.Energy0,'String'));
handles.inp_struc.z0_bar	= 1E-3*str2double(get(handles.Z0BAR,'String'));
handles.inp_struc.d0_bar	= 1E-2*str2double(get(handles.d0BAR,'String'));
handles.inp_struc.splots	= get(handles.splots,'Value');
handles.inp_struc.Nbin		= round(str2double(get(handles.NBIN,'String')));
handles.inp_struc.comment	= get(handles.comment,'String');
handles.inp_struc.contourf  = get(handles.contour,'Value');
handles.inp_struc.gzfit		= get(handles.GAUSSZFIT,'Value');
handles.inp_struc.gdfit		= get(handles.GAUSSEFIT,'Value');
handles.inp_struc.plot_frac = str2double(get(handles.PLOTFRAC,'String'));
handles.inp_struc.Int		= get(handles.Internal,'Value');
handles.inp_struc.asym		= str2double(get(handles.ASYM,'String'));
handles.inp_struc.sigz0		= 1E-3*str2double(get(handles.SIGZ0,'String'));
handles.inp_struc.sigd0		= 1E-2*str2double(get(handles.SIGE0,'String'));
handles.inp_struc.Nesim		= round(str2double(get(handles.NESIM,'String')));
handles.inp_struc.sz_scale	= str2double(get(handles.SZSCALE,'String'));
handles.inp_struc.nsamp		= round(str2double(get(handles.NSAMP,'String')));
handles.inp_struc.save_fn	= get(handles.savename,'String');
handles.codesc = get(handles.popupmenu1,'String');		% all possible codes in 1st row of LiTrack_GUI.fig file
for j = 1:length(handles.codesc)
  handles.codes(j)=str2int(handles.codesc{j});	% convert cells to integer array
end
handles.inp_struc.beamline = cell(25, 6);
handles.inp_struc.beamline(:) = {0};
for j = 1:25
  set(handles.(sprintf('radiobutton%i', j)), 'Value', 0) 
  handles.inp_struc.p(j) = 0;
  pop = handles.(sprintf('popupmenu%i', j));
  contents = get(pop, 'String');
  handles.inp_struc.beamline{j, 1} = sign(0.5-handles.inp_struc.p(j))*str2double(contents{get(pop,'Value')});
  for n = 1:5
    handles.inp_struc.beamline{j, n} = str2double(get(handles.(sprintf('edit%i', 5*(j-1)+n)), 'String'));
  end
  enable_disable_beamline(j, handles.inp_struc.beamline{j, 1}, handles)
end
set(handles.radiobutton1,'Value',1);			% set first plot radiobutton initially ON (better initial demo)
handles.inp_struc.p(1) = 1;
handles.inp_struc.beamline{1, 1} = sign(0.5-handles.inp_struc.p(1))*str2double(contents{get(handles.popupmenu1,'Value')});
if nargin == 3,
  wake_dir = pwd;
  file_dir = pwd;
  save_dir = pwd;
elseif nargin > 4
  if strcmpi(varargin{1},'dir')
    if exist(varargin{2},'dir')
      wake_dir = varargin{2};
      file_dir = varargin{3};
      save_dir = varargin{4};
    else
      errordlg('Input argument must be a valid directory','Input Argument Error!')
      return
    end
  else
    errordlg('Unrecognized input argument','Input Argument Error!');
    return;
  end
end
handles.wake_dir = wake_dir;
handles.file_dir = file_dir;
handles.save_dir = save_dir;
wake_fn = load_wakelistbox(wake_dir,handles);
% now convert wake_fn from cell structure to simple ASCII array of point-charge wakefield functions
N = length(wake_fn);
for j = 1:N
  x = wake_fn{j};
  n(j) = length(x);
end
nmax = max(n);
for j = 1:N
  wake_fn_str(j,:) = blanks(nmax);
  x = wake_fn{j};
  n = length(x);
  wake_fn_str(j,1:n) = x(1:n);
end
handles.wake_fn = wake_fn_str;						% load ASCII array into input structure for sending to LiTrack
handles.N_wake_files = length(wake_fn_str(:,1));	% count how many wakefield files available in the directory
set(handles.InternalPanel,'Visible','on')			% always start up in Internal-particle source mode
set(handles.FilePanel,'Visible','off')
contents = get(handles.GUM,'String');
x = contents{get(handles.GUM,'Value')};
handles.inp_struc.inp = x(1);
handles.inp_struc.GUM_pntr = get(handles.GUM,'Value');
load_savelistbox(save_dir,handles)
guidata(hObject, handles);
x = handles;
save LiTrack_GUI.mat x

% Write new strings to popups
raw = {'Nothing', 'Dump', 'Compressor', 'Chicane', 'Linac', 'Linac', 'E-fdbk', ...
    'RW-wake', 'Dechirper', 'CSR', 'Add ESprd', 'Auto Ecut', 'E-cut', 'con-N-Ecut', ...
    'Ntch-col', 'Abs-Ecut', 'Z-cut', 'con-N-zcut', 't-modul', 'E-modul', 'terminate'};

for i = 1:25
    set(handles.(sprintf('popupmenu%i', i)), 'string', raw)
end

% UIWAIT makes LiTrack_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = LiTrack_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% handles    structure with handles and user data (see GUIDATA)
varargout{1} = handles.output;

% --- Executes on button press in clear.
function clear_Callback(hObject, eventdata, handles)
codesc = get(handles.popupmenu1,'String');     % all possible codes in 1st row of LiTrack_GUI.fig file
length(codesc);
for j = 1:25
  cmnd = ['set(handles.popupmenu' int2str(j) ',''Value'',' int2str(length(codesc)) ');'];  % set popupmenu-j to 99
  eval(cmnd)
  cmnd = ['set(handles.radiobutton' int2str(j) ',''Value'',' '0' ');'];  % set plot button-j off
  eval(cmnd)
  for k = 1:5
    cmnd = ['set(handles.edit' int2str((j-1)*5 + k) ',''String'',' '0' ');'];
    eval(cmnd)
  end
  cmnd = ['contents = get(handles.popupmenu' int2str(j) ',''String'');']; % read full popupmenuj ('1', '2', ..., '99')
  eval(cmnd)
  cmnd = ['handles.inp_struc.beamline(' int2str(j) ',1) = sign(0.5-handles.inp_struc.p(' int2str(j) '))*abs(str2double(contents{get(handles.popupmenu' int2str(j) ',''Value'')}));']; % set beamline matrix col-1
  eval(cmnd);
end
set(handles.comment,'String',' ')
set(handles.savename,'String',' ')
set(handles.MSGBOX,'String','Data matrix cleared')
drawnow
guidata(handles.figure1,handles)


% --- Executes on button press in TRACK.
function TRACK_Callback(hObject, eventdata, handles)
run_ok = 1;
if handles.inp_struc.Int==0					% if need external zd-file...
  if exist(handles.inp_struc.zd_file)~=2	% if external zd-file pointed at does not exist...
    disp('error')
    warndlg(['Particle Input File ' handles.inp_struc.zd_file ' does not exist'],'No Such File')
    run_ok = 0;
  end
end
for j = 1:25
  cod = abs(handles.inp_struc.beamline{j, 1});
  if cod==99
    break
  elseif cod ==10 || cod ==11
	x = handles.inp_struc.beamline{j, 5};
	if isnumeric(x) && (x > handles.N_wake_files)
	  warndlg(['''WakeON'' pointer ''' int2str(x) ''' on line #' int2str(j) ' is too large for number of available wakefield files (' int2str(handles.N_wake_files) ') - try again.'],'No Such Wakefield')
      run_ok = 0;
	  break
	end
  end
end
if run_ok
  set(handles.MSGBOX,'String','Tracking started...')
  drawnow
  LiTrack(0,0,0,0,0,0,handles.inp_struc,handles.wake_fn);
  set(handles.MSGBOX,'String','Tracking finished')
  drawnow
end

function wake_fn = load_wakelistbox(dir_path,handles)
dir_struct = dir(dir_path);
[sorted_names,sorted_index] = sortrows({dir_struct.name}');
handles.wake_is_dir = [dir_struct.isdir];
k = 0;
for j = 1:length(handles.wake_is_dir)
  if handles.wake_is_dir(j)==0
    k = k + 1;
    if k >9
      wake_fnl{k} = [int2str(k) '. '  sorted_names{j}];
    else
      wake_fnl{k} = [int2str(k) '.  ' sorted_names{j}];
    end
	wake_fn{k} = sorted_names{j};
  end
end
guidata(handles.figure1,handles)
set(handles.wakelistbox,'String',wake_fnl,'Value',1)
set(handles.dirtext,'String',dir_path)


function sorted_names = load_filelistbox(dir_path,handles)
dir_struct = dir(dir_path);
[sorted_names,sorted_index] = sortrows({dir_struct.name}');
handles.file_names = sorted_names;
handles.is_dir = [dir_struct.isdir];
handles.sorted_index = [sorted_index];
guidata(handles.figure1,handles);
set(handles.filelistbox,'String',handles.file_names,'Value',1)
set(handles.dirtextfile,'String',dir_path)


function load_savelistbox(dir_path,handles)
dir_struct = dir(dir_path);
[sorted_names,sorted_index] = sortrows({dir_struct.name}');
handles.save_names = sorted_names;
handles.is_dir = [dir_struct.isdir];
handles.sorted_index = [sorted_index];
guidata(handles.figure1,handles)
set(handles.savelistbox,'String',handles.save_names,'Value',1)
set(handles.dirsave,'String',dir_path)


function enable_disable_beamline(row,code,handles)
codes = [1 2 6 7 10 11 13 15 16 17 22 25 26 27 28 29 36 37 44 45 99];	% must match possible codes in LiTrack_GUI.fig file (beamline row-1)
nstrt = [1 1 5 4  6  6  6  6  6  4  2  2  3  2  3  3  3  2  3  3  1];	% number of parameters used per code (1 to 6)
if length(handles.codes)~=length(codes)
  errordlg('Function codes on panel do not match available code options in source - call P. Emma','Code Error!')
end
if length(handles.codes)~=length(nstrt)
  errordlg('Function codes on panel do not match code parameter array in source - call P. Emma','Code Error!')
end
if std(codes-handles.codes)~=0
  errordlg('Function codes on panel do not align with available code options in source - call P. Emma','Code Error!')
end
i = find(abs(code)==codes);
if length(i)==1
  N = nstrt(i);
else			% if code number not found...
  N = 6;		% don't disable any beamline entries
end
for j = N:5		% disable all entries not used
  n = j + (row-1)*5;
  cmnd = ['set(handles.edit' int2str(n) ',''Enable'',''off'');'];
  eval(cmnd)
end
for j = 1:(N-1)	% re-enable all used entries
  n = j + (row-1)*5;
  cmnd = ['set(handles.edit' int2str(n) ',''Enable'',''on'');'];
  eval(cmnd)
end
guidata(handles.figure1,handles)


function update_blegend(x,handles)
    x = abs(x);

switch x
  case 1
    str = '1: Do nothing but generate a plot (if "plot" is switched on)';
  case 2
    str = '2: Dump 2-col ASCII file: LiTrack_zd_output.dat [z(mm) dE/E(%)]';
  case 6
    str = '6:Compressor  R56/m  T566/m  Enom/GeV U5666/m';
  case 7
    str = '7:Chicane   R56/m   Enom/GeV dR56/R56';
  case 10
    str = '10:Linac   Etot/GeV phi/deg lambda/m  wakeON    L/m';
  case 11
    str = '11:Linac   dEacc/GeV phi/deg lambda/m wakeON    L/m';
  case 13
    str = '13:E-fdbk E-goal/GV Eacc/GV phi1/deg phi2/deg lambda/m';
  case 15
    str = '15:RW-wake radius/m   L/m  cond(Ohm-m) tau/s 0=cyl,1=r';
  case 16
    str = '16:Dechirp radius/m   L/m    per/gap depth/m 0=cyl,1=r';
  case 17
    str = '17:CSR       L/m   angle/rad Nbends';
  case 22
    str = '22:Add Esprd sigE/E';
  case 25
    str = '25:AutoEcut dE/E-wdth';
  case 26
    str = '26:E-cut  dE/E(min) dE/E(max)';
  case 27
    str = '27:con-N-Ecut dN/N';
  case 28
    str = '28:Ntch-col min-dE/E max-dE/E';
  case 29
    str = '29:Abs-Ecut E1/GeV   E2/GeV';
  case 36
    str = '36:Z-cut    min-Z/m  max-Z/m';
  case 37
    str = '37:con-N-zcut dN/N';
  case 44
    str = '44:t-modul rel-Amp  lambda/m';
  case 45
    str = '45:E-modul rel-Amp  lambda/m';
  case 99
    str = '99: (terminate tracking)';
  otherwise
    str = [num2str(x) ': unknown LiTrack code number'];
end
set(handles.blegend,'String',str, 'FontName', 'MS Sans Serif')


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit21_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit25_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popupmenu6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit26_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit27_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit28_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit29_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit30_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popupmenu7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function edit31_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit32_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit33_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit34_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit35_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popupmenu8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit36_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit37_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit38_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function edit39_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit40_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popupmenu9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit41_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit42_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit43_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit44_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function edit45_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popupmenu10_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function edit46_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit47_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function edit48_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function edit49_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function edit50_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popupmenu11_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function edit51_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function edit52_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit53_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit54_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit55_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popupmenu12_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit56_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit57_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit58_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit59_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit60_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popupmenu13_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit61_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit62_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit63_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit64_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit65_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popupmenu14_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit66_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit67_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit68_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit69_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit70_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popupmenu15_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit71_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit72_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit73_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit74_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit75_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popupmenu16_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit76_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit77_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit78_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit79_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit80_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popupmenu17_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit81_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit82_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit83_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit84_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit85_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popupmenu18_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit86_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit87_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit88_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit89_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit90_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popupmenu19_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit91_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit92_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit93_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit94_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit95_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popupmenu20_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit96_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit97_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit98_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit99_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit100_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popupmenu21_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit101_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit102_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit103_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit104_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit105_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function popupmenu22_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit106_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit107_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit108_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit109_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit110_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popupmenu23_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit111_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit112_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit113_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit114_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit115_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popupmenu24_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit116_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit117_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit118_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit119_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit120_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popupmenu25_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit121_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit122_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit123_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit124_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit125_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Nelectrons_Callback(hObject, eventdata, handles)
handles.inp_struc.Ne = 1E10*str2double(get(hObject,'String'));
if isnan(handles.inp_struc.Ne)
  set(hObject, 'String', '0');
  errordlg('Input must be a number','Error');
elseif handles.inp_struc.Ne < 0
  set(hObject, 'String', '0');
  errordlg('Input must be >=0','Error');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Nelectrons_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Energy0_Callback(hObject, eventdata, handles)
handles.inp_struc.E0 = str2double(get(hObject,'String'));
if isnan(handles.inp_struc.E0)
  set(hObject, 'String', '1');
  errordlg('Input must be a number','Error');
elseif handles.inp_struc.E0 <= 0
  set(hObject, 'String', '1');
  errordlg('Input must be >0','Error');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Energy0_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Z0BAR_Callback(hObject, eventdata, handles)
handles.inp_struc.z0_bar = 1E-3*str2double(get(hObject,'String'));
if isnan(handles.inp_struc.z0_bar)
  set(hObject, 'String', '0');
  errordlg('Input must be a number','Error');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Z0BAR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function d0BAR_Callback(hObject, eventdata, handles)
handles.inp_struc.d0_bar = 1E-2*str2double(get(hObject,'String'));
if isnan(handles.inp_struc.d0_bar)
  set(hObject, 'String', '0');
  errordlg('Input must be a number','Error');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function d0BAR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in splots.
function splots_Callback(hObject, eventdata, handles)
handles.inp_struc.splots = get(hObject,'Value');
guidata(hObject, handles);



function NBIN_Callback(hObject, eventdata, handles)
handles.inp_struc.Nbin = round(str2double(get(hObject,'String')));
if isnan(handles.inp_struc.Nbin)
  set(hObject, 'String', '100');
  errordlg('Input must be a number','Error');
elseif handles.inp_struc.Nbin < 1
  set(hObject, 'String', '100');
  errordlg('Input must be >0','Error');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function NBIN_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in wakelistbox.
function wakelistbox_Callback(hObject, eventdata, handles)
set(handles.MSGBOX,'String',['This does nothing - list is simple pointer index to wake files'])


% --- Executes during object creation, after setting all properties.
function wakelistbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function comment_Callback(hObject, eventdata, handles)
handles.inp_struc.comment = get(hObject,'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function comment_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in GAUSSZFIT.
function GAUSSZFIT_Callback(hObject, eventdata, handles)
handles.inp_struc.gzfit = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in GAUSSEFIT.
function GAUSSEFIT_Callback(hObject, eventdata, handles)
handles.inp_struc.gdfit = get(hObject,'Value');
guidata(hObject, handles);



function PLOTFRAC_Callback(hObject, eventdata, handles)
handles.inp_struc.plot_frac = str2double(get(hObject,'String'));
if isnan(handles.inp_struc.plot_frac)
  set(hObject, 'String', '0.1');
  errordlg('Input must be a number','Error');
elseif (handles.inp_struc.plot_frac>1) || (handles.inp_struc.plot_frac<0.00001)
  set(hObject, 'String', '0.1');
  errordlg('Input must be between 0.00001 and 1','Error');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function PLOTFRAC_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in Internal.
function Internal_Callback(hObject, eventdata, handles)
set(handles.Internal,'Value',1)
set(handles.External,'Value',0)
set(handles.InternalPanel,'Visible','on')
set(handles.FilePanel,'Visible','off')
handles.inp_struc.Int = 1;
handles.inp_struc.GUM_pntr = get(handles.GUM,'Value');
contents = get(handles.GUM,'String');
x = contents{get(handles.GUM,'Value')};
handles.inp_struc.inp = x(1);
handles.inp_struc.sigz0 = 1E-3*str2double(get(handles.SIGZ0,'String'));
handles.inp_struc.sigd0 = 1E-2*str2double(get(handles.SIGE0,'String'));
handles.inp_struc.Nesim = round(str2double(get(handles.NESIM,'String')));
handles.inp_struc.asym  = str2double(get(handles.ASYM,'String'));
guidata(hObject, handles);


% --- Executes on button press in External.
function External_Callback(hObject, eventdata, handles)
set(handles.Internal,'Value',0)
set(handles.External,'Value',1)
set(handles.InternalPanel,'Visible','off')
set(handles.FilePanel,'Visible','on')
handles.inp_struc.Int = 0;
file_names = load_filelistbox(handles.file_dir,handles);
set(handles.filelistbox,'Value',3)					% set zd-file as 1st real file in list
handles.inp_struc.zd_file_index = get(handles.filelistbox,'Value');
file_list = get(handles.filelistbox,'String');	
filename = file_list{handles.inp_struc.zd_file_index};
[path,name,ext] = fileparts(filename);
handles.inp_struc.zd_file = [name ext];
handles.inp_struc.inp = [name ext];
handles.inp_struc.sz_scale = str2double(get(handles.SZSCALE,'String'));
handles.inp_struc.nsamp = str2double(get(handles.NSAMP,'String'));
guidata(hObject, handles);



function SIGZ0_Callback(hObject, eventdata, handles)
handles.inp_struc.sigz0 = 1E-3*str2double(get(hObject,'String'));
if isnan(handles.inp_struc.sigz0)
  set(hObject, 'String', '0.830');
  errordlg('Input must be a number','Error');
elseif handles.inp_struc.sigz0 <= 0
  set(hObject, 'String', '0.830');
  errordlg('Input must be > 0','Error');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function SIGZ0_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SIGE0_Callback(hObject, eventdata, handles)
handles.inp_struc.sigd0 = 1E-2*str2double(get(hObject,'String'));
if isnan(handles.inp_struc.sigd0)
  set(hObject, 'String', '0.05');
  errordlg('Input must be a number','Error');
elseif handles.inp_struc.sigd0 <= 0
  set(hObject, 'String', '0.05');
  errordlg('Input must be > 0','Error');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function SIGE0_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NESIM_Callback(hObject, eventdata, handles)
handles.inp_struc.Nesim = round(str2double(get(hObject,'String')));
if isnan(handles.inp_struc.Nesim)
  set(hObject, 'String', '100000');
  errordlg('Input must be a number','Error');
elseif (handles.inp_struc.Nesim>2500000) || (handles.inp_struc.Nesim<100)
  set(hObject, 'String', '100000');
  errordlg('Input must be between 100 and 2500000','Error');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function NESIM_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ASYM_Callback(hObject, eventdata, handles)
handles.inp_struc.asym = str2double(get(hObject,'String'));
if isnan(handles.inp_struc.asym)
  set(hObject, 'String', '0');
  errordlg('Input must be a number','Error');
elseif (handles.inp_struc.asym>=1) || (handles.inp_struc.asym<=-1)
  set(hObject, 'String', '0');
  errordlg('Input must be: -1 < asym < 1','Error');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function ASYM_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NSAMP_Callback(hObject, eventdata, handles)
handles.inp_struc.nsamp = round(str2double(get(hObject,'String')));
if isnan(handles.inp_struc.nsamp)
  set(hObject, 'String', '1');
  errordlg('Input must be a number','Error');
elseif (handles.inp_struc.nsamp>100) || (handles.inp_struc.nsamp<1)
  set(hObject, 'String', '1');
  errordlg('Input must be between 1 and 100','Error');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function NSAMP_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SZSCALE_Callback(hObject, eventdata, handles)
handles.inp_struc.sz_scale = str2double(get(hObject,'String'));
if isnan(handles.inp_struc.sz_scale)
  set(hObject, 'String', '1');
  errordlg('Input must be a number','Error');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function SZSCALE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in filelistbox.
function filelistbox_Callback(hObject, eventdata, handles)
if strcmp(get(handles.figure1,'SelectionType'),'normal')
  handles.inp_struc.zd_file_index = get(handles.filelistbox,'Value');
  file_list = get(handles.filelistbox,'String');	
  filename = file_list{handles.inp_struc.zd_file_index};
  [path,name,ext] = fileparts(filename);
  handles.inp_struc.zd_file = [name ext];
  handles.inp_struc.inp = [name ext];
  set(handles.MSGBOX,'String',['Input beam selected: ' name ext])
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function filelistbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in savelistbox.
function savelistbox_Callback(hObject, eventdata, handles)
get(handles.figure1,'SelectionType');
if strcmp(get(handles.figure1,'SelectionType'),'open')
  index_selected = get(handles.savelistbox,'Value');
  file_list = get(handles.savelistbox,'String');
  filename = file_list{index_selected};
  [path,name,ext] = fileparts(filename);
  switch ext
  case '.mat'
    raw = load([handles.save_dir filesep name ext]);
    inp_struc = raw.inp_struc;
    set(handles.MSGBOX,'String',['Loaded from: ' name ext])
    
    % change old format matrix to new cell style
    if ~iscell(inp_struc.beamline)
        inp_struc.beamline = num2cell(inp_struc.beamline);
    end
    
    handles.inp_struc = inp_struc;
    if handles.inp_struc.Int==1
	  set(handles.Internal,'Value',1)
 	  set(handles.External,'Value',0)
	  set(handles.InternalPanel,'Visible','on')
	  set(handles.FilePanel,'Visible','off')
	  set(handles.ASYM,'String',num2str(handles.inp_struc.asym))
	  set(handles.GUM,'Value',handles.inp_struc.GUM_pntr)
	  set(handles.SIGZ0,'String',num2str(handles.inp_struc.sigz0/1E-3))
	  set(handles.SIGE0,'String',num2str(handles.inp_struc.sigd0/1E-2))
	  set(handles.NESIM,'String',num2str(round(handles.inp_struc.Nesim)))
	else
	  set(handles.Internal,'Value',0)
 	  set(handles.External,'Value',1)
	  set(handles.InternalPanel,'Visible','off')
	  set(handles.FilePanel,'Visible','on')
	  set(handles.SZSCALE,'String',num2str(handles.inp_struc.sz_scale))
	  set(handles.NSAMP,'String',int2str(handles.inp_struc.nsamp))
 	  file_names = load_filelistbox(handles.file_dir,handles);
	  handles.file_names = file_names;		% can't get this array loaded in load_filelistbox ???
	  ifn = strcmp(handles.inp_struc.zd_file,handles.file_names);
	  ind = find(ifn==1);
	  if ~isempty(ind)
	    x = ind(1);
	  else
		warndlg(['File ' handles.file_dir '/' handles.inp_struc.zd_file ' does not exist'],'Particle File Missing')
		x = 1;
	  end
      set(handles.filelistbox,'Value',x);
    end
    handles.inp_struc.save_fn = [name ext];
    set(handles.savename,'String',handles.inp_struc.save_fn)
	set(handles.Nelectrons,'String',num2str(handles.inp_struc.Ne/1E10))
	set(handles.Energy0,'String',num2str(handles.inp_struc.E0))
	set(handles.Z0BAR,'String',num2str(handles.inp_struc.z0_bar/1E-3))
	set(handles.d0BAR,'String',num2str(handles.inp_struc.d0_bar/1E-2))
	set(handles.splots,'Value',handles.inp_struc.splots)
	set(handles.NBIN,'String',int2str(handles.inp_struc.Nbin))
	set(handles.comment,'String',handles.inp_struc.comment)
	set(handles.GAUSSZFIT,'Value',handles.inp_struc.gzfit)
	set(handles.GAUSSEFIT,'Value',handles.inp_struc.gdfit)
	set(handles.contour,'Value',handles.inp_struc.contourf)
	set(handles.PLOTFRAC,'String',num2str(handles.inp_struc.plot_frac))
%	update beamline array display panel, from file
	for j = 1:25
      set(handles.(sprintf('radiobutton%i', j)), 'Value', handles.inp_struc.p(j))
      set(handles.radiobutton1,'Value',0);
	  code = abs(handles.inp_struc.beamline{j, 1});
    icode = find(code==handles.codes);
	  if length(icode)~=1
	    errordlg(['Beamline file has an unavailable function code=' int2str(code)],'File Error');
    end
	  cmnd = ['set(handles.popupmenu' int2str(j) ',''Value'',' int2str(icode) ');'];
	  eval(cmnd);
	  for n = 1:5
          set(handles.(sprintf('edit%i', 5*(j-1)+n)), 'String', handles.inp_struc.beamline{j, n + 1});
	  end
      enable_disable_beamline(j, handles.inp_struc.beamline{j, 1}, handles)
	end
  otherwise
	errordlg(lasterr,'File Type is not .MAT','modal')
  end
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function savelistbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SAVE.
function SAVE_Callback(hObject, eventdata, handles)
%uiwait(msgbox(['Want to save into file: ' handles.inp_struc.save_fn],'CAUTION','modal'))
inp_struc = handles.inp_struc;

%str = [handles.save_dir '/' handles.inp_struc.save_fn];
str = [handles.save_dir filesep handles.inp_struc.save_fn];
%cmnd = ['save ' str ' inp_struc'];
cmnd = ['save(''' str ''',''inp_struc'')'];
eval(cmnd)
load_savelistbox(handles.save_dir,handles)
set(handles.MSGBOX,'String',['Saved in: ' handles.inp_struc.save_fn])


function savename_Callback(hObject, eventdata, handles)
handles.inp_struc.save_fn = get(hObject,'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function savename_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in GUM.
function GUM_Callback(hObject, eventdata, handles)
% Hints: contents = get(hObject,'String') returns GUM contents as cell array
%        contents{get(hObject,'Value')} returns selected item from GUM
handles.inp_struc.GUM_pntr = get(hObject,'Value');
contents = get(hObject,'String');
x = contents{get(hObject,'Value')};
handles.inp_struc.inp = x(1);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function GUM_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in CLOSEALL.
function CLOSEALL_Callback(hObject, eventdata, handles)
close all


% --- Executes on button press in HELP.
function HELP_Callback(hObject, eventdata, handles)
helpdlg('Dream on buddy...','HELP');



function MSGBOX_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function MSGBOX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in contour.
function contour_Callback(hObject, eventdata, handles)
handles.inp_struc.contourf = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);

if strcmp('/usr/local/lcls/tools/matlab/LiTrack/LiTrack_GUI.m', which('LiTrack_GUI'))
    lcaClear(); % Disconnect from Channel Access
    exit
else
    % don't exit from matlab
end


% --- Executes on key press with focus on popupmenu17 and none of its controls.
function popupmenu17_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu17 (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

function array_callback(row, col, hObject, handles)
    % Append beamline cell array with value. Tries to make a double of it.
    % in case it fails it assumes string.

    raw = get(hObject, 'String');
    val = str2double(raw);
    if isnan(val)
        val = raw;
    end
    
    handles.inp_struc.beamline{row, col + 1} = val;
    guidata(hObject, handles);
    update_blegend(handles.inp_struc.beamline{row, 1}, handles)

function radio_callback(ind, hObject, handles)
    handles.inp_struc.p(ind) = get(handles.(sprintf('radiobutton%i', ind)), 'Value');
    handles.inp_struc.beamline{ind, 1} = sign(0.5-handles.inp_struc.p(ind)) * abs(handles.inp_struc.beamline{3, 1});
    update_blegend(handles.inp_struc.beamline{ind, 1}, handles)
    guidata(hObject, handles);  
    
function popup_callback(ind, hObject, handles)
    val_ind = get(hObject, 'Value');
    VAL = [1, 2, 6, 7, 10, 11, 13, 15, 16, 17, 22, 25, 26, 27, 28, 29, 36, 37, 44, 45, 99];
    val = VAL(val_ind);
    disp(val)
    handles.inp_struc.beamline{ind, 1} = sign(0.5-handles.inp_struc.p(ind)) * abs(val);
    update_blegend(handles.inp_struc.beamline{ind, 1}, handles)
    enable_disable_beamline(ind, handles.inp_struc.beamline{ind, 1}, handles)
    guidata(hObject, handles);
      
% Auto generated code for all the callbacks of the edits.
% for row = 1:25
%    for col = 1:5
%       fprintf('function edit%i_Callback(hObject, ~, handles),', col + row*5 - 5)
%       fprintf('array_callback(%i, %i, hObject, handles)\n', row, col)
%    end
% end
% Auto generated code for all the callbacks of the radiobuttons
% for i = 1:15
%    fprintf('function radiobutton%i_Callback(hObject, ~, handles),', i)
%    fprintf('radio_callback(%i, hObject, handles)\n', i)
% end
% Auto generated code for all the callbacks of the popmenu
% for i = 1:15
%    fprintf('function popupmenu%i_Callback(hObject, ~, handles),', i)
%    fprintf('popup_callback(%i, hObject, handles)\n', i)
% end


%% edit callbacks
function edit1_Callback(hObject, ~, handles),array_callback(1, 1, hObject, handles)
function edit2_Callback(hObject, ~, handles),array_callback(1, 2, hObject, handles)
function edit3_Callback(hObject, ~, handles),array_callback(1, 3, hObject, handles)
function edit4_Callback(hObject, ~, handles),array_callback(1, 4, hObject, handles)
function edit5_Callback(hObject, ~, handles),array_callback(1, 5, hObject, handles)
function edit6_Callback(hObject, ~, handles),array_callback(2, 1, hObject, handles)
function edit7_Callback(hObject, ~, handles),array_callback(2, 2, hObject, handles)
function edit8_Callback(hObject, ~, handles),array_callback(2, 3, hObject, handles)
function edit9_Callback(hObject, ~, handles),array_callback(2, 4, hObject, handles)
function edit10_Callback(hObject, ~, handles),array_callback(2, 5, hObject, handles)
function edit11_Callback(hObject, ~, handles),array_callback(3, 1, hObject, handles)
function edit12_Callback(hObject, ~, handles),array_callback(3, 2, hObject, handles)
function edit13_Callback(hObject, ~, handles),array_callback(3, 3, hObject, handles)
function edit14_Callback(hObject, ~, handles),array_callback(3, 4, hObject, handles)
function edit15_Callback(hObject, ~, handles),array_callback(3, 5, hObject, handles)
function edit16_Callback(hObject, ~, handles),array_callback(4, 1, hObject, handles)
function edit17_Callback(hObject, ~, handles),array_callback(4, 2, hObject, handles)
function edit18_Callback(hObject, ~, handles),array_callback(4, 3, hObject, handles)
function edit19_Callback(hObject, ~, handles),array_callback(4, 4, hObject, handles)
function edit20_Callback(hObject, ~, handles),array_callback(4, 5, hObject, handles)
function edit21_Callback(hObject, ~, handles),array_callback(5, 1, hObject, handles)
function edit22_Callback(hObject, ~, handles),array_callback(5, 2, hObject, handles)
function edit23_Callback(hObject, ~, handles),array_callback(5, 3, hObject, handles)
function edit24_Callback(hObject, ~, handles),array_callback(5, 4, hObject, handles)
function edit25_Callback(hObject, ~, handles),array_callback(5, 5, hObject, handles)
function edit26_Callback(hObject, ~, handles),array_callback(6, 1, hObject, handles)
function edit27_Callback(hObject, ~, handles),array_callback(6, 2, hObject, handles)
function edit28_Callback(hObject, ~, handles),array_callback(6, 3, hObject, handles)
function edit29_Callback(hObject, ~, handles),array_callback(6, 4, hObject, handles)
function edit30_Callback(hObject, ~, handles),array_callback(6, 5, hObject, handles)
function edit31_Callback(hObject, ~, handles),array_callback(7, 1, hObject, handles)
function edit32_Callback(hObject, ~, handles),array_callback(7, 2, hObject, handles)
function edit33_Callback(hObject, ~, handles),array_callback(7, 3, hObject, handles)
function edit34_Callback(hObject, ~, handles),array_callback(7, 4, hObject, handles)
function edit35_Callback(hObject, ~, handles),array_callback(7, 5, hObject, handles)
function edit36_Callback(hObject, ~, handles),array_callback(8, 1, hObject, handles)
function edit37_Callback(hObject, ~, handles),array_callback(8, 2, hObject, handles)
function edit38_Callback(hObject, ~, handles),array_callback(8, 3, hObject, handles)
function edit39_Callback(hObject, ~, handles),array_callback(8, 4, hObject, handles)
function edit40_Callback(hObject, ~, handles),array_callback(8, 5, hObject, handles)
function edit41_Callback(hObject, ~, handles),array_callback(9, 1, hObject, handles)
function edit42_Callback(hObject, ~, handles),array_callback(9, 2, hObject, handles)
function edit43_Callback(hObject, ~, handles),array_callback(9, 3, hObject, handles)
function edit44_Callback(hObject, ~, handles),array_callback(9, 4, hObject, handles)
function edit45_Callback(hObject, ~, handles),array_callback(9, 5, hObject, handles)
function edit46_Callback(hObject, ~, handles),array_callback(10, 1, hObject, handles)
function edit47_Callback(hObject, ~, handles),array_callback(10, 2, hObject, handles)
function edit48_Callback(hObject, ~, handles),array_callback(10, 3, hObject, handles)
function edit49_Callback(hObject, ~, handles),array_callback(10, 4, hObject, handles)
function edit50_Callback(hObject, ~, handles),array_callback(10, 5, hObject, handles)
function edit51_Callback(hObject, ~, handles),array_callback(11, 1, hObject, handles)
function edit52_Callback(hObject, ~, handles),array_callback(11, 2, hObject, handles)
function edit53_Callback(hObject, ~, handles),array_callback(11, 3, hObject, handles)
function edit54_Callback(hObject, ~, handles),array_callback(11, 4, hObject, handles)
function edit55_Callback(hObject, ~, handles),array_callback(11, 5, hObject, handles)
function edit56_Callback(hObject, ~, handles),array_callback(12, 1, hObject, handles)
function edit57_Callback(hObject, ~, handles),array_callback(12, 2, hObject, handles)
function edit58_Callback(hObject, ~, handles),array_callback(12, 3, hObject, handles)
function edit59_Callback(hObject, ~, handles),array_callback(12, 4, hObject, handles)
function edit60_Callback(hObject, ~, handles),array_callback(12, 5, hObject, handles)
function edit61_Callback(hObject, ~, handles),array_callback(13, 1, hObject, handles)
function edit62_Callback(hObject, ~, handles),array_callback(13, 2, hObject, handles)
function edit63_Callback(hObject, ~, handles),array_callback(13, 3, hObject, handles)
function edit64_Callback(hObject, ~, handles),array_callback(13, 4, hObject, handles)
function edit65_Callback(hObject, ~, handles),array_callback(13, 5, hObject, handles)
function edit66_Callback(hObject, ~, handles),array_callback(14, 1, hObject, handles)
function edit67_Callback(hObject, ~, handles),array_callback(14, 2, hObject, handles)
function edit68_Callback(hObject, ~, handles),array_callback(14, 3, hObject, handles)
function edit69_Callback(hObject, ~, handles),array_callback(14, 4, hObject, handles)
function edit70_Callback(hObject, ~, handles),array_callback(14, 5, hObject, handles)
function edit71_Callback(hObject, ~, handles),array_callback(15, 1, hObject, handles)
function edit72_Callback(hObject, ~, handles),array_callback(15, 2, hObject, handles)
function edit73_Callback(hObject, ~, handles),array_callback(15, 3, hObject, handles)
function edit74_Callback(hObject, ~, handles),array_callback(15, 4, hObject, handles)
function edit75_Callback(hObject, ~, handles),array_callback(15, 5, hObject, handles)
function edit76_Callback(hObject, ~, handles),array_callback(16, 1, hObject, handles)
function edit77_Callback(hObject, ~, handles),array_callback(16, 2, hObject, handles)
function edit78_Callback(hObject, ~, handles),array_callback(16, 3, hObject, handles)
function edit79_Callback(hObject, ~, handles),array_callback(16, 4, hObject, handles)
function edit80_Callback(hObject, ~, handles),array_callback(16, 5, hObject, handles)
function edit81_Callback(hObject, ~, handles),array_callback(17, 1, hObject, handles)
function edit82_Callback(hObject, ~, handles),array_callback(17, 2, hObject, handles)
function edit83_Callback(hObject, ~, handles),array_callback(17, 3, hObject, handles)
function edit84_Callback(hObject, ~, handles),array_callback(17, 4, hObject, handles)
function edit85_Callback(hObject, ~, handles),array_callback(17, 5, hObject, handles)
function edit86_Callback(hObject, ~, handles),array_callback(18, 1, hObject, handles)
function edit87_Callback(hObject, ~, handles),array_callback(18, 2, hObject, handles)
function edit88_Callback(hObject, ~, handles),array_callback(18, 3, hObject, handles)
function edit89_Callback(hObject, ~, handles),array_callback(18, 4, hObject, handles)
function edit90_Callback(hObject, ~, handles),array_callback(18, 5, hObject, handles)
function edit91_Callback(hObject, ~, handles),array_callback(19, 1, hObject, handles)
function edit92_Callback(hObject, ~, handles),array_callback(19, 2, hObject, handles)
function edit93_Callback(hObject, ~, handles),array_callback(19, 3, hObject, handles)
function edit94_Callback(hObject, ~, handles),array_callback(19, 4, hObject, handles)
function edit95_Callback(hObject, ~, handles),array_callback(19, 5, hObject, handles)
function edit96_Callback(hObject, ~, handles),array_callback(20, 1, hObject, handles)
function edit97_Callback(hObject, ~, handles),array_callback(20, 2, hObject, handles)
function edit98_Callback(hObject, ~, handles),array_callback(20, 3, hObject, handles)
function edit99_Callback(hObject, ~, handles),array_callback(20, 4, hObject, handles)
function edit100_Callback(hObject, ~, handles),array_callback(20, 5, hObject, handles)
function edit101_Callback(hObject, ~, handles),array_callback(21, 1, hObject, handles)
function edit102_Callback(hObject, ~, handles),array_callback(21, 2, hObject, handles)
function edit103_Callback(hObject, ~, handles),array_callback(21, 3, hObject, handles)
function edit104_Callback(hObject, ~, handles),array_callback(21, 4, hObject, handles)
function edit105_Callback(hObject, ~, handles),array_callback(21, 5, hObject, handles)
function edit106_Callback(hObject, ~, handles),array_callback(22, 1, hObject, handles)
function edit107_Callback(hObject, ~, handles),array_callback(22, 2, hObject, handles)
function edit108_Callback(hObject, ~, handles),array_callback(22, 3, hObject, handles)
function edit109_Callback(hObject, ~, handles),array_callback(22, 4, hObject, handles)
function edit110_Callback(hObject, ~, handles),array_callback(22, 5, hObject, handles)
function edit111_Callback(hObject, ~, handles),array_callback(23, 1, hObject, handles)
function edit112_Callback(hObject, ~, handles),array_callback(23, 2, hObject, handles)
function edit113_Callback(hObject, ~, handles),array_callback(23, 3, hObject, handles)
function edit114_Callback(hObject, ~, handles),array_callback(23, 4, hObject, handles)
function edit115_Callback(hObject, ~, handles),array_callback(23, 5, hObject, handles)
function edit116_Callback(hObject, ~, handles),array_callback(24, 1, hObject, handles)
function edit117_Callback(hObject, ~, handles),array_callback(24, 2, hObject, handles)
function edit118_Callback(hObject, ~, handles),array_callback(24, 3, hObject, handles)
function edit119_Callback(hObject, ~, handles),array_callback(24, 4, hObject, handles)
function edit120_Callback(hObject, ~, handles),array_callback(24, 5, hObject, handles)
function edit121_Callback(hObject, ~, handles),array_callback(25, 1, hObject, handles)
function edit122_Callback(hObject, ~, handles),array_callback(25, 2, hObject, handles)
function edit123_Callback(hObject, ~, handles),array_callback(25, 3, hObject, handles)
function edit124_Callback(hObject, ~, handles),array_callback(25, 4, hObject, handles)
function edit125_Callback(hObject, ~, handles),array_callback(25, 5, hObject, handles)

%% radio callbacks
function radiobutton1_Callback(hObject, ~, handles),radio_callback(1, hObject, handles)
function radiobutton2_Callback(hObject, ~, handles),radio_callback(2, hObject, handles)
function radiobutton3_Callback(hObject, ~, handles),radio_callback(3, hObject, handles)
function radiobutton4_Callback(hObject, ~, handles),radio_callback(4, hObject, handles)
function radiobutton5_Callback(hObject, ~, handles),radio_callback(5, hObject, handles)
function radiobutton6_Callback(hObject, ~, handles),radio_callback(6, hObject, handles)
function radiobutton7_Callback(hObject, ~, handles),radio_callback(7, hObject, handles)
function radiobutton8_Callback(hObject, ~, handles),radio_callback(8, hObject, handles)
function radiobutton9_Callback(hObject, ~, handles),radio_callback(9, hObject, handles)
function radiobutton10_Callback(hObject, ~, handles),radio_callback(10, hObject, handles)
function radiobutton11_Callback(hObject, ~, handles),radio_callback(11, hObject, handles)
function radiobutton12_Callback(hObject, ~, handles),radio_callback(12, hObject, handles)
function radiobutton13_Callback(hObject, ~, handles),radio_callback(13, hObject, handles)
function radiobutton14_Callback(hObject, ~, handles),radio_callback(14, hObject, handles)
function radiobutton15_Callback(hObject, ~, handles),radio_callback(15, hObject, handles)

%% popup callbacks
function popupmenu1_Callback(hObject, ~, handles),popup_callback(1, hObject, handles)
function popupmenu2_Callback(hObject, ~, handles),popup_callback(2, hObject, handles)
function popupmenu3_Callback(hObject, ~, handles),popup_callback(3, hObject, handles)
function popupmenu4_Callback(hObject, ~, handles),popup_callback(4, hObject, handles)
function popupmenu5_Callback(hObject, ~, handles),popup_callback(5, hObject, handles)
function popupmenu6_Callback(hObject, ~, handles),popup_callback(6, hObject, handles)
function popupmenu7_Callback(hObject, ~, handles),popup_callback(7, hObject, handles)
function popupmenu8_Callback(hObject, ~, handles),popup_callback(8, hObject, handles)
function popupmenu9_Callback(hObject, ~, handles),popup_callback(9, hObject, handles)
function popupmenu10_Callback(hObject, ~, handles),popup_callback(10, hObject, handles)
function popupmenu11_Callback(hObject, ~, handles),popup_callback(11, hObject, handles)
function popupmenu12_Callback(hObject, ~, handles),popup_callback(12, hObject, handles)
function popupmenu13_Callback(hObject, ~, handles),popup_callback(13, hObject, handles)
function popupmenu14_Callback(hObject, ~, handles),popup_callback(14, hObject, handles)
function popupmenu15_Callback(hObject, ~, handles),popup_callback(15, hObject, handles)
