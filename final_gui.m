function varargout = final_gui(varargin)
% FINAL_GUI M-file for final_gui.fig
%      FINAL_GUI, by itself, creates a new FINAL_GUI or raises the existing
%      singleton*.
%
%      H = FINAL_GUI returns the handle to a new FINAL_GUI or the handle to
%      the existing singleton*.
%
%      FINAL_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FINAL_GUI.M with the given input arguments.
%
%      FINAL_GUI('Property','Value',...) creates a new FINAL_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before final_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to final_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help final_gui

% Last Modified by GUIDE v2.5 15-Jun-2016 20:25:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @final_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @final_gui_OutputFcn, ...
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


% --- Executes just before final_gui is made visible.
function final_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to final_gui (see VARARGIN)

% Choose default command line output for final_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes final_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = final_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file path]=uigetfile('*.*');
I=imread(file); %reads selected image
I=imresize(I,[128 128]);%resize image into 256*256
axes(handles.axes1)
imshow(I);title('Original Image','FontName','cambria','FontSize',12);drawnow;
handles.I=I;
guidata(hObject, handles);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.figure1, 'pointer', 'watch')
drawnow;

I=handles.I;
arn=I;
tic;%record time

[row col plane]=size(I);

if (plane==1)
%% for grayscale image
%% 2.Quadtree Decomposition
s=qtdecomp(I,0.2,[2 64]);%divides image using quadtree decomposition of
                         %threshold .2 and min dim =2 ,max dim =64
[i,j,blksz] = find(s); %record x and y coordinates and blocksize
blkcount=length(i);  %no of total blocks
si=10.1;
global si
avg=zeros(blkcount,1);%record mean values
for k=1:blkcount 
    avg(k)=mean2(I(i(k):i(k)+blksz(k)-1,j(k):j(k)+blksz(k)-1));%find mean 
                                                               %value
end 
avg=uint8(avg);
axes(handles.axes2)
imshow((full(s)));title('Quadtree Decompositioin','FontName','cambria','FontSize',12);drawnow;
%% 3.Huffman Encoding
%prepare data
i(end+1)=0;j(end+1)=0;blksz(end+1)=0;%set boundary elements
data=[i;j;blksz;avg];%record total information
data=single(data); %convert to single
symbols= unique(data);% Distinct symbols that data source can produce
counts = hist(data(:), symbols);%find counts of symblos in given data
p = counts./ sum(counts);% Probability distribution
sp=round(p*1000);% scaled probabilities
dict = huffmandict(symbols,p'); % Create dictionary.
comp = huffmanenco(data,dict);% Encode the data.

%% 4.Compressed
%Time taken for compression
t=toc;
fprintf('Time taken for compression = %f seconds\n',t);
set(handles.edit1,'string',t)
%compression ratio
bits_in_original=8*256*256;
bits_in_final=length(comp)+8*length(symbols)+8*length(sp);
%Compression Ratio = total number of bits in original file, divided by 
%number of bits in final file
CR= bits_in_original/bits_in_final;
fprintf('compression ratio= %f\n',CR);
set(handles.edit2,'string',CR)

%% 5.Huffman Decoding
tic;%record time
datanew = huffmandeco(comp,dict);% decode the data.
zeroindx=find(data==0);%find boundries
inew=datanew(1:zeroindx(1)-1); %seperate row index
jnew=datanew(zeroindx(1)+1:zeroindx(2)-1); %seperate column index
blksznew=datanew(zeroindx(2)+1:zeroindx(3)-1);%seperate blocksize
avgnew=datanew(zeroindx(3)+1:end); %seperate mean values

%% 6.Decompressed image
avgnew=uint8(avgnew);
for k=1:blkcount 
  outim(inew(k):inew(k)+blksznew(k)-1,jnew(k):jnew(k)+blksznew(k)-1)=avgnew(k);
end


GaussF=guassin_outt(arn);
axes(handles.axes3)
imshow(GaussF);title('Decompressed Image','FontName','cambria','FontSize',12);drawnow;


%% PSNR calculation
%Time taken for De-compression
t=toc;
fprintf('Time taken for Decompression = %f seconds\n',t);
set(handles.edit3,'string',t)
%Create psnr object
 [P]=psnr(I,GaussF);
% hpsnr = vision.PSNR;
% psnr = step(hpsnr, I,outim);%calculate psnr
fprintf('PSNR= %f\n',P);%display psnr
set(handles.edit4,'string',P)


else
%% For color image
for arj=1:3

%% 2.Quadtree Decomposition
s=qtdecomp(I(:,:,arj),0.2,[2 64]);%divides image using quadtree decomposition of
                         %threshold .2 and min dim =2 ,max dim =64
[i,j,blksz] = find(s); %record x and y coordinates and blocksize
blkcount=length(i);  %no of total blocks
si=10.1;
global si
avg=zeros(blkcount,1);%record mean values
for k=1:blkcount 
    avg(k)=mean2(I(i(k):i(k)+blksz(k)-1,j(k):j(k)+blksz(k)-1));%find mean 
                                                               %value
end 
avg=uint8(avg);
quaddisp(:,:,arj)=full(s);

%% 3.Huffman Encoding
%prepare data
i(end+1)=0;j(end+1)=0;blksz(end+1)=0;%set boundary elements
data=[i;j;blksz;avg];%record total information
data=single(data); %convert to single
symbols= unique(data);% Distinct symbols that data source can produce
counts = hist(data(:), symbols);%find counts of symblos in given data
p = counts./ sum(counts);% Probability distribution
sp=round(p*1000);% scaled probabilities
dict = huffmandict(symbols,p'); % Create dictionary.
comp = huffmanenco(data,dict);% Encode the data.

%% 4.Compressed
%Time taken for compression
t(:,:,arj)=toc;
%compression ratio
bits_in_original=8*256*256;
bits_in_final=length(comp)+8*length(symbols)+8*length(sp);
%Compression Ratio = total number of bits in original file, divided by 
%number of bits in final file
CR(:,:,arj)= bits_in_original/bits_in_final;

%% 5.Huffman Decoding
tic;%record time
datanew = huffmandeco(comp,dict);% decode the data.
zeroindx=find(data==0);%find boundries
inew=datanew(1:zeroindx(1)-1); %seperate row index
jnew=datanew(zeroindx(1)+1:zeroindx(2)-1); %seperate column index
blksznew=datanew(zeroindx(2)+1:zeroindx(3)-1);%seperate blocksize
avgnew=datanew(zeroindx(3)+1:end); %seperate mean values

%% 6.Decompressed image
avgnew=uint8(avgnew);
for k=1:blkcount 
  outim(inew(k):inew(k)+blksznew(k)-1,jnew(k):jnew(k)+blksznew(k)-1)=avgnew(k);
end

outimg(:,:,arj)=outim;
    
end
fprintf('Time taken for compression = %f seconds\n',max(t));
set(handles.edit1,'string',max(t))
axes(handles.axes2)
imshow((full(quaddisp)));title('Quadtree Decomposition','FontName','cambria','FontSize',12);drawnow;

GaussF=guassin_outt(arn);
axes(handles.axes3)
imshow(GaussF);title('Decompressed Image','FontName','cambria','FontSize',12);drawnow;

% Compression ratio
fprintf('compression ratio= %f\n',max(CR));
set(handles.edit2,'string',max(CR))

%% PSNR calculation
%Time taken for De-compression
t=toc;
fprintf('Time taken for Decompression = %f seconds\n',t);
set(handles.edit3,'string',t)
%Create psnr object
 [P1]=psnr(I(:,:,1),GaussF(:,:,1));
 [P2]=psnr(I(:,:,2),GaussF(:,:,2));
 [P3]=psnr(I(:,:,3),GaussF(:,:,3));
 P=max([P1,P2,P3]);
fprintf('PSNR= %f\n',P);%display psnr
set(handles.edit4,'string',P)

end
set(handles.figure1, 'pointer', 'arrow')

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a=[];
set(handles.edit1,'string',a)
set(handles.edit2,'string',a)
set(handles.edit3,'string',a)
set(handles.edit4,'string',a)

axes(handles.axes1);cla
axes(handles.axes2);cla
axes(handles.axes3);cla

clc
clear all;


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1)


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
