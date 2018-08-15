function varargout = one(varargin)
% ONE MATLAB code for one.fig
%      ONE, by itself, creates a new ONE or raises the existing
%      singleton*.
%
%      H = ONE returns the handle to a new ONE or the handle to
%      the existing singleton*.
%
%      ONE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ONE.M with the given input arguments.
%
%      ONE('Property','Value',...) creates a new ONE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before one_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to one_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help one

% Last Modified by GUIDE v2.5 14-Aug-2018 18:54:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @one_OpeningFcn, ...
                   'gui_OutputFcn',  @one_OutputFcn, ...
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


% --- Executes just before one is made visible.
function one_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to one (see VARARGIN)

% Choose default command line output for one
handles.output = hObject;
% handles.SP = 0;
% handles.stop = 0;
handles.readCh = [0, 1];
handles.writeCh = [0];
global board;
global time;
global stop;
global x;
global sp;
global nivel1;
global nivel2;
x = 0;
sp = 0;
nivel1 = 0;
nivel2 = 0;
stop = 0;
time = 1;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes one wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = one_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function [board] = connectBoard()
name = 'q8_usb';
identifier = '0';
board = hil_open(name,identifier);

function disconnectBoard(board)
hil_close(board);

function [ L1,L2 ] = readLevels( board,channels )
%lendo nivel atual dos tanques
levels = hil_read_analog(board,channels) * 6.25;
L1 = levels(1);
L2 = levels(2);

function writeVoltage(board,channels,voltage)
hil_write_analog(board,channels,voltage);

function [erro] = malhaFechada(sp, nivel)
erro = sp - nivel;

function [ss] = locker(volts)
if volts > 4
    ss = 4;
elseif volts < -4
    ss = -4;
else
    ss = volts;
end

function [P] = setP(e,Kp)
P = e * Kp;

function spText_Callback(hObject, eventdata, handles)
% hObject    handle to spText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spText as text
%        str2double(get(hObject,'String')) returns contents of spText as a double


% --- Executes during object creation, after setting all properties.
function spText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in sendBtn.
function sendBtn_Callback(hObject, eventdata, handles)
% hObject    handle to sendBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global board;
global stop;
global time;
global x;
global sp;
global nivel1;
global nivel2;
handles.SP = str2double(get(handles.spText,'String'));
stop = 0;
while(time < 10000 && stop == 0)
    i = time;
    sp(i) = handles.SP;
    try
        [nivel1(i),nivel2(i)] = readLevels(board,handles.readCh);
    catch
        disp('Não foi possível ler!');
    end
    
    %%%ACAO DE CONTROLE - MF
    e = malhaFechada(sp(i),nivel1(i));
    
    %P
    out = setP(e,2);
    
    %Trava
    sinal = locker(out);
    
    disp(sinal);
    writeVoltage(board,handles.writeCh,sinal);
    
    x(i) = time;
    plot(x,sp,'blue');
    plot(x,nivel1,'red');
    plot(x,nivel2,'green');grid on;
    time = time + 1;
    pause(0.01);
end
writeVoltage(board,handles.writeCh,0);


% --- Executes on button press in stopBtn.
function stopBtn_Callback(hObject, eventdata, handles)
% hObject    handle to stopBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global stop;
global time;
global x;
global sp;
global nivel1;
global nivel2;
global board;
stop = 1;
time = 1;
x = 0;
sp = 0;
nivel1 = 0;
nivel2 = 0;
writeVoltage(board,handles.writeCh,0);
cla;




% --- Executes on button press in conectBtn.
function conectBtn_Callback(hObject, eventdata, handles)
% hObject    handle to conectBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global board;
try
   board = connectBoard();
   set(handles.statusText,'String','CONNECTED!');
   set(handles.statusText,'ForegroundColor',[0, 0.5, 0]);
catch
   set(handles.statusText,'String','ERRO! NOT CONNECTED');
   set(handles.statusText,'ForegroundColor','red');
end


% --- Executes on button press in disconectBtn.
function disconectBtn_Callback(hObject, eventdata, handles)
% hObject    handle to disconectBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global board;
disconnectBoard(board);
set(handles.statusText,'String', 'NOT CONNECTED');
set(handles.statusText,'ForegroundColor','red');
