function varargout = smartBuildingGUI(varargin)
% SMARTBUILDINGGUI MATLAB code for smartBuildingGUI.fig
%      SMARTBUILDINGGUI, by itself, creates a new SMARTBUILDINGGUI or raises the existing
%      singleton*.
%
%      H = SMARTBUILDINGGUI returns the handle to a new SMARTBUILDINGGUI or the handle to
%      the existing singleton*.
%
%      SMARTBUILDINGGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SMARTBUILDINGGUI.M with the given input arguments.
%
%      SMARTBUILDINGGUI('Property','Value',...) creates a new SMARTBUILDINGGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before smartBuildingGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to smartBuildingGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help smartBuildingGUI

% Last Modified by GUIDE v2.5 01-Apr-2015 11:31:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @smartBuildingGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @smartBuildingGUI_OutputFcn, ...
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


% --- Executes just before smartBuildingGUI is made visible.
function smartBuildingGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to smartBuildingGUI (see VARARGIN)

% Choose default command line output for smartBuildingGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% hObject: Object handle, 
% handles: GUI data

% UIWAIT makes smartBuildingGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Create the user help button on toolbar if it was not created before 
% (i.e. check hpt value)
global hpt;
if ~any(hpt)
[X, map] = imread(fullfile(...
matlabroot,'toolbox','matlab','icons','csh_icon.gif'));
icon = ind2rgb(X,map);
hpt = uipushtool(handles.uitoolbar1,'CData',icon,...
        'TooltipString','Help',...
        'ClickedCallback',@userHelp);
end
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


% --- Outputs from this function are returned to the command line.
function varargout = smartBuildingGUI_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;


% STORE VARIABLES THROUGH HANDLES 
% GUIDE uses guidata to store and maintain the handles structure. In a GUIDE GUI code file, do not overwrite the handles 
% structure or your GUI will no longer work. If you need to store data other than handles for your GUI, you can add new fields 
% to the handles structure and safely place your data there.

%{
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Set System Variables through handles before Running Simulation
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%}
% (Note: You can only do that in this function)

function handles = getpara(handles)

    display('Model parameters being grabbed from GUI');
    display('getparam first statement');

    % --- Building properties ---
    % Room geometry (unit: meter)
    handles.room.number = get(handles.numRoom,'Value');
    handles.room.length = str2double(get(handles.Length,'String')); 
    handles.room.width  = str2double(get(handles.Width,'String'));     
    handles.room.height = str2double(get(handles.Height,'String'));    

    % Roof properties (unit: degree and radian)
    handles.roof.slopeDeg = 40;
    handles.roof.slopeRad = handles.roof.slopeDeg * pi / 180;

    % --- Window properties ---
    handles.window.number = str2double(get(handles.numWindow,'String'));
    handles.window.height = 1;
    handles.window.width = 1;
    % k refers to the thermal conductance of the window (unit: Joule / sec . meter . degCelcius).
    handles.window.k = 0.78*3600;   
    % In order to use hour as the time unit, we multiply k with 3600 
    % L refers to the thickness of the window (unit: meter).
    handles.window.L = 0.01;
    % heat capacity of glass window (15 Celsius)= 657 J/kg-C
    handles.window.capGlass = 657;
    % density of glass window
    handles.window.densGlass = 0;   % Not defined
    % Calculate window area
    handles.window.area = calcWindowArea(handles);
    % Calculate thermal resistance of the wall
    handles.window.thermalR = calcThermalR (handles.window.k, handles.window.L, handles.window.area);
    %handles.window.thermalC = calcWindowThermalC (handles);

    % --- Wall properties ---
    % k refers to the thermal conductance of the wall (unit: Joule / sec . meter . degCelcius).
    handles.wall.k = 0.038*3600;
    % In order to use hour as the time unit, we multiply k with 3600 
    % L refers to the thickness of the wall (unit: meter).
    handles.wall.L = 0.2;
    % heat capacity of glass wool (15 Celsius)= 820 J/kg-C
    handles.wall.capGW = 820;
    % density of glass wool
    handles.wall.densGW = 0;   % Not defined
    % Calculate wall area 
    handles.wall.area = calcWallArea(handles);
    % Calculate thermal resistance of the wall
    handles.wall.thermalR = calcThermalR (handles.wall.k, handles.wall.L, handles.wall.area);
    %handles.wall.thermalC = calcWallThermalC (handles);

    % --- Thermal Properties of the Air ---
    % heat capacity of air (0 Celsius)= 1005.4 J/kg-C
    handles.air.cap = 1005.4;
    % Air flow rate Maf = 1 kg/sec = 3600 kg/hr
    handles.air.massFlowHeater = 404;  % kg/hr
    handles.air.massFlowCooler = 404;
    % Density of air at sea level = 1.2250 kg/m^3
    handles.air.density = 1.2250;
    % calculate air mass
    handles.air.mass = calcAirMass(handles);
    % calculate thermal capacitance of air
    handles.air.thermalC = calcAirThermalC(handles);
    % Thermal Capacitance of Air flow produced by Heater
    %handles.air.flowThermalC = calcAirFlowThermalC (handles);
    
    
    % --- Thermal Properties of the room ---
    % Total thermal resistance of the building
    handles.room.totalR = totalThermalR (handles);
    % Total thermal capacitance of the building
    handles.room.totalC = totalThermalC (handles);
  
    
    % --- Temperature Data Properties ---
    % Set Point for Room1 in Fahrenheit
    handles.data.TSet1 = str2double(get(handles.Tset1,'String'));  
    % Set Point for Room1 in Fahrenheit
    handles.data.TSet2 = str2double(get(handles.Tset2,'String')); 
    % Set Point for Room1 in Fahrenheit
    handles.data.TSet3 = str2double(get(handles.Tset3,'String')); 
    % Average outdoor temperature in Fahrenheit
    handles.data.TAout = str2double(get(handles.TAout,'String'));   
    % Initial room temperature in Fahrenheit
    handles.data.TInit = str2double(get(handles.TInit,'String'));
    % The heater produces flow of air at a constant temperature that is a heater property.
    % Temperature of Heater in Fahrenheit
    handles.data.THeater = 110;  % ~40  celsius
    % The cooler produces flow of air at a constant temperature that is a cooler property.
    % Temperature of Cooler in Fahrenheit
    handles.data.TCooler = 30;  %  ~0 celsius
    % Assume the cost of electricity is $0.175 per kilowatt/hour
    % 1 kW-hr = 3.6e6 J   cost = $0.175 per 3.6e6 J
    handles.data.cost = 0.175/3.6e6;
    % Initial Indoor Temperature in Fahrenheit 
    %handles.data.TInit = 70;  
    

    % Pup up menu readings
    setting = str2double(get(handles.setting,'String'));
    stepSize = str2double(get(handles.stepSize,'String'));
    
    % Model file selection based on popup menu readings
    switch setting
        case 3000
            handles.model.name = 'thermalBuilding3000';
        case 3110
            handles.model.name = 'thermalBuilding3110';
        case 3111
            handles.model.name = 'thermalBuilding3111';
        case 3120
            handles.model.name = 'thermalBuilding3120';
        case 3121
            handles.model.name = 'thermalBuilding3121';
        case 3210
            handles.model.name = 'thermalBuilding3210';
        case 3211
            handles.model.name = 'thermalBuilding3211';
        case 3220
            handles.model.name = 'thermalBuilding3220';
        case 3221
            handles.model.name = 'thermalBuilding3221';
        case 3310
            handles.model.name = 'thermalBuilding3310';
        case 3311
            handles.model.name = 'thermalBuilding3311';    
    end

    handles.sim.setting = setting;
    handles.sim.stepSize = stepSize;
     
    %{
    % Create folder for simulation results
    name1 = datestr(clock,0);
    name2 = [name1(1:11),'-',name1(13:14),'-',name1(16:17),'-',name1(19:20)];
    handles.sim.savePath = [pwd '/Data/results/'];
    dirName = [num2str(handles.building.numRoom) '_Rm_' name2];
    handles.sim.resultPath = [handles.sim.savePath dirName '/'];
    mkdir(handles.sim.resultPath);   
    %}
    
    % Create name annex for file name that includes simulation results
    name1 = datestr(clock,0);
    name2 = [name1(1:11),'-',name1(13:14),'-',name1(16:17),'-',name1(19:20)];
    handles.sim.savePath = [pwd '/Data/results/'];
    fileName = [sprintf('SimOut%d',handles.sim.setting) '-' name2 '.mat'];
    handles.sim.fileName = fileName;
    handles.sim.filePath = [handles.sim.savePath fileName];   
    
    display('getparam last statement');
	
%{
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            HELPING FUNCTIONS
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%}    

function [area] = calcWallArea (handles)
    area = 2 * handles.room.height * (handles.room.length + handles.room.width) + ...
           2*(1/cos(handles.roof.slopeRad/2)) * handles.room.length * handles.room.width - handles.window.area;

       
function [area] = calcWindowArea (handles)
    area = handles.window.number * handles.window.height * handles.window.width;

    
function [R] = calcThermalR (k, L, area)
    R = L / (k * area);

    
function [C] = calcWindowThermalC (handles)
    C = 0;   % Not Defined

function [C] = calcWallThermalC (handles)
    C = 0;   % Not Defined
    

function [massAir] = calcAirMass (handles)
    massAir = (handles.room.length * handles.room.width * handles.room.height + ...
        tan(handles.roof.slopeRad) * handles.room.width * handles.room.length) * handles.air.density;
  
function [C] = calcAirThermalC (handles)
    C = handles.air.mass * handles.air.cap;
    
function [C] = calcAirFlowThermalC (handles)
    C = handles.air.massFlow * handles.air.cap;
    
function [totalR] = totalThermalR (handles)
    % Calculate total thermal resistance of whole building
    totalR = handles.wall.thermalR * handles.window.thermalR / (handles.wall.thermalR + handles.window.thermalR);

    
function [totalC] = totalThermalC (handles)
    % Calculate total thermal resistance of whole building
    totalC = handles.air.thermalC;
    
%{
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Set Model Workspace Variables and Start Simulation
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%}
    
function buildingSim(handles)
    display('Simulation being started');
    display('buildingSim first statement');
    display(handles.model.name);

    % Load building model to memory and transfer some of pre-defined variables
    % into Simulink model workspace to increase the simulation performance.

    load_system(handles.model.name); 
    buildingParam = get_param(handles.model.name, 'modelworkspace');
    buildingParam.DataSource = 'MAT-File';
    buildingParam.FileName = [pwd '/Data/wsVars/' handles.model.name 'WS'];
    buildingParam.assignin('THeater', handles.data.THeater);
    buildingParam.assignin('TCooler', handles.data.TCooler);
    buildingParam.assignin('Mafh', handles.air.massFlowHeater);
    buildingParam.assignin('Mafc', handles.air.massFlowCooler);
    buildingParam.assignin('Ca', handles.air.cap);
    % Tin refers to initial room temperatures
    buildingParam.assignin('TInit', handles.data.TInit);
    buildingParam.assignin('cost', handles.data.cost);
    buildingParam.assignin('Req', handles.room.totalR);
    buildingParam.assignin('Rwall', handles.wall.thermalR);
    buildingParam.assignin('Ceq', handles.room.totalC);
    buildingParam.assignin('TSet1', handles.data.TSet1);
    %buildingParam.assignin('TSet2', handles.data.TSet2);
    %buildingParam.assignin('TSet3', handles.data.TSet3);
    buildingParam.assignin('TAout', handles.data.TAout);
    buildingParam.assignin('stepSize', handles.sim.stepSize);
    % 17th char of the string model name refers to the setting
    % configuration
    if ~strcmp(handles.model.name(17), '0')
       % False-Positive Sampling Time (ST)
       buildingParam.assignin('fpST', 0.025);
       % False-Positive Probability of Zero (Pr)
       buildingParam.assignin('fpPr', 0.995);
       %buildingParam.assignin('fnST', 0);
    end
    % 16th char of the string model name refers to the room number
    if strcmp(handles.model.name(16), '2')
       buildingParam.assignin('TSet2', handles.data.TSet2);
    end
    % 16th char of the string model name refers to the room number
    if strcmp(handles.model.name(16), '3')
       buildingParam.assignin('TSet2', handles.data.TSet2);
       buildingParam.assignin('TSet3', handles.data.TSet3);
    end
    buildingParam.saveToSource;
    buildingParam.reload;

    % Since we made changes on the model, we check dirty flag and save the model.
    if strcmp(get_param(handles.model.name, 'Dirty'), 'on')
        save_system(handles.model.name, [], 'SaveModelWorkspace', true, 'OverwriteIfChangedOnDisk', true);
    end 

    % Define a simulink object through Simulink.SimulationOutput class to access simulink toWorkspace variables 
    % and relay them to base workspace variables. 
    eval(['global ' sprintf('SimOut%d',handles.sim.setting)]);
    % global Simout1;
    
    eval([sprintf('SimOut%d',handles.sim.setting) '= Simulink.SimulationOutput;']);
    %SimOut1 = Simulink.SimulationOutput;
    
    % Run simulation with some model configuration parameters
    eval([sprintf('SimOut%d',handles.sim.setting) '=' sprintf('sim(''thermalBuilding%d''', handles.sim.setting) ',''StartTime'', ''0'', ''StopTime'', ''48'');']);
        
    % The below statement is for debugging purpose
    display('buildingSim last statement');
 
    
%{
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            Save Simulation Results
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%}    
    
function saveResults(handles)
    display('Results being saved');
    display('saveResults first statement');
    % global SimoutN;
    eval(['global ' sprintf('SimOut%d',handles.sim.setting)]);
    
    %filename = ['SimOut' sprintf('Setting%d', handles.sim.setting)];
    %save([handles.sim.resultPath filename '.mat'], sprintf('SimOut%d', handles.sim.setting));
   
    save(handles.sim.filePath);
    
    display('saveResults last statement');
    
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function userHelp(varargin)
    % Create help message
    dlgname = 'About Thermal Building Application';
    txt = {'How to use the application';
        '';
        'First of all define room properties and temperatures';
        '';
        'Then define Configuration in Settings section :';
        'defining Configuration:3000 means that 3 room with perfect sensors will be simulated';
        'defining Configuration:3110 means that 3 room with sensors having single-sample-spike (positive) fault will be simulated';
        'defining Configuration:3111 means that 3 room with sensors having single-sample-spike (positive) fault and its mitigation technique will be simulated';
        'defining Configuration:3120 means that 3 room with sensors having single-sample-spike (negative) fault will be simulated';
        'defining Configuration:3121 means that 3 room with sensors having single-sample-spike (negative) fault and its mitigation technique will be simulated';
        'defining Configuration:3210 means that 3 room with sensors having spike-and-stay (positive) fault will be simulated';
        'defining Configuration:3211 means that 3 room with sensors having spike-and-stay (positive) fault and its mitigation technique will be simulated';
        'defining Configuration:3220 means that 3 room with sensors having spike-and-stay (negative) fault will be simulated';
        'defining Configuration:3221 means that 3 room with sensors having spike-and-stay (negative) fault and its mitigation technique will be simulated';
        'defining Configuration:3310 means that 3 room with sensors having stuck-at fault will be simulated';
        'defining Configuration:3311 means that 3 room with sensors having stuck-at fault and its mitigation technique will be simulated';
        '';
        'For example, let''s say you want to simulate 3 room with imperfect sensors.';
        'Then set Num of Rooms to 3 and configuration to 3000'};
    helpdlg(txt, dlgname);     
    

% --- Executes on button press in pushbutton_title.
function pushbutton_title_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_title (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% You may need to update GUI display. Then use the following command:
guidata(hObject, handles);


% -------------------------------------------------------------------------

% --- Executes on selection change in numFloor.
function numFloor_Callback(hObject, eventdata, handles)
% hObject    handle to numFloor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns numFloor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from numFloor

% You may need to update GUI display. Then use the following command:
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function numFloor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numFloor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in numRoom.
function numRoom_Callback(hObject, eventdata, handles)
% hObject    handle to numRoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns numRoom contents as cell array
%        contents{get(hObject,'Value')} returns selected item from numRoom

% You may need to update GUI display. Then use the following command:
set(handles.setting, 'String', get(handles.numRoom,'Value'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function numRoom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numRoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Length_Callback(hObject, eventdata, handles)
% hObject    handle to Length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Length as text
%        str2double(get(hObject,'String')) returns contents of Length as a double

% You may need to update GUI display. Then use the following command:
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Length_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Width_Callback(hObject, eventdata, handles)
% hObject    handle to Width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Width as text
%        str2double(get(hObject,'String')) returns contents of Width as a double

% You may need to update GUI display. Then use the following command:
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Height_Callback(hObject, eventdata, handles)
% hObject    handle to Height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Height as text
%        str2double(get(hObject,'String')) returns contents of Height as a double

% You may need to update GUI display. Then use the following command:
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Height_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function numWindow_Callback(hObject, eventdata, handles)
% hObject    handle to numWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numWindow as text
%        str2double(get(hObject,'String')) returns contents of numWindow as a double


% --- Executes during object creation, after setting all properties.
function numWindow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function setting_Callback(hObject, eventdata, handles)
% hObject    handle to setting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of setting as text
%        str2double(get(hObject,'String')) returns contents of setting as a double

% You may need to update GUI display. Then use the following command:
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function setting_CreateFcn(hObject, eventdata, handles)
% hObject    handle to setting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function stepSize_Callback(hObject, eventdata, handles)
% hObject    handle to stepSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stepSize as text
%        str2double(get(hObject,'String')) returns contents of stepSize as a double


% --- Executes during object creation, after setting all properties.
function stepSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stepSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Tset1_Callback(hObject, eventdata, handles)
% hObject    handle to Tset1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Tset1 as text
%        str2double(get(hObject,'String')) returns contents of Tset1 as a double


% --- Executes during object creation, after setting all properties.
function Tset1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Tset1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Tset2_Callback(hObject, eventdata, handles)
% hObject    handle to Tset2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Tset2 as text
%        str2double(get(hObject,'String')) returns contents of Tset2 as a double


% --- Executes during object creation, after setting all properties.
function Tset2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Tset2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Tset3_Callback(hObject, eventdata, handles)
% hObject    handle to Tset3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Tset3 as text
%        str2double(get(hObject,'String')) returns contents of Tset3 as a double


% --- Executes during object creation, after setting all properties.
function Tset3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Tset3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function TAout_Callback(hObject, eventdata, handles)
% hObject    handle to TAout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TAout as text
%        str2double(get(hObject,'String')) returns contents of TAout as a double



% --- Executes during object creation, after setting all properties.
function TAout_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TAout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in run.
function Run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% ++++++++++++++++++++++++++++++++++++++++++++++++++
% Get variables from GU and Create necessary variables to simulate the thermal model of the smart buildingI
handles = getpara(handles);
% Load Room direction / location data
evalin('base', 'load(''D:\PROGRAMMING-IDEs\MATLAB\1WORKSPACE\1_Projects\Smart-Building\WIN\Data\east_data.mat'')');
evalin('base', 'load(''D:\PROGRAMMING-IDEs\MATLAB\1WORKSPACE\1_Projects\Smart-Building\WIN\Data\west_data.mat'')');
% Simulate the termal model of the building
buildingSim(handles);
% Save Simulation results to the folder created above
saveResults(handles);
% Update GUI
guidata(hObject,handles);


% --- Executes on button press in mupad.
function Mupad_Callback(hObject, eventdata, handles)
% hObject    handle to mupad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
open('thermodynamics_eqns.mn');
% You may need to update GUI display. Then use the following command:
guidata(hObject, handles);

% -----------------------------------------------------------------------------

% --- Executes on selection change in figurePath.
function figurePath_Callback(hObject, eventdata, handles)
% hObject    handle to figurePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns figurePath contents as cell array
%        contents{get(hObject,'Value')} returns selected item from figurePath


% --- Executes during object creation, after setting all properties.
function figurePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figurePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in newGUIfigure.
function newGUIfigure_Callback(hObject, eventdata, handles)
% hObject    handle to newGUIfigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guide();

% --- Executes on button press in selectGUIfigure.
function selectGUIfigure_Callback(hObject, eventdata, handles)
% hObject    handle to selectGUIfigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file path] = uigetfile({'*.fig'},'Select a Figure');
if (file~=0)
    [pathName, fileName, fileExt] = fileparts(file);
    pathStr=get(handles.figurePath,'String');  % String vs Value, drawing analogy with enumeration in C
    if(isempty(pathStr))
        pathStr={fileName};
    else
        pathStr={pathStr{:},fileName};
    end
    set(handles.figurePath,'String',pathStr);
    set(handles.figurePath,'Value',size(pathStr,2));
end

% --- Executes on button press in editGUIfigure.
function editGUIfigure_Callback(hObject, eventdata, handles)
% hObject    handle to editGUIfigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pathStr=get(handles.figurePath,'String');  % String vs Value, drawing analogy with enumeration in C
if(isempty(pathStr))
    errordlg({'You must select a GUI figure',...
        'before editing it'},'GUI Figure Selection Error!')
    return
else
    val=get(handles.figurePath,'Value');
    str=get(handles.figurePath,'String');
    guide([pwd,'/',char(str(val)),'.fig']);
end

% -----------------------------------------------------------------------------

% --- Executes on selection change in mfilePath.
function mfilePath_Callback(hObject, eventdata, handles)
% hObject    handle to mfilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns mfilePath contents as cell array
%        contents{get(hObject,'Value')} returns selected item from mfilePath

% --- Executes during object creation, after setting all properties.
function mfilePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mfilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in newGUImfile.
function newGUImfile_Callback(hObject, eventdata, handles)
% hObject    handle to newGUImfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
edit();

% --- Executes on button press in selectGUImfile.
function selectGUImfile_Callback(hObject, eventdata, handles)
% hObject    handle to selectGUImfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file path] = uigetfile({'*.m'},'Select a File');
if (file~=0)
    [pathName, fileName, fileExt] = fileparts(file);
    pathStr=get(handles.mfilePath,'String');  % String vs Value, drawing analogy with enumeration in C
    if(isempty(pathStr))
        pathStr={fileName};
    else
        pathStr={pathStr{:},fileName};
    end
    set(handles.mfilePath,'String',pathStr);
    set(handles.mfilePath,'Value',size(pathStr,2));
end

% --- Executes on button press in editGUImfile.
function editGUImfile_Callback(hObject, eventdata, handles)
% hObject    handle to editGUImfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pathStr=get(handles.mfilePath,'String');  % String vs Value, drawing analogy with enumeration in C
if(isempty(pathStr))
    errordlg({'You must select a file',...
        'before editing it'},'File Selection Error!')
    return
else
    val=get(handles.mfilePath,'Value');
    str=get(handles.mfilePath,'String');
    edit([pwd,'\',char(str(val)),'.m']);
end


% --- Executes on button press in refreshGUI.
function refreshGUI_Callback(hObject, eventdata, handles)
% hObject    handle to refreshGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
drawnow();
smartBuildingGUI;


% --- Executes on button press in restartGUI.
function restartGUI_Callback(hObject, eventdata, handles)
% hObject    handle to restartGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% hpt is the uipushtool object
global hpt;
hpt = 0;
close(gcbf);
smartBuildingGUI;

% -----------------------------------------------------------------------------


% --- Executes on button press in pushbuttonTitle.
function pushbuttonTitle_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonTitle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in plotTool.
function plotTool_Callback(hObject, eventdata, handles)
% hObject    handle to plotTool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
plotTool3;
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
% Figure windows have a CloseRequestFcn property, which defines a callback function 
% that will run when the window is closed (before deleting the window). 

% hpt is the uipushtool object
global hpt;
hpt = 0;


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



function TInit_Callback(hObject, eventdata, handles)
% hObject    handle to TInit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TInit as text
%        str2double(get(hObject,'String')) returns contents of TInit as a double


% --- Executes during object creation, after setting all properties.
function TInit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TInit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
