function varargout = plotTool3(varargin)
% PLOTTOOL3 MATLAB code for plotTool3.fig
%      PLOTTOOL3, by itself, creates a new PLOTTOOL3 or raises the existing
%      singleton*.
%
%      H = PLOTTOOL3 returns the handle to a new PLOTTOOL3 or the handle to
%      the existing singleton*.
%
%      PLOTTOOL3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTTOOL3.M with the given input arguments.
%
%      PLOTTOOL3('Property','Value',...) creates a new PLOTTOOL3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plotTool3_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plotTool3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plotTool3

% Last Modified by GUIDE v2.5 31-Aug-2014 04:46:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plotTool3_OpeningFcn, ...
                   'gui_OutputFcn',  @plotTool3_OutputFcn, ...
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

% --- Executes just before plotTool3 is made visible.
function plotTool3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plotTool3 (see VARARGIN)

% Choose default command line output for plotTool3
handles.output = hObject;

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Determine initial drive
projectDir = pwd;

% Generate the list on the upper listbox which includes simulink objects
% from /Data/Results forlder
loadListUpper(projectDir,handles);

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes plotTool3 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Create the user help button on toolbarn if it was not created before 
% (i.e. check hpt value)
[X, map] = imread(fullfile(...
matlabroot,'toolbox','matlab','icons','csh_icon.gif'));
icon = ind2rgb(X,map);
uipushtool(handles.uitoolbar1,'CData',icon,...
        'TooltipString','Help',...
        'ClickedCallback',@userHelp);
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% --- Outputs from this function are returned to the command line.
function varargout = plotTool3_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%{
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    HELPING FUNCTIONS
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%}

% This function populates the upper listboxes that are located below axes1 and
% axes2, respectively.
function loadListUpper(projectPath, handles)
% cd (dir_path)
resultPath = '/Data/results/';
dirStruct = dir([projectPath, resultPath, '*.mat']);
sortedNames = sortrows({dirStruct.name}');
handles.fileNames = sortedNames;
guidata(handles.figure1, handles);

% Generate the listboxAx1
set(handles.listboxAx1, 'String', handles.fileNames,...
    'Value',1);
set(handles.projectPathAx1, 'String', projectPath);
set(handles.resultPathAx1, 'String', resultPath);

% Generate the listboxAx2
set(handles.listboxAx2,'String',handles.fileNames,...
    'Value',1);
set(handles.projectPathAx2, 'String', projectPath);
set(handles.resultPathAx2, 'String', resultPath);


% This function polupates the lower listboxes with baseworkspace variables
function loadListLowerAx1(handles)
% hObject    handle to update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

% Updates the listbox to match the current workspace
vars = evalin('base','who');
set(handles.listboxVarsAx1,'String',vars)


% This function polupates the lower listboxes with baseworkspace variables
function loadListLowerAx2(handles)
% hObject    handle to update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

% Updates the listbox to match the current workspace
vars = evalin('base','who');
set(handles.listboxVarsAx2,'String',vars)


function [var1,var2] = getVarNamesAx1(handles)
% Returns the names of the two variables to plot
list_entries = get(handles.listboxVarsAx1,'String');
index_selected = get(handles.listboxVarsAx1,'Value');
var1 = [];
var2 = [];
if length(index_selected) ~= 2
    errordlg('You must select 2 variables including axisX','Incorrect Selection','modal')
else
    var1 = list_entries{index_selected(1)};
    var2 = list_entries{index_selected(2)};
end 


function [var1,var2] = getVarNamesAx2(handles)
% Returns the names of the two variables to plot
list_entries = get(handles.listboxVarsAx2, 'String');
index_selected = get(handles.listboxVarsAx2, 'Value');
var1 = [];
var2 = [];
if length(index_selected) ~= 2
    errordlg('You must select 2 variables including axisX','Incorrect Selection','modal')
else
    var1 = list_entries{index_selected(1)};
    var2 = list_entries{index_selected(2)};
end 
    

function userHelp(varargin)
    % Create help message
    dlgname = 'About Thermal Building Application';
    txt = {'How to use the application';
        '';
        'First of all define room properties and temperatures';
        '';
        'Then define the setting:';
        '';
        'For example, let''s say you want to simulate 2 room with imperfect sensors.';
        'Then set Num of Rooms to 2 and setting to 21'};
    helpdlg(txt, dlgname);     
    

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%{
########################## 
###   AXES1 Settings   ###
##########################
%}

function projectPathAx1_Callback(hObject, eventdata, handles)
% hObject    handle to projectPathAx1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of projectPathAx1 as text
%        str2double(get(hObject,'String')) returns contents of projectPathAx1 as a double


% --- Executes during object creation, after setting all properties.
function projectPathAx1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to projectPathAx1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function resultPathAx1_Callback(hObject, eventdata, handles)
% hObject    handle to resultPathAx1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of resultPathAx1 as text
%        str2double(get(hObject,'String')) returns contents of resultPathAx1 as a double


% --- Executes during object creation, after setting all properties.
function resultPathAx1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resultPathAx1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in updateAx1.
function updateAx1_Callback(hObject, eventdata, handles)
% hObject    handle to updateAx1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Define on which axes the plot will appear. The current axes is set to axes1 
axes(handles.axes1);
% clear axes1
cla;

[x,y] = getVarNamesAx1(handles);
if isempty(x) && isempty(y)
    return
end

try
    evalin('base',['resultFig1 = plot(', x, ',', y, ', ''LineStyle'', ''-'', ''LineWidth'', 2); ', ...
        'xlabel(''Time (hour)''); set(gca, ''fontsize'', 18);']);
    
%{
    if strncmp(y, 'tempRoom', 5)
        % red is [1 0 0], green is [0 1 0], blue is [0 1 0]
        evalin('base', 'colorspec = {[1 0 0]; [0 1 0]; [0 0 1]}; ');
        evalin('base', 'set(resultFig1, {''color''}, colorspec);');
    end
%}
        
catch ex
    errordlg(...
      ex.getReport('basic'),'Error generating linear plot','modal')
end


% --- Executes on selection change in listboxAx1.
function listboxAx1_Callback(hObject, eventdata, handles)
% hObject    handle to listboxAx1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listboxAx1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxAx1

% If the user double-click a menu item, do the following
if strcmp(get(handles.figure1,'SelectionType'),'open')
    
    indexSelected = get(handles.listboxAx1,'Value');
    fileList = get(handles.listboxAx1,'String');
    
    filePath = get(handles.resultPathAx1,'String');

    % set(handles.projectPathAx1, 'String', fileList{indexSelected});
    
    % Determine the filename including the path
    filename = [filePath, '/Data/results/', fileList{indexSelected}];
    % Extract path, name, and extension info from filename
    [path, name, ext] = fileparts(filename);
    
    % Clear base workspace
    evalin('base', 'clearvars');
    % Display which result is shown
    evalin('base', ['display(''' name ''')']);
    % Load variables of the result into base workspace
    evalin('base', ['load(''' name ''')']);
    % Extrac SimOut simulink object variables into base workspace
    evalin('base', ['extractVars(''' name ''')']);
    % Populate the lower list box with above-extracted variables
    loadListLowerAx1(handles);
    
end

% --- Executes during object creation, after setting all properties.
function listboxAx1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxAx1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in updateUpperListbox1.
function updateUpperListbox1_Callback(hObject, eventdata, handles)
% hObject    handle to updateUpperListbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Determine initial drive
projectDir = pwd;

% Generate the list on the upper listbox which includes simulink objects
% from /Data/Results forlder
loadListUpper(projectDir,handles);


% --- Executes on selection change in listboxVarsAx1.
function listboxVarsAx1_Callback(hObject, eventdata, handles)
% hObject    handle to listboxVarsAx1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listboxVarsAx1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxVarsAx1


% --- Executes during object creation, after setting all properties.
function listboxVarsAx1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxVarsAx1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in updateLowerListbox1.
function updateLowerListbox1_Callback(hObject, eventdata, handles)
% hObject    handle to updateLowerListbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
loadListLowerAx1(handles);

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%{
########################## 
###   AXES2 Settings   ###
##########################
%}

function projectPathAx2_Callback(hObject, eventdata, handles)
% hObject    handle to projectPathAx2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of projectPathAx2 as text
%        str2double(get(hObject,'String')) returns contents of projectPathAx2 as a double


% --- Executes during object creation, after setting all properties.
function projectPathAx2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to projectPathAx2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function resultPathAx2_Callback(hObject, eventdata, handles)
% hObject    handle to resultPathAx2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of resultPathAx2 as text
%        str2double(get(hObject,'String')) returns contents of resultPathAx2 as a double


% --- Executes during object creation, after setting all properties.
function resultPathAx2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resultPathAx2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in updateAx2.
function updateAx2_Callback(hObject, eventdata, handles)
% hObject    handle to updateAx2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Define on which axes the plot will appear. The current axes is set to axes1 
axes(handles.axes2);
% clear axes1
cla;

[x,y] = getVarNamesAx2(handles);
if isempty(x) && isempty(y)
    return
end

try
    evalin('base',['resultFig2 = plot(', x, ',', y, ', ''LineStyle'', ''-'', ''LineWidth'', 2); ', ...
        'xlabel(''Time (hour)''); set(gca, ''fontsize'', 18);']);
    
%{
    if strncmp(y, 'tempRoom', 5)
        % red is [1 0 0], green is [0 1 0]
        evalin('base', 'colorspec = {[1 0 0]; [0 1 0]; [0 0 1]};');
        evalin('base', 'set(resultFig2, {''color''}, colorspec);');
    end
%}
        
catch ex
    errordlg(...
      ex.getReport('basic'),'Error generating linear plot','modal')
end


% --- Executes on selection change in listboxAx2.
function listboxAx2_Callback(hObject, eventdata, handles)
% hObject    handle to listboxAx2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listboxAx2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxAx2

% If the user double-click a menu item, do the following
if strcmp(get(handles.figure1,'SelectionType'),'open')
    
    indexSelected = get(handles.listboxAx2,'Value');
    fileList = get(handles.listboxAx2,'String');
    
    filePath = get(handles.resultPathAx2,'String');

    %set(handles.projectPathAx2, 'String', fileList{indexSelected});
    
    % Determine the filename including the path
    filename = [filePath, '/Data/results/', fileList{indexSelected}];
    % Extract path, name, and extension info from filename
    [path, name, ext] = fileparts(filename);
    
    % Clear base workspace
    evalin('base', 'clearvars');
    % Display which result is shown
    evalin('base', ['display(''' name ''')']);
    % Load variables of the result into base workspace
    evalin('base', ['load(''' name ''')']);
    % Extrac SimOut simulink object variables into base workspace
    evalin('base', ['extractVars(''' name ''')']);
    % Populate the lower list box with above-extracted variables
    loadListLowerAx2(handles);
    
end


% --- Executes during object creation, after setting all properties.
function listboxAx2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxAx2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in updateUpperListbox2.
function updateUpperListbox2_Callback(hObject, eventdata, handles)
% hObject    handle to updateUpperListbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Determine initial drive
projectDir = pwd;

% Generate the list on the upper listbox which includes simulink objects
% from /Data/Results forlder
loadListUpper(projectDir,handles);



% --- Executes on selection change in listboxVarsAx2.
function listboxVarsAx2_Callback(hObject, eventdata, handles)
% hObject    handle to listboxVarsAx2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listboxVarsAx2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxVarsAx2


% --- Executes during object creation, after setting all properties.
function listboxVarsAx2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxVarsAx2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in updateLowerListbox2.
function updateLowerListbox2_Callback(hObject, eventdata, handles)
% hObject    handle to updateLowerListbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
loadListLowerAx2(handles);


%{
############################## 
###   Menu Item Settings   ###
##############################
%}

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)

%{
#################################
###   Context Menu Settings   ###
#################################
%}

% --------------------------------------------------------------------
function plotAxes1_Callback(hObject, eventdata, handles)
% hObject    handle to plotAxes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function plotAxes2_Callback(hObject, eventdata, handles)
% hObject    handle to plotAxes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function plotAx1_Callback(hObject, eventdata, handles)
% hObject    handle to plotAx1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Displays contents of axes1 at larger size in a new figure

% Create a figure to receive this axes' data
axes1fig = figure;
% Copy the axes and size it to the figure
axes1copy = copyobj(handles.axes1, axes1fig);
set(axes1copy,'Units','Normalized',...
              'Position',[.05,.20,.90,.60])
          
% Assemble a title for this new figure
indexSelected = get(handles.listboxAx1,'Value');
fileList = get(handles.listboxAx1,'String');
str = ['Results for ' fileList{indexSelected}];
title(str,'Fontweight','bold')

% Save handles to new fig and axes in case
% we want to do anything else to them
handles.axes1fig = axes1fig;
handles.axes1copy = axes1copy;
guidata(hObject, handles);


% --------------------------------------------------------------------
function plotAx2_Callback(hObject, eventdata, handles)
% hObject    handle to plotAx2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Displays contents of axes2 at larger size in a new figure

% Create a figure to receive this axes' data
axes2fig = figure;
% Copy the axes and size it to the figure
axes2copy = copyobj(handles.axes2, axes2fig);
set(axes2copy,'Units','Normalized',...
              'Position',[.05,.20,.90,.60])
          
% Assemble a title for this new figure
indexSelected = get(handles.listboxAx2,'Value');
fileList = get(handles.listboxAx2,'String');
str = ['Results for ' fileList{indexSelected}];
title(str,'Fontweight','bold')

% Save handles to new fig and axes in case
%  we want to do anything else to them
handles.axes1fig = axes2fig;
handles.axes1copy = axes2copy;
guidata(hObject, handles);
