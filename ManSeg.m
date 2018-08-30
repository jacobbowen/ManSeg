function varargout = ManSeg(varargin)
% MANSEG MATLAB code for ManSeg.fig
% *************************************************************************
% *************************************************************************
% THE SOURCE CODE TO MANSEG (ALL VERSIONS) IS CONFIDENTIAL AND COPYRIGHT IS
% OWNED BY JACOB R. BOWEN (DTU ENERGY CONVERSION AND STORAGE).FOR USAGE
% PERMISSIONS CONTACT JRBO@DTU.DK
% *************************************************************************
% *************************************************************************

% ManSeg v0.2: Contains all basic file and image handling functionality in
% v0.1
% This version develops the basics of line profile analysis
% *************************************************************************
% ManSeg v0.25: Contains all features in v0.2
% This version incorporates the handling of segmented line segments and 
% their classification into phases, calculation of segment statistics and
% their output into the project file structure
% *************************************************************************
% ManSeg v0.3: Contains all features in v0.25
% This version outputs a basic report summarising phase fraction, MLI and
% some statistical information in addition to an image, histogram of line
% segments, the line profile and basic summary information of the image.
% BUG FIX: Missing last segment in statistics calculation
% BUG FIX: Speed increase for classifying interfaces. It is now possible
% to scan left and right whilst holding the left or right arrow kew
% depressed.
% BUG FIX: Plotting of last line segment
% BUG    : Output file is still overwritten. Workaround --> save a new file
%          for each analysed line/image.
% *************************************************************************
% ManSeg v0.31: Contains all features in v0.3
% This version adds PHASE LOCKING to the classification of segments. It is
% therefore no longer possible to classify two sequential segments as the
% same phase when the "Number of Phases" is greater than 1. When "Number of
% Phases" equals one ManSeg v0.31 can be used as a grain size
% characteriser.
% In the phase panel the phase number is now colour coded and is not
% greayed out like the Phase Name once the START button has been activated.
% The chord length histogram in the summary figure now contains coloured
% bars that correspond to the phase colour.
% Implemented workflow control for opening folders, creating a project and
% opening images
% BUGFIX:   Speed increase for keyboard response in assigning phases to
% segments
% BUGFIX:   Output file creation is now bug free. Each project structure
%           can store data for multiple files and multiple lines. Although
%           it is recommended to make a folder of files for each project.
% NEXT TODO: Implement UNDO function of phase assignment. Currently the
%           work around is to use the right arrow key to restart the whole
%           line - quite annoying, but not essential. Task is set for April
% *************************************************************************
% ManSeg v0.32: Contains all features in v0.31 and is a dedicated version
% for a student project
% BUGFIX:   Project Name callback no longer writes the output file to the
%           location specified by the Open Folder Button. The project file
%           is now initially saved in the location set by the Select data
%           output location button.
% BUGFIX:   File management is now independent of operating system for file
%           path handling
% BUGFIX:   Suppression of non TIF and JPG files in the files list
%           corrected
% BUG:      When reaching the last interface on the test line and the NO
%           CallBack is executed NO tries to write to Project which is
%           not a structure. WORKAROUND is to use the Previous CallBack and
%           the the Next CallBack at the end of the line after a NO
%           command. The same issue is encountered when executing the YES
%           CallBack at the end of the test line.
% *************************************************************************
% ManSeg v0.34: Contains all features in v0.32
% BUGFIX:   OpenFile:
%           2013-07-26: Corrected pixel size reading error for Zeiss images 
%           when number of decimal places vaires.
%           2013-07-26: ManSeg now gives warning to set the pixel size 
%           manually if itcan't be read from a Zeiss image.
% BUGFIX:   OpenFolder:
%           Occasional error in NotImage filter calculation
%           2013-07-26: Corrected NotImage parameter error by preassigning
% NEW FUNC: OpenFile:
%           2013-07-30: Now reads Hitachi TM1000 and TM3000 images and
%           accounts for 24 bit RGB format files, both TIF and JPG.
%           OpenFIle also sets pixel size correctly and warns if it cannot
%           find the corresponding image TXT metadata file.
% BUG:      Segment:
%           ManSeg version not correctly displayed in output figure
% *************************************************************************
% ManSeg v0.35: Contains all features in v0.34
% BIGFIX:   OpenFile:
%           2013-08-06: Could not close Hitachi text file if none was
%           opened. fclose moved to inside IF statement where fopen used
% BUGFIX:   OpenFile
%           2013-11-04: filepath does not exist until user changes the
%           selected image in the files list. Edit OpenFolder.
%           Error was because set FileData did not include filepath, 
%           therefore OpenFile erased its own data.
% NEW FUNC: MedFilt:
%           2013-11-04: Option to remoce image noise using a median filter
%           (medfilt2D). No restrictions applied yet. Checkbox functions
%           but interdependencies with other callbacks not tested yet.
% NEW FUNC: Segment
%           2013-11-04: Sv added to stats calculated. No output as yet.
% BUGFIX:   OpenFile
%           2013-11-26: Allow for older versions of SMARTSEM with limited
%           tiff headers. Added extra if statment to check the output of
%           regular expression
% BUGFIX:   Segment
%           2013-11-26: Fixed subscripting of file names in the summary
%           output
% NEW FUNC: Help
%           2013-11-29: Added a help button that opens the old figure with
%           segmenting instructions. This is disabled in the Next function.
% NEW FUNC: Main
%           2013-11-29: Added DTU logos to figure
% *************************************************************************
% ManSeg v0.36: Contains all features in v0.35
% BUGFIX:   YES, NO,OUTPUT & Segment
%           2014-08-08: Fixed error on when checking for existing project
%           data file exists. ManSeg v0.36 should now be able to append
%           data to an existing project if new files or test lines are
%           analysed. This feature will mostly only benefit users of the
%           saved data file and for the planned "Interceptor" statistics
%           program
% NEW FUNC: Segment
%           2014-08-08: ManSeg 0.36 now outputs a figure containing a table
%           of chord lengths from the most recently analysed test line. The
%           data can be copied and pasted elsewhere for other analysis if
%           needed. NOTE: THIS IS A TEMPORARY FEATURE AND WILL BE REMOVED
%           AFTER THE RELEASE OF INTERCEPTOR
% *************************************************************************
% ManSeg v0.37: Contains sll fetures in v0.36
% Planned feature is to implement possibility to count boundaries within
% phases
% BUGFIX:   Error if start button pressed before selecting a testline
%           2017-08-22: Added an error dialog message to beginning of START
%           button callback function.
% NEW FUNC: Added Grain Boundary function tickbox and added functionality
%           to PhaseX button down functions to check for GB tickbox status.
% TODO:     Add statistical analysis of grain segment lengths. The user
%           must collate grain segements and perform statistics otherwise
%           the phase segments that contain grains will tield an incorrect
%           phase MLI etc.
% TODO:     Add function to skip to ends and middle of testline
%**************************************************************************
% ManSeg v0.4 will implement advanced profile analysis of grids and circles
% manseg v0.5 will implement the statistical analysis of analysed profiles
% and is tentatively the last alpha version prior to ManSeg v1.0
% *************************************************************************
% See also: 

% Edit the above text to modify the response to help ManSeg

% Last Modified by GUIDE v2.5 17-Aug-2017 10:51:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ManSeg_OpeningFcn, ...
                   'gui_OutputFcn',  @ManSeg_OutputFcn, ...
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



% --- Executes just before ManSeg is made visible.
function ManSeg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ManSeg (see VARARGIN)

% Choose default command line output for ManSeg
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% Set the default line profile selection to Single Line
set(handles.LineSetupPanel,'SelectedObject',handles.SingLineBut)
% Initialise ZoomPopup
Zoom = get(handles.ZoomPopup,'String');
SelectedZoom = get(handles.ZoomPopup,'Value');
Padding = Zoom(SelectedZoom);
Padding = Padding{1};
Padding = str2num(Padding);
data.Padding=Padding;
set(handles.ZoomPopup,'UserData',data)
% Make Main & Zoom Image's axes pretty
set(handles.MainImage,'XColor',[1 .5 0],'YColor',[1 .5 0],...
    'GridLineStyle',':','MinorGridLineStyle',':',...
    'XGrid','on','YGrid','on','Layer','top',...
    'XMinorGrid','off','YMinorGrid','off','Layer','top')
set(handles.ZoomImage,'XColor',[1 .5 0],'YColor',[1 .5 0],...
    'GridLineStyle',':','MinorGridLineStyle',':',...
    'XGrid','on','YGrid','on','Layer','top',...
    'XMinorTick','on','YMinorTick','on','Layer','top')
% Setup logos
axes(handles.Logo1)
% ECS = imread([pwd,'\ECS.bmp']);
imshow([pwd,'\ECS.bmp'],'Border','tight')
axes(handles.DTU)
% DTU = imread([pwd,'\DTU 3.jpg']);
imshow([pwd,'\DTU 3.jpg'],'Border','loose')

% UIWAIT makes ManSeg wait for user response (see UIRESUME)
% uiwait(handles.ManSeg);

% --- Outputs from this function are returned to the command line.
function varargout = ManSeg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on slider movement.
function HorizPosSlide_Callback(hObject, eventdata, handles)
% hObject    handle to HorizPosSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% Deactivate vertical line control
HorizPosSlide_ButtonDownFcn(handles.HorizPosSlide,eventdata,handles)
% Get MainImage's UserData
data = get(handles.MainImage,'UserData');
% Delete the previous line if it exists
MainImageKids = get(handles.MainImage,'Children');
for n=1:length(MainImageKids)
    if strcmp(get(MainImageKids(n),'Tag'),'Horizontal')
        delete(MainImageKids(n))
    elseif strcmp(get(MainImageKids(n),'Tag'),'Vertical')
        delete(MainImageKids(n))
    elseif strcmp(get(MainImageKids(n),'Tag'),'LocationMarker')
        delete(MainImageKids(n))
    elseif strcmp(get(MainImageKids(n),'Tag'),'Segment')
           delete(MainImageKids(n))
    end
end
info = data.info;
% Set slider max and min and the slider step to 1 and 100 pixel steps
set(hObject,'Max',info.Width)
set(hObject,'Min',1)
set(hObject,'SliderStep',[1/info.Width 100/info.Width])
% Set Main Image in focus and draw line
axes(handles.MainImage);
horpos = get(hObject,'Value');
horpos = uint16(horpos);
h = line([horpos horpos],[0 info.Height],'LineStyle','-.','Color','r',...
    'LineWidth',2);
set(h,'Tag','Horizontal')
set(handles.HorizPosText,'String',int2str(horpos))
data.h = h;
% Extract pixel intensities in line
data.LineColNo = horpos;
CurrentImage = data.CurrentImage;
data.CurrentLineIntensity = CurrentImage(:,horpos);
% Store data in MainImage UserData
set(handles.MainImage,'UserData',data)
% Update Line Profile
LineProfileKids = get(handles.LineProfile,'Children');
% Delete the previous line profile if there is one
for n=1:length(LineProfileKids)
    if strcmp(get(LineProfileKids(n),'Tag'),'Profile')
        delete(LineProfileKids(n))
    elseif strcmp(get(LineProfileKids(n),'Tag'),'LocationMarker')
        delete(LineProfileKids(n))
    elseif strcmp(get(LineProfileKids(n),'Tag'),'Segment')
        delete(LineProfileKids(n))
    end
end
axes(handles.LineProfile);
Profile = line(1:info.Height,data.CurrentLineIntensity,'Color','r','LineStyle','-');
set(Profile,'Tag','Profile')
% h = plot(data.CurrentLineIntensity,'-r');
axis tight
% Update Zoom Profile
LineKids = get(handles.LineProfile,'Children');
ZoomKids = get(handles.ZoomProfile,'Children');
delete(ZoomKids)
ZoomKids = copyobj(LineKids,handles.ZoomProfile);
Padding = get(handles.ZoomPopup,'UserData');
Padding = Padding.Padding;
set(handles.ZoomProfile,'xlim',[data.CurrentLocation(1)-Padding data.CurrentLocation(1)+Padding])

% --- Executes during object creation, after setting all properties.
function HorizPosSlide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HorizPosSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'String','0')

function HorizPosText_Callback(hObject, eventdata, handles)
% hObject    handle to HorizPosText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HorizPosText as text
%        str2double(get(hObject,'String')) returns contents of HorizPosText as a double

HorPos = str2double(get(hObject,'String'));
set(handles.HorizPosSlide,'Value',HorPos)
HorizPosSlide_Callback(handles.HorizPosSlide, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function HorizPosText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HorizPosText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function VerPosSlide_Callback(hObject, eventdata, handles)
% hObject    handle to VerPosSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
VerPosSlide_ButtonDownFcn(handles.HorizPosSlide,eventdata,handles)
% Get MainImage's UserData
data = get(handles.MainImage,'UserData');
% Delete the previous line and LocationMarker if it exists
MainImageKids = get(handles.MainImage,'Children');
for n=1:length(MainImageKids)
       if strcmp(get(MainImageKids(n),'Tag'),'Vertical')
           delete(MainImageKids(n))
       elseif strcmp(get(MainImageKids(n),'Tag'),'Horizontal')
           delete(MainImageKids(n))
       elseif strcmp(get(MainImageKids(n),'Tag'),'LocationMarker')
           delete(MainImageKids(n))
       elseif strcmp(get(MainImageKids(n),'Tag'),'Segment')
           delete(MainImageKids(n))
       end
end
info = data.info;
% Set slider max and min and the slider step to 1 and 100 pixel steps
set(hObject,'Max',info.Height)
set(hObject,'Min',1)
set(hObject,'SliderStep',[1/info.Height 100/info.Height])
% Set Main Image in focus and draw line
axes(handles.MainImage);
verpos = get(hObject,'Value');
verpos = uint16(verpos);
v = line([0 info.Width],[verpos verpos],'LineStyle','-.','Color','b',...
    'LineWidth',2);
set(v,'Tag','Vertical')
set(handles.VerPosText,'String',int2str(verpos))
data.v = v;
% Extract pixel intensities in line
data.LineRowNo = verpos;
CurrentImage = data.CurrentImage;
data.CurrentLineIntensity = CurrentImage(verpos,:);
% Store data in MainImage UserData
set(handles.MainImage,'UserData',data)
% Update Line Profile
LineProfileKids = get(handles.LineProfile,'Children');
% Delete the previous line profile and LocationMarker if they exist
for n=1:length(LineProfileKids)
    if strcmp(get(LineProfileKids(n),'Tag'),'Profile')
        delete(LineProfileKids(n))
    elseif strcmp(get(LineProfileKids(n),'Tag'),'LocationMarker')
        delete(LineProfileKids(n))
    elseif strcmp(get(LineProfileKids(n),'Tag'),'Segment')
        delete(LineProfileKids(n))
    end
end
axes(handles.LineProfile);
Profile = line(1:info.Width,data.CurrentLineIntensity,'Color','b','LineStyle','-');
set(Profile,'Tag','Profile')
axis tight
% Update ZoomProfile
LineKids = get(handles.LineProfile,'Children');
ZoomKids = get(handles.ZoomProfile,'Children');
delete(ZoomKids)
ZoomKids = copyobj(LineKids,handles.ZoomProfile);
Padding = get(handles.ZoomPopup,'UserData');
Padding = Padding.Padding;
set(handles.ZoomProfile,'xlim',[data.CurrentLocation(2)-Padding data.CurrentLocation(2)+Padding])


% --- Executes during object creation, after setting all properties.
function VerPosSlide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VerPosSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'Value',10)
set(hObject,'Max',200)
set(hObject,'Min',10)

function VerPosText_Callback(hObject, eventdata, handles)
% hObject    handle to VerPosText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of VerPosText as text
%        str2double(get(hObject,'String')) returns contents of VerPosText as a double
VerPos = str2double(get(hObject,'String'));
set(handles.VerPosSlide,'Value',VerPos)
VerPosSlide_Callback(handles.VerPosSlide, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function VerPosText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VerPosText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function AngleSlide_Callback(hObject, eventdata, handles)
% hObject    handle to AngleSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% Get the OriginalImage, rotate it and store it in CurrentImage, update
% file info with new image dimensions
set(hObject,'SliderStep',[1/180 10/180])
data = get(handles.MainImage,'UserData');
angle = get(hObject,'Value');
set(handles.AngleText,'String',num2str(angle))
% Update angle for MainImage's UserData
data.angle = angle;
% Rotate image
CurrentImage = imrotate(data.OriginalImage,angle,'bilinear','crop');
data.CurrentImage = CurrentImage;
% Plot rotated image in MainImage
axes(handles.MainImage);
AxesKids=get(gca,'Children');
length(AxesKids);
if length(AxesKids>1)
    for n=1:length(AxesKids)
        if strcmp(get(AxesKids(n),'Type'),'image')
            set(AxesKids(n),'CData',CurrentImage)
        else
        end
    end
else
    set(AxesKids,'CData',CurrentImage)
end
% Update MainImage UserData's CurrentImage field with the rotated image
set(handles.MainImage,'UserData',data)
% Plot rotated image in ZoomImage
% data = get(handles.MainImage,'UserData');
% CurrentLocation = data.CurrentLocation;
% Zoom = get(handles.ZoomPopup,'String');
% SelectedZoom = get(handles.ZoomPopup,'Value');
% Padding = Zoom(SelectedZoom);
% Padding = Padding{1};
% Padding = str2num(Padding);
% axes(handles.ZoomImage);
ZoomKids=get(handles.ZoomImage,'Children');
% if length(ZoomKids>1)
for n=1:length(ZoomKids)
    if strcmp(get(ZoomKids(n),'Type'),'image')
        ZoomPopup_Callback(handles.ZoomPopup, eventdata, handles)
%         CurrentZoom = CurrentImage(CurrentLocation(1)-Padding:CurrentLocation(1)+Padding,CurrentLocation(2)-Padding:CurrentLocation(2)+Padding);
%         set(ZoomKids(n),'CData',CurrentZoom)
%         data.CurrentZoom = CurrentZoom;
    end
end
% else
%     set(ZoomKids,'CData',CurrentImage(CurrentLocation(1)-Padding:CurrentLocation(1)+Padding,CurrentLocation(2)-Padding:CurrentLocation(2)+Padding))
% end
% Update MainImage UserData's CurrentImage field with the rotated zoom image
% set(handles.MainImage,'UserData',data)
% Update Lineprofile according to horizontal and vertical slider positions
if strcmp(get(handles.HorizPosSlide,'Enable'),'on')
    HorizPosSlide_Callback(handles.HorizPosSlide, eventdata, handles)
else if strcmp(get(handles.VerPosSlide,'Enable'),'on')
        VerPosSlide_Callback(handles.VerPosSlide, eventdata, handles)
    end
end
    
% --- Executes during object creation, after setting all properties.
function AngleSlide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AngleSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'SliderStep',[1/180 10/180])

function AngleText_Callback(hObject, eventdata, handles)
% hObject    handle to AngleText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AngleText as text
%        str2double(get(hObject,'String')) returns contents of AngleText as a double
data = get(handles.MainImage,'UserData');
angle = get(handles.AngleText,'String');
angle = str2double(angle);
set(handles.AngleSlide,'Value',angle)
data.angle = angle;
set(handles.MainImage,'UserData',data)
AngleSlide_Callback(handles.AngleSlide, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function AngleText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AngleText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function LinePercSlide_Callback(hObject, eventdata, handles)
% hObject    handle to LinePercSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes during object creation, after setting all properties.
function LinePercSlide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LinePercSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function LinePercText_Callback(hObject, eventdata, handles)
% hObject    handle to LinePercText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LinePercText as text
%        str2double(get(hObject,'String')) returns contents of LinePercText as a double

% --- Executes during object creation, after setting all properties.
function LinePercText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LinePercText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function BasicIntThrSlide_Callback(hObject, eventdata, handles)
% hObject    handle to BasicIntThrSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes during object creation, after setting all properties.
function BasicIntThrSlide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BasicIntThrSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function BasicIntThrText_Callback(hObject, eventdata, handles)
% hObject    handle to BasicIntThrText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BasicIntThrText as text
%        str2double(get(hObject,'String')) returns contents of BasicIntThrText as a double

% --- Executes during object creation, after setting all properties.
function BasicIntThrText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BasicIntThrText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function HorizGrdPitSlide_Callback(hObject, eventdata, handles)
% hObject    handle to HorizGrdPitSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes during object creation, after setting all properties.
function HorizGrdPitSlide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HorizGrdPitSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'Value',10)
set(hObject,'Max',200)
set(hObject,'Min',10)

function HorizGrdPitText_Callback(hObject, eventdata, handles)
% hObject    handle to HorizGrdPitText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HorizGrdPitText as text
%        str2double(get(hObject,'String')) returns contents of HorizGrdPitText as a double

% --- Executes during object creation, after setting all properties.
function HorizGrdPitText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HorizGrdPitText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function VerGrdPitSlide_Callback(hObject, eventdata, handles)
% hObject    handle to VerGrdPitSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes during object creation, after setting all properties.
function VerGrdPitSlide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VerGrdPitSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function VerGrdPitText_Callback(hObject, eventdata, handles)
% hObject    handle to VerGrdPitText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of VerGrdPitText as text
%        str2double(get(hObject,'String')) returns contents of VerGrdPitText as a double

% --- Executes during object creation, after setting all properties.
function VerGrdPitText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VerGrdPitText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function PhaseNumSlide_Callback(hObject, eventdata, handles)
% hObject    handle to PhaseNumSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% Update PhaseNumText
PhaseNum = get(hObject,'Value');
PhaseNum = uint16(PhaseNum);
set(handles.PhaseNumText,'String',int2str(PhaseNum))
PhaseNumText_Callback(handles.PhaseNumText, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function PhaseNumSlide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PhaseNumSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function PhaseNumText_Callback(hObject, eventdata, handles)
% hObject    handle to PhaseNumText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PhaseNumText as text
%        str2double(get(hObject,'String')) returns contents of PhaseNumText as a double

% Update PhaseNumSlide
PhaseNum = str2double(get(hObject,'String'));
set(handles.PhaseNumSlide,'Value',PhaseNum)
% Deactivate unused phases
for n = 10:-1:PhaseNum-1
    if n==0
        continue
    else
        eval(['set(handles.Phase',num2str(n),'Edit,''Visible'',''off'')'])
        eval(['set(handles.Phase',num2str(n),'Text,''Visible'',''off'')'])
    end
end
for n = 1:PhaseNum
    eval(['set(handles.Phase',num2str(n),'Edit,''Visible'',''on'')'])
    eval(['set(handles.Phase',num2str(n),'Text,''Visible'',''on'')'])
end

% --- Executes during object creation, after setting all properties.
function PhaseNumText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PhaseNumText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function PixelSizeSlide_Callback(hObject, eventdata, handles)
% hObject    handle to PixelSizeSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
pixel = get(hObject,'Value');
set(handles.PixelSizeEdit,'String',num2str(pixel))

% --- Executes during object creation, after setting all properties.
function PixelSizeSlide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PixelSizeSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function PixelSizeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to PixelSizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PixelSizeEdit as text
%        str2double(get(hObject,'String')) returns contents of PixelSizeEdit as a double
pixel = get(hObject,'String');
set(handles.PixelSizeSlide,'Value',str2num(pixel))

% --- Executes during object creation, after setting all properties.
function PixelSizeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PixelSizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function slider15_Callback(hObject, eventdata, handles)
% hObject    handle to slider15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes during object creation, after setting all properties.
function slider15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double

% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in Previous.
function Previous_Callback(hObject, eventdata, handles)
% hObject    handle to Previous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get MainImage UserData
data = get(handles.MainImage,'UserData');
data.CurrentAuto = data.CurrentAuto - 1;
auto = data.Auto(data.CurrentAuto,:);
data.CurrentLocation(1) = auto(2);
data.CurrentLocation(2) = auto(1);
set(handles.LocationText,'String',sprintf('Current Location\n [%d %d]',auto(2),auto(1)))
set(handles.IntfaceNoText,'String',sprintf('Interface No: %d',data.CurrentAuto))
% Setup case for first datapoint behaviour
if data.CurrentAuto == 1
    set(hObject,'Enable','off')
    return
end
set(handles.MainImage,'UserData',data)
% Enable next
set(handles.Next,'Enable','on')
% Setup YES/NO buttons on off
if data.Auto(data.CurrentAuto,5)==1
    set(handles.YES,'Enable','off')
    set(handles.NO,'Enable','on')
elseif data.Auto(data.CurrentAuto,5)==-1
    set(handles.NO,'Enable','off')
    set(handles.YES,'Enable','on')
elseif data.Auto(data.CurrentAuto,5)==0
    set(handles.NO,'Enable','on')
    set(handles.YES,'Enable','on')
end
% Update MainImage
MainImageKids = get(handles.MainImage,'Children');
for n = 1:length(MainImageKids)
    if strcmp(get(MainImageKids(n),'Tag'),'LocationMarker')
        if auto(4)==0
            set(MainImageKids(n),'XData',auto(1),'YData',auto(2),...
                'Marker','v','MarkerFaceColor','y')
            if data.Auto(data.CurrentAuto,5)==1
                set(MainImageKids(n),'MarkerFaceColor','g',...
                    'MarkerEdgeColor','g')
            elseif data.Auto(data.CurrentAuto,5)==-1
                set(MainImageKids(n),'MarkerFaceColor','r',...
                    'MarkerEdgeColor','r')
            end
        elseif auto(4)==1
            set(MainImageKids(n),'XData',auto(1),'YData',auto(2),...
                'Marker','^','MarkerFaceColor','y')
            if data.Auto(data.CurrentAuto,5)==1
                set(MainImageKids(n),'MarkerFaceColor','g',...
                    'MarkerEdgeColor','g')
            elseif data.Auto(data.CurrentAuto,5)==-1
                set(MainImageKids(n),'MarkerFaceColor','r',...
                    'MarkerEdgeColor','r')
            end
        end
    end
end
% Update ZoomImage
ZoomPopup_Callback(handles.ZoomPopup, eventdata, handles)
% Update LineProfile
LineProfileKids = get(handles.LineProfile,'Children');
LineProfileData = get(handles.LineProfile,'UserData');
for n = 1:length(LineProfileKids)
    switch LineProfileData.LineOrientation
        case 'Horizontal'
            orientation = 'Horizontal';
            if strcmp(get(LineProfileKids(n),'Tag'),'LocationMarker')
                if auto(4)==0
                    set(LineProfileKids(n),'XData',auto(1),'YData',auto(3),...
                        'Marker','v','MarkerFaceColor','y')
                    if data.Auto(data.CurrentAuto,5)==1
                        set(LineProfileKids(n),'MarkerFaceColor','g',...
                        'MarkerEdgeColor','g')
                    elseif data.Auto(data.CurrentAuto,5)==-1
                        set(LineProfileKids(n),'MarkerFaceColor','r',...
                    'MarkerEdgeColor','r')
                    end
                elseif auto(4)==1
                    set(LineProfileKids(n),'XData',auto(1),'YData',auto(3),...
                        'Marker','^','MarkerFaceColor','y')
                    if data.Auto(data.CurrentAuto,5)==1
                        set(LineProfileKids(n),'MarkerFaceColor','g',...
                        'MarkerEdgeColor','g')
                    elseif data.Auto(data.CurrentAuto,5)==-1
                        set(LineProfileKids(n),'MarkerFaceColor','r',...
                    'MarkerEdgeColor','r')
                    end
                end
            end
        case 'Vertical'
            orientation = 'Horizontal';
            if strcmp(get(LineProfileKids(n),'Tag'),'LocationMarker')
                if auto(4)==0
                    set(LineProfileKids(n),'XData',auto(2),'YData',auto(3),...
                        'Marker','v','MarkerFaceColor','y')
                    if data.Auto(data.CurrentAuto,5)==1
                        set(LineProfileKids(n),'MarkerFaceColor','g',...
                        'MarkerEdgeColor','g')
                    elseif data.Auto(data.CurrentAuto,5)==-1
                        set(LineProfileKids(n),'MarkerFaceColor','r',...
                    'MarkerEdgeColor','r')
                    end
                elseif auto(4)==1
                    set(LineProfileKids(n),'XData',auto(2),'YData',auto(3),...
                        'Marker','^','MarkerFaceColor','y')
                    if data.Auto(data.CurrentAuto,5)==1
                        set(LineProfileKids(n),'MarkerFaceColor','g',...
                        'MarkerEdgeColor','g')
                    elseif data.Auto(data.CurrentAuto,5)==-1
                        set(LineProfileKids(n),'MarkerFaceColor','r',...
                    'MarkerEdgeColor','r')
                    end
                end
            end
    end
end
% Update ZoomProfile
LineKids = get(handles.LineProfile,'Children');
ZoomKids = get(handles.ZoomProfile,'Children');
delete(ZoomKids)
ZoomKids = copyobj(LineKids,handles.ZoomProfile);
Padding = get(handles.ZoomPopup,'UserData');
Padding = Padding.Padding;
if strcmp(orientation,'Vertical')
set(handles.ZoomProfile,'xlim',[data.CurrentLocation(1)-Padding data.CurrentLocation(1)+Padding])
elseif strcmp(orientation,'Horizontal')
    set(handles.ZoomProfile,'xlim',[data.CurrentLocation(2)-Padding data.CurrentLocation(2)+Padding])
end
% Update Classified
Remaining = find(data.Auto(:,5)==0);
set(handles.ClassifiedText,'String',sprintf('Unclassified: %d',length(Remaining)))

% --- Executes on button press in Next.
function Next_Callback(hObject, eventdata, handles)
% hObject    handle to Next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get MainImage UserData
data = get(handles.MainImage,'UserData');
Remaining = find(data.Auto(:,5)==0);
% Setup case for last datapoint behaviour
if data.CurrentAuto == length(data.Auto)
    set(hObject,'Enable','off')
    if length(Remaining)==0
        classify = questdlg('There are no more interfaces to classify, would you like to classify line segments?',...
            'Line finished!','Yes','No','Cancel','No');
        switch classify
            case 'Yes'
                % Identify segments
                switch data.Mode
                    case 'Single Horizontal'
                        AutoCol = 1;
                    case 'Single Vertical'
                        AutoCol = 2;
                end
                Manual = data.Auto(find(data.Auto(:,5)==1),:);
                data.Manual = Manual;
                Segments(:,1) = Manual(1:end-1,AutoCol);
                Segments(:,2) = Manual(2:end,AutoCol)-1;
                % Sort out segment one with image boundary
                if data.Auto(1,AutoCol)~=1
                Segments(length(Segments)+1,:) = [1,Manual(1,AutoCol)-1];
                Segments = circshift(Segments,[1,0]);
                end
                % Sort out last segment with image boundary
                switch data.Mode
                    case 'Single Horizontal'
                        if data.Auto(end,AutoCol)~=data.info.Width
                            Segments(length(Segments)+1,:) = [Manual(end,AutoCol),data.info.Width];
                        end
%                         % Move functionality out of Next button to Segment
%                         % button
%                         data.Segments = Segments;
%                         set(handles.MainImage,'UserData',data)
%                         set(handles.Segment,'Visible','on')
%                         Segment_Callback(handles.Segment, eventdata, handles)
                    case 'Single Vertical'
                        if data.Auto(end,AutoCol)~=data.info.Height
                            Segments(length(Segments)+1,:) = [Manual(end,AutoCol),data.info.Height];
                        end
                        
                end
%                 h = figure('Toolbar','none','Name','Segmening Instructions','Color',[225 235 250]/255,...
%                     'MenuBar','none','NumberTitle','off');
%                 HelpText = {'Use the following keys to allocate individual segments',...
%                     'to phases.','',...
%                     'Note: to activate key strokes click set the ManSeg window',...
%                     'in focus by clicking on a light blue background portion of',...
%                     ' the window',...
%                     '','For each segment press the number corresponding to the',...
%                     'the phase (or click on the corresponding phase in the )',...
%                     'phase panel.','','Use the ''Home'' key to identify contiguous ',...
%                     'segments at the beginning of a line profile that should not be ',...
%                     'counted as a phase. This is useful if you have rotated the image.',...
%                     'Correspondingly use the ''End'' key to identify contiguous',...
%                     'line segments at the end of a line profile.','',...
%                     'Use the ''Page Up'' and Page Down'' keys to navigate forth and',...
%                     'back along the line segments in case you wish to correct',...
%                     'the allocation of a segment.','',...
%                     'The segment will automatically advance on selection of a phase.',...
%                     'Once all segments are allocated you will be asked for final confirmation.'};
%                 HText = text(0,0,HelpText);
%                 axis off
%                 xlim([-10 10])
%                 ylim([-10 10])
%                 set(HText, 'HorizontalAlignment','center','VerticalAlignment','middle')
                % Setup segment statistics panel
                
                data.Segments = Segments;
                Segment.Phase = [];
                data.Segment = Segment;
                data.CurrentSegmentNo = 1;
                set(handles.MainImage,'UserData',data)
                set(handles.SegmentsText,'String',sprintf('Segments: %d',length(Segments)))
                set(handles.SegmentNumText,'String',sprintf('Segment No: %d',data.CurrentSegmentNo))
                set(handles.SegClassifiedText,'String',sprintf('Classified: %d',0))
                % Move functionality out of Next button to Segment button
                set(handles.Segment,'Visible','on')
                Segment_Callback(handles.Segment, eventdata, handles)
             case 'No'
            case 'Cancel'
        end
    end
    return
end

data.CurrentAuto = data.CurrentAuto + 1;
auto = data.Auto(data.CurrentAuto,:);
data.CurrentLocation(1) = auto(2);
data.CurrentLocation(2) = auto(1);
set(handles.LocationText,'String',sprintf('Current Location\n [%d %d]',auto(2),auto(1)))
set(handles.IntfaceNoText,'String',sprintf('Interface No: %d',data.CurrentAuto))
set(handles.MainImage,'UserData',data)
% Enable previous
set(handles.Previous,'Enable','on')
% Setup YES/NO buttons on off
if data.Auto(data.CurrentAuto,5)==1
    set(handles.YES,'Enable','off')
    set(handles.NO,'Enable','on')
elseif data.Auto(data.CurrentAuto,5)==-1
    set(handles.NO,'Enable','off')
    set(handles.YES,'Enable','on')
elseif data.Auto(data.CurrentAuto,5)==0
    set(handles.NO,'Enable','on')
    set(handles.YES,'Enable','on')
end
% Update MainImage
MainImageKids = get(handles.MainImage,'Children');
for n = 1:length(MainImageKids)
    if strcmp(get(MainImageKids(n),'Tag'),'LocationMarker')
        if auto(4)==0
            set(MainImageKids(n),'XData',auto(1),'YData',auto(2),...
                'Marker','v','MarkerFaceColor','y')
            if data.Auto(data.CurrentAuto,5)==1
                set(MainImageKids(n),'MarkerFaceColor','g',...
                    'MarkerEdgeColor','g')
            elseif data.Auto(data.CurrentAuto,5)==-1
                set(MainImageKids(n),'MarkerFaceColor','r',...
                    'MarkerEdgeColor','r')
            end
        elseif auto(4)==1
            set(MainImageKids(n),'XData',auto(1),'YData',auto(2),...
                'Marker','^','MarkerFaceColor','y')
            if data.Auto(data.CurrentAuto,5)==1
                set(MainImageKids(n),'MarkerFaceColor','g',...
                    'MarkerEdgeColor','g')
            elseif data.Auto(data.CurrentAuto,5)==-1
                set(MainImageKids(n),'MarkerFaceColor','r',...
                    'MarkerEdgeColor','r')
            end
        end
    end
end
% Update ZoomImage
ZoomPopup_Callback(handles.ZoomPopup, eventdata, handles)
% Update LineProfile
LineProfileKids = get(handles.LineProfile,'Children');
LineProfileData = get(handles.LineProfile,'UserData');
for n = 1:length(LineProfileKids)
    switch LineProfileData.LineOrientation
        case 'Horizontal'
            orientation = 'Horizontal';
            if strcmp(get(LineProfileKids(n),'Tag'),'LocationMarker')
                % Detect negative gradient and use appropriate marker
                if auto(4)==0
                    set(LineProfileKids(n),'XData',auto(1),'YData',auto(3),...
                        'Marker','v','MarkerFaceColor','y')
                    if data.Auto(data.CurrentAuto,5)==1
                        set(LineProfileKids(n),'MarkerFaceColor','g',...
                        'MarkerEdgeColor','g')
                    elseif data.Auto(data.CurrentAuto,5)==-1
                        set(LineProfileKids(n),'MarkerFaceColor','r',...
                    'MarkerEdgeColor','r')
                    end
                elseif auto(4)==1
                    % Detect positive gradient and use appropriate marker
                    set(LineProfileKids(n),'XData',auto(1),'YData',auto(3),...
                        'Marker','^','MarkerFaceColor','y')
                    if data.Auto(data.CurrentAuto,5)==1
                        set(LineProfileKids(n),'MarkerFaceColor','g',...
                            'MarkerEdgeColor','g')
                    elseif data.Auto(data.CurrentAuto,5)==-1
                        set(LineProfileKids(n),'MarkerFaceColor','r',...
                    'MarkerEdgeColor','r')
                    end
                end
            end
        case 'Vertical'
            orientation = 'Vertical';
            if strcmp(get(LineProfileKids(n),'Tag'),'LocationMarker')
                % Detect negative gradient and use appropriate marker
                if auto(4)==0
                    set(LineProfileKids(n),'XData',auto(2),'YData',auto(3),...
                        'Marker','v','MarkerFaceColor','y')
                    if data.Auto(data.CurrentAuto,5)==1
                        set(LineProfileKids(n),'MarkerFaceColor','g',...
                            'MarkerEdgeColor','g')
                    elseif data.Auto(data.CurrentAuto,5)==-1
                        set(LineProfileKids(n),'MarkerFaceColor','r',...
                    'MarkerEdgeColor','r')
                    end
                elseif auto(4)==1
                    % Detect positive gradient and use appropriate marker
                    set(LineProfileKids(n),'XData',auto(2),'YData',auto(3),...
                        'Marker','^','MarkerFaceColor','y')
                    if data.Auto(data.CurrentAuto,5)==1
                        set(LineProfileKids(n),'MarkerFaceColor','g',...
                            'MarkerEdgeColor','g',...
                    'MarkerEdgeColor','r')
                    elseif data.Auto(data.CurrentAuto,5)==-1
                        set(LineProfileKids(n),'MarkerFaceColor','r')
                    end
                end
            end
    end
end
% Update ZoomProfile
LineKids = get(handles.LineProfile,'Children');
ZoomKids = get(handles.ZoomProfile,'Children');
delete(ZoomKids)
ZoomKids = copyobj(LineKids,handles.ZoomProfile);
Padding = get(handles.ZoomPopup,'UserData');
Padding = Padding.Padding;
if strcmp(orientation,'Vertical')
set(handles.ZoomProfile,'xlim',[data.CurrentLocation(1)-Padding data.CurrentLocation(1)+Padding])
elseif strcmp(orientation,'Horizontal')
    set(handles.ZoomProfile,'xlim',[data.CurrentLocation(2)-Padding data.CurrentLocation(2)+Padding])
end
% Update Classified
Remaining = find(data.Auto(:,5)==0);
set(handles.ClassifiedText,'String',sprintf('Unclassified: %d',length(Remaining)))


% --- Executes on button press in YES.
function YES_Callback(hObject, eventdata, handles)
% hObject    handle to YES (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.MainImage,'UserData');
% auto = data.Auto(data.CurrentAuto,:);
data.Auto(data.CurrentAuto,5) = 1;
set(handles.MainImage,'UserData',data)
% Setup case for last datapoint behaviour
if data.CurrentAuto == length(data.Auto)
    set(hObject,'Enable','off')
    % NextUnclassified data in project to disk
    FileUserData = get(handles.OpenFile,'UserData');
    filenumber = FileUserData.filenumber;
    FileUserData.Project = get(handles.ProjectName,'String');
    
    MainImageUserData = get(handles.MainImage,'UserData');
    MainImageUserData = rmfield(MainImageUserData,'CurrentImage');
    MainImageUserData = rmfield(MainImageUserData,'OriginalImage');
    MainImageUserData = rmfield(MainImageUserData,'CurrentLocation');
    MainImageUserData = rmfield(MainImageUserData,'CurrentAuto');
%     Auto = MainImageUserData.Auto;
           
    OpenFolderUserData = get(handles.OpenFolder,'UserData');
    directoryname = OpenFolderUserData.path;
    saveproject = [directoryname '\' FileUserData.Project];
    % Check for exisitng project file
    ProjectExist = exist(saveproject, 'file');
    if ~ProjectExist
        load(saveproject);
    end
%     Project = rmfield(Project,'Project');
    % Add file, MainImage and line info to Project structure
    Project(filenumber).File = FileUserData;
    Project(filenumber).MainImage = MainImageUserData;
    Project(filenumber).LineSetup = get(handles.LineSetupPanel,'UserData');
    save(saveproject,'Project')
%     return
end

Next_Callback(handles.Next, eventdata, handles)

% --- Executes on button press in NO.
function NO_Callback(hObject, eventdata, handles)
% hObject    handle to NO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.MainImage,'UserData');
% auto = data.Auto(data.CurrentAuto,:);
data.Auto(data.CurrentAuto,5) = -1;
set(handles.MainImage,'UserData',data)
% Setup case for last datapoint behaviour
if data.CurrentAuto == length(data.Auto)
    set(hObject,'Enable','off')
    % NextUnclassified data in project to disk
    FileUserData = get(handles.OpenFile,'UserData');
    filenumber = FileUserData.filenumber;
    FileUserData.Project = get(handles.ProjectName,'String');
       
    MainImageUserData = get(handles.MainImage,'UserData');
    MainImageUserData = rmfield(MainImageUserData,'CurrentImage');
    MainImageUserData = rmfield(MainImageUserData,'OriginalImage');
    MainImageUserData = rmfield(MainImageUserData,'CurrentLocation');
    MainImageUserData = rmfield(MainImageUserData,'CurrentAuto');
       
    OpenFolderUserData = get(handles.OpenFolder,'UserData');
    directoryname = OpenFolderUserData.path;
    saveproject = [directoryname '\' FileUserData.Project];
    
    % Check for exisitng project file
    ProjectExist = exist(saveproject, 'file');
    if ~ProjectExist
        load(saveproject);
    end
%     Project = rmfield(Project,'Project');
    % Add file, MainImage and line info to Project structure
    Project(filenumber).File = FileUserData;
    Project(filenumber).MainImage = MainImageUserData;
    Project(filenumber).LineSetup = get(handles.LineSetupPanel,'UserData');
    save(saveproject,'Project')
%     return
end


Next_Callback(handles.Next, eventdata, handles)

% --- Executes on button press in UNDO.
function UNDO_Callback(hObject, eventdata, handles)
% hObject    handle to UNDO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = get(handles.MainImage,'UserData');
auto = data.Auto(data.CurrentAuto,:);
data.Auto(data.CurrentAuto,5) = 0;
set(handles.MainImage,'UserData',data)

% Update Classified
Remaining = find(data.Auto(:,5)==0);
set(handles.ClassifiedText,'String',sprintf('Unclassified: %d',length(Remaining)))
% Update MainImage
MainImageKids = get(handles.MainImage,'Children');
for n = 1:length(MainImageKids)
    if strcmp(get(MainImageKids(n),'Tag'),'LocationMarker')
        if auto(4)==0
            set(MainImageKids(n),'XData',auto(1),'YData',auto(2),...
                'Marker','v','MarkerFaceColor','y')
            if data.Auto(data.CurrentAuto,5)==1
                set(MainImageKids(n),'MarkerFaceColor','g',...
                    'MarkerEdgeColor','g')
            elseif data.Auto(data.CurrentAuto,5)==-1
                set(MainImageKids(n),'MarkerFaceColor','r',...
                    'MarkerEdgeColor','r')
            end
        elseif auto(4)==1
            set(MainImageKids(n),'XData',auto(1),'YData',auto(2),...
                'Marker','^','MarkerFaceColor','y')
            if data.Auto(data.CurrentAuto,5)==1
                set(MainImageKids(n),'MarkerFaceColor','g',...
                    'MarkerEdgeColor','g')
            elseif data.Auto(data.CurrentAuto,5)==-1
                set(MainImageKids(n),'MarkerFaceColor','r',...
                    'MarkerEdgeColor','r')
            end
        end
    end
end
% Update ZoomImage
ZoomPopup_Callback(handles.ZoomPopup, eventdata, handles)
% Update LineProfile
LineProfileKids = get(handles.LineProfile,'Children');
LineProfileData = get(handles.LineProfile,'UserData');
for n = 1:length(LineProfileKids)
    switch LineProfileData.LineOrientation
        case 'Horizontal'
            orientation = 'Horizontal';
            if strcmp(get(LineProfileKids(n),'Tag'),'LocationMarker')
                if auto(4)==0
                    set(LineProfileKids(n),'XData',auto(1),'YData',auto(3),...
                        'Marker','v','MarkerFaceColor','y')
                    if data.Auto(data.CurrentAuto,5)==1
                        set(LineProfileKids(n),'MarkerFaceColor','g',...
                        'MarkerEdgeColor','g')
                    elseif data.Auto(data.CurrentAuto,5)==-1
                        set(LineProfileKids(n),'MarkerFaceColor','r',...
                    'MarkerEdgeColor','r')
                    end
                elseif auto(4)==1
                    set(LineProfileKids(n),'XData',auto(1),'YData',auto(3),...
                        'Marker','^','MarkerFaceColor','y')
                    if data.Auto(data.CurrentAuto,5)==1
                        set(LineProfileKids(n),'MarkerFaceColor','g',...
                        'MarkerEdgeColor','g')
                    elseif data.Auto(data.CurrentAuto,5)==-1
                        set(LineProfileKids(n),'MarkerFaceColor','r',...
                    'MarkerEdgeColor','r')
                    end
                end
            end
        case 'Vertical'
            orientation = 'Horizontal';
            if strcmp(get(LineProfileKids(n),'Tag'),'LocationMarker')
                if auto(4)==0
                    set(LineProfileKids(n),'XData',auto(2),'YData',auto(3),...
                        'Marker','v','MarkerFaceColor','y')
                    if data.Auto(data.CurrentAuto,5)==1
                        set(LineProfileKids(n),'MarkerFaceColor','g',...
                        'MarkerEdgeColor','g')
                    elseif data.Auto(data.CurrentAuto,5)==-1
                        set(LineProfileKids(n),'MarkerFaceColor','r',...
                    'MarkerEdgeColor','r')
                    end
                elseif auto(4)==1
                    set(LineProfileKids(n),'XData',auto(2),'YData',auto(3),...
                        'Marker','^','MarkerFaceColor','y')
                    if data.Auto(data.CurrentAuto,5)==1
                        set(LineProfileKids(n),'MarkerFaceColor','g',...
                        'MarkerEdgeColor','g')
                    elseif data.Auto(data.CurrentAuto,5)==-1
                        set(LineProfileKids(n),'MarkerFaceColor','r',...
                    'MarkerEdgeColor','r')
                    end
                end
            end
    end
end
% Update ZoomProfile
LineKids = get(handles.LineProfile,'Children');
ZoomKids = get(handles.ZoomProfile,'Children');
delete(ZoomKids)
ZoomKids = copyobj(LineKids,handles.ZoomProfile);
% NextUnclassified data in project to disk
% FileUserData = get(handles.OpenFile,'UserData');
% filenumber = FileUserData.filenumber;
% FileUserData.Project = get(handles.ProjectName,'String');
% Project(filenumber).File = FileUserData;
% 
% MainImageUserData = get(handles.MainImage,'UserData');
% MainImageUserData = rmfield(MainImageUserData,'CurrentImage');
% MainImageUserData = rmfield(MainImageUserData,'OriginalImage');
% MainImageUserData = rmfield(MainImageUserData,'CurrentLocation');
% MainImageUserData = rmfield(MainImageUserData,'CurrentAuto');
% Project(filenumber).MainImage = MainImageUserData;
% 
% Project(filenumber).LineSetup = get(handles.LineSetupPanel,'UserData');
% OpenFolderUserData = get(handles.OpenFolder,'UserData');
% directoryname = OpenFolderUserData.path;
% saveproject = [directoryname '\' FileUserData.Project];
% save(saveproject,'Project')


% --- Executes on button press in OpenFile.
function OpenFile_Callback(hObject, eventdata, handles)
% hObject    handle to OpenFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get file data to store in OpenFile UserData for later use (e.g. saving)
UserData = get(handles.OpenFile,'UserData');
list_entries = get(handles.Files,'String');
index_selected = get(handles.Files,'Value');
if length(index_selected) > 1
    error('ManSeg:Files', 'Select only one file')
end
file=list_entries(index_selected);
file=char(file);
filepath = UserData.filepath;%TODO Fix bug that filepath does not exist 
% until user changes the selected image in the files list. Edit OpenFolder function
% 2013-11-04 15:27 fixed in v0.35: Error was because set FileData did not
% include filepath, therefore OpenFile erased its own data.
FileData.file = file;
FileData.files = list_entries;
FileData.filenumber = index_selected;
FileData.filepath = filepath;
OpenFolderData = get(handles.OpenFolder,'UserData');
directoryname = OpenFolderData.path;
FileData.directoryname = directoryname;
set(handles.OpenFile,'UserData',FileData)
% Get info about selected image
info = imfinfo(filepath);
[pathstr, name, ext] = fileparts(filepath);

pause on
PixSizeSet=0;
if  strcmp(info.Format,'tif')
    %     Check for tiff and treat accordingly
    if isfield(info, 'UnknownTags') && isfield(info.UnknownTags, 'Value')
        % Check for Zeiss
        Microscope = ['Zeiss'];
        ZeissParams = info.UnknownTags.Value;
        data.ZeissParams = ZeissParams;
        [PixelSize,s,e] = regexp(ZeissParams, 'Image Pixel Size = \w*\.\w*\s\wm','match','start','end');
        [unit,us,ue] = regexp(PixelSize,'[n|µ]m','match','start','end');
        [pix,pixs,pixe] = regexp(PixelSize,'\d*\.\d*','match','start','end');
        if isempty(PixelSize) % BUGFIX 2013-11-26 allow for older versions of SMARTSEM with limited tiff headers
            [PixelSize,s,e] = regexp(ZeissParams, 'Pixel Size = \w*\.\w*\s\wm','match','start','end');
            [unit,us,ue] = regexp(PixelSize,'[n|µ]m','match','start','end');
            [pix,pixs,pixe] = regexp(PixelSize,'\d*\.\d*','match','start','end');
        end
        if isempty(PixelSize)
            warndlg('ManSeg could not read the image pixel size. Set pixel size manually', ...
                'ManSeg:ZeissPixSizeNotRead')
            pause(3)
        else
            pixel = str2num(char(pix{1,1}));
            switch char(unit{1,1});
                case 'nm'
                    pixel = pixel/1000;
                case 'µm'
                    pixel = pixel;
            end
            set(handles.PixelSizeEdit,'String',num2str(pixel))
        end
        PixelSizeEdit_Callback(handles.PixelSizeEdit, eventdata, handles)
        CurrentImage = imread(filepath);
        PixSizeSet=1;
    end
end
% Check for Hitachi Images
if ~PixSizeSet
    AuxTextFile=[pathstr,'\',name,'.txt'];
    ImagefileID = fopen(AuxTextFile);
    if ImagefileID>0
        AuxText = textscan(ImagefileID, '%s');
        AuxText2=AuxText{1};
        for HitachiParam=1:length(AuxText2)
%             AuxText2{HitachiParam}
            [PixelSize,s,e] = regexp(char(AuxText2{HitachiParam}), 'PixelSize=','match','start','end');
            if ~isempty(PixelSize)
                [PS,PSs,PSe] = regexp(char(AuxText2{HitachiParam}), '\d*,\d*','match','start','end');
                s = regexprep(PS, ',', '.');
                pixel=str2num(char(s))/1000;
                set(handles.PixelSizeEdit,'String',num2str(pixel))
                break
            else
                continue
            end
            
        end
    fclose(ImagefileID); % 2013-08-06: Moved as not possible to close file if none was opened
    else
        warndlg('ManSeg could not not find a Hitachi auxilary file. If you are trying to read a Hitachi file move a copy of the corresponding text file to the image folder', ...
            'ManSeg:NoHitachiAuxFile')
        pause(3)
    end 
end
PixelSizeEdit_Callback(handles.PixelSizeEdit, eventdata, handles)
CurrentImage = imread(filepath);
% Account for colour images. If image is an RGB image take only R plane.
% Hitachi Images are usually greyscale images in RGB format. Also account
% for reduction in bit depth
BitDepth=info.BitDepth;
if size(CurrentImage,3)>1
    CurrentImage=CurrentImage(:,:,1);
    BitDepth=BitDepth/3;
end
% PixSizeSet=1;
pause off
% Set focus to Main Axes and plot image
axes(handles.MainImage);
imagesc(CurrentImage,[0 2^BitDepth])
set(handles.MainImage,'XColor',[1 .5 0],'YColor',[1 .5 0],...
    'GridLineStyle',':','MinorGridLineStyle',':',...
    'XGrid','on','YGrid','on','Layer','top',...
    'XMinorGrid','off','YMinorGrid','off','Layer','top')
AxesKids=get(gca,'Children');
% set(handles.MainImage,'ButtonDownFcn','@(hObject,eventdata)ManSeg(''MainImage_ButtonDownFcn'',hObject,eventdata,guidata(hObject))')
set(AxesKids,'ButtonDownFcn',{@MainImage_ButtonDownFcn,handles});
colormap gray
% Set ManSeg version
Version = 'v0.37';
data = get(handles.MainImage,'UserData');
data.Version = Version;
% Store CurrentImage in MainImage UserData
data.CurrentImage = CurrentImage;
data.OriginalImage = CurrentImage;
data.info = info;
% Initialise position of CurrentLocation for ZoomAxes view
CurrentLocation(1) = round(info.Height/2);
CurrentLocation(2) = round(info.Width/2);
data.CurrentLocation = CurrentLocation;
set(handles.LocationText,'String',sprintf('Current Location\n [%d %d]',CurrentLocation(1),CurrentLocation(2)))
% Write UserData to MainAxes figure
set(handles.MainImage,'UserData',data)
% Plot zoom of image data in ZoomAxes according to ZoomPopup
ZoomPopup_Callback(handles.ZoomPopup, eventdata, handles)
% Plot CurrentLocation marker


% Set Line profile Y axis max and min to bit depth given by imfinfo
set(handles.LineProfile,'Ylim',[0 2^info.BitDepth])
set(handles.ZoomProfile,'Ylim',[0 2^info.BitDepth])

% TODO
% Fix ButtonDown callback so that full image size opens in new figure
% open jpeg

% --- Executes on button press in OpenFolder.
function OpenFolder_Callback(hObject, eventdata, handles)
% hObject    handle to OpenFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
UserData = get(hObject,'UserData');
if isfield(UserData, 'path')
     directoryname = uigetdir(UserData.path, 'Select a Folder');
 else
     directoryname = uigetdir(pwd, 'Select a Folder');
%      directoryname = uigetdir('', 'Select a Folder'); Delete above line
%      after developing
end
if directoryname == 0
    return
end
D = dir(directoryname);
C = struct2cell(D);
filenames=C(1,3:end);
% Filter out non images (take only tifs and jpgs
NotImage=zeros(1,length(filenames)); % Initialise index of unintersting files
for pics=1:length(filenames)
    filepath = char(filenames(1,pics));
    [pathstr, name, ext] = fileparts(filepath);
    if ~strcmp(ext,'.tif')
        if ~strcmp(ext,'.jpg')
            NotImage(pics)=1;
        end
    end
end
filenames=filenames(~NotImage);% v0.31 BUGFIX: filenames(NotImage(NotImage==1))=[];
%  Put file names in selected folder into the Files list box for selection
set(handles.Files,'String',filenames)
%  Store the directory name in OpenFolders (this callback) UserData
data.path = directoryname;
set(handles.Path,'String',directoryname)
set(hObject,'UserData',data)
%  Setup OpenFile_Callback with starting file path
list_entries = get(handles.Files,'String');
file=list_entries(1);
file=char(file);
% UserData = get(handles.OpenFolder,'UserData');
% directoryname = UserData.path;
filepath = fullfile(directoryname,file);
UserData.filepath = filepath;
set(handles.OpenFile,'UserData',data)
% Activate Project
set(handles.ProjectName,'Enable','on')
% Update Files UserData

% Completed
 
% --- Executes on selection change in Files.
function Files_Callback(hObject, eventdata, handles)
% hObject    handle to Files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Files contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Files
list_entries = get(handles.Files,'String');
index_selected = get(handles.Files,'Value');
if length(index_selected) > 1
    error('ManSeg:Files', 'Select only one file')
end
file=list_entries(index_selected);
file=char(file);
UserData = get(handles.OpenFolder,'UserData');
directoryname = UserData.path;
filepath = fullfile(directoryname,file);
%  Put fullpath (i.e. selceted file in the Files list into the OpenFile
%  button's UserData
 data.filepath = filepath;
 data.file = file;
 data.files = list_entries;
 data.filenumber = index_selected;
 data.directoryname = directoryname;
 set(handles.OpenFile,'UserData',data)
%  Completed

% --- Executes during object creation, after setting all properties.
function Files_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in PevImage.
function PevImage_Callback(hObject, eventdata, handles)
% hObject    handle to PevImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
list_entries = get(handles.Files,'String');
index_selected = get(handles.Files,'Value');
if index_selected == 1
    index_selected = length(list_entries)+1;
end

file=list_entries(index_selected-1);
set(handles.Files,'Value',index_selected-1);
file=char(file);
UserData = get(handles.OpenFolder,'UserData');
directoryname = UserData.path;
filepath = [directoryname '\' file];
%  Put fullpath (i.e. selceted file in the Files list into the OpenFile
%  button's UserData
data.filepath = filepath;
set(handles.OpenFile,'UserData',data)

OpenFile_Callback(handles.OpenFile, eventdata, handles)
% TODO
% Handle case of analysed data

% --- Executes on button press in NextImage.
function NextImage_Callback(hObject, eventdata, handles)
% hObject    handle to NextImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
list_entries = get(handles.Files,'String');
index_selected = get(handles.Files,'Value');
if index_selected == length(list_entries)
    index_selected = 0;
end

file=list_entries(index_selected+1);
set(handles.Files,'Value',index_selected+1);
file=char(file);
UserData = get(handles.OpenFolder,'UserData');
directoryname = UserData.path;
filepath = [directoryname '\' file];
%  Put fullpath (i.e. selceted file in the Files list into the OpenFile
%  button's UserData
data.filepath = filepath;
set(handles.OpenFile,'UserData',data)

OpenFile_Callback(handles.OpenFile, eventdata, handles)
% TODO
% Handle case of analysed data

% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on button press in Output.
function Output_Callback(hObject, eventdata, handles)
% hObject    handle to Output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check if project name has been set
if strcmp(get(handles.ProjectName,'String'),'Enter project name')
    h = warndlg('Please give your project a name.','No project name');
    uiwait(h)
    return
else Project.Project = get(handles.ProjectName,'String');
end
% Get results output saving location
UserData = get(handles.OpenFolder,'UserData');
if isfield(UserData, 'path')
     directoryname = uigetdir(UserData.path, 'Select a Folder');
 else
     directoryname = uigetdir(pwd, 'Select a Folder');
%      directoryname = uigetdir('', 'Select a Folder'); Delete above line
%      after developing
end
if directoryname == 0
    return
end
OutputPath = [directoryname '\' Project.Project '.txt'];
set(handles.OutPutPath,'String',OutputPath)
% BIG FIX needed here - does not like spaces in path
data.OutputPath = OutputPath;
data.Project = Project.Project;
set(handles.Export,'UserData',data)
% Create ManSeg output project data structure
% SAVE!
saveproject = fullfile(directoryname,Project.Project);
save(saveproject,'Project')
% Enable analysis
set(handles.Start,'Enable','on')
% Activate Select Open FIle, Previous & Next Image
set(handles.OpenFile,'Enable','on')
set(handles.PevImage,'Enable','on')
set(handles.NextImage,'Enable','on')
% Control access to other features
set(handles.MedFilt,'Enable','on')


% --- Executes on button press in NextUnclassified.
function NextUnclassified_Callback(hObject, eventdata, handles)
% hObject    handle to NextUnclassified (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = get(handles.MainImage,'UserData');
classify = data.Auto(:,5);
Unclassified = find(classify==0);
if length(Unclassified)>0
    data.CurrentAuto = Unclassified(1) - 1;
    set(handles.MainImage,'UserData',data)
    Next_Callback(handles.Next, eventdata, handles)
else h = msgbox('There are no more interfaces to classify','Line finished!','help');
end


% % Enable export
% set(handles.Export,'Enable','on')
% TODO

% --- Executes on button press in Export.
function Export_Callback(hObject, eventdata, handles)
% hObject    handle to Export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% TODO

% --- Executes when selected object is changed in MainAxesOnOff.
function MainAxesOnOff_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in MainAxesOnOff 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

% Use MainAxesOnOff handle to get the SelectedObject. Use the handle in
% SelectedObject to detemine which radio button handle is active and then
% switch axis on or off
axes(handles.MainImage);
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'MainAxesOn'
        % Turn axis on.
        axis on
    case 'MainAxesOff'
        % Turn axis off.
        axis off
    otherwise
end
% Complete

% --- Executes when selected object is changed in ZoomAxes.
function ZoomAxes_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in ZoomAxes 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

% Use ZoomAxesOnOff handle to get the SelectedObject. Use the handle in
% SelectedObject to detemine which radio button handle is active and then
% switch axis on or off
axes(handles.ZoomImage);
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'ZoomAxesOn'
        % Turn axis on.
        axis on
    case 'ZoomAxesOff'
        % Turn axis off.
        axis off
    otherwise
end
% Complete

% --- Executes on mouse press over axes background.
function ZoomImage_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ZoomImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure

% --- Executes during object creation, after setting all properties.
function MainImage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MainImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate MainImage

% --- Executes on mouse press over axes background.
function MainImage_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to MainImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure
data = get(handles.MainImage,'UserData');
imagesc(data.CurrentImage,[0 2^data.info.BitDepth])
axis image
colormap gray

% --- Executes when selected object is changed in MainColorMap.
function MainColorMap_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in MainColorMap 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
axes(handles.MainImage);
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'MainGrey'
        % Set colour map to grey.
        colormap gray
    case 'MainJet'
        % Set colour map to jet.
        colormap jet
    otherwise
end

% --- Executes on selection change in ZoomPopup.
function ZoomPopup_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = get(handles.MainImage,'UserData');
% axes(handles.ZoomImage);
Zoom = get(handles.ZoomPopup,'String');
SelectedZoom = get(handles.ZoomPopup,'Value');
Padding = Zoom(SelectedZoom);
Padding = Padding{1};
Padding = str2num(Padding);
% Draw new figure method - uncomment all lines between ****
% ****
MinRow = data.CurrentLocation(1)-Padding;
MaxRow = data.CurrentLocation(1)+Padding;
MinCol = data.CurrentLocation(2)-Padding;
MaxCol = data.CurrentLocation(2)+Padding;
ZoomCol = Padding + 1;
ZoomRow = Padding + 1;
if MinRow < 1
    MaxRow = MaxRow + abs(MinRow);
    ZoomRow = ZoomRow - (abs(MinRow));
    MinRow = 1;
end
if MaxRow > data.info.Height
    MinRow = MinRow - (MaxRow - data.info.Height);
    ZoomRow = ZoomRow + (MaxRow - data.info.Height);
    MaxRow = data.info.Height;
end
if MinCol < 1
    MaxCol = MaxCol + abs(MinCol);
    ZoomCol = ZoomCol - (abs(MinCol))-1;
    MinCol = 1;
end
if MaxCol > data.info.Height
    MinCol = MinCol - (MaxCol - data.info.Width);
    ZoomCol = ZoomCol + (MaxCol - data.info.Width);
    MaxCol = data.info.Width;
end

% ZoomKids=get(handles.ZoomImage,'Children');
% if isempty(ZoomKids)
%     imagesc(data.CurrentImage(MinRow:MaxRow,MinCol:MaxCol),[0 2^data.info.BitDepth])
% end
Zoomdata.Padding=Padding;
% data.ZoomLocation = [ZoomRow ZoomCol];
% Set ZoomAxes limits according to line direction
if isfield(data,'Mode')
    switch data.Mode
        case 'Single Horizontal'
            set(handles.ZoomProfile,'xlim',...
                [data.CurrentLocation(2)-Padding data.CurrentLocation(2)+Padding],...
                'YLimMode','auto')
%             ZoomProfileKids = get(handles.ZoomProfile,'Children');
%             delete(ZoomProfileKids)
%             LineProfileKids = get(handles.LineProfile,'Children');
%             ZoomProfileKids = copyobj(LineProfileKids,handles.ZoomProfile);
        case 'Single Vertical'
            set(handles.ZoomProfile,'xlim',...
                [data.CurrentLocation(1)-Padding data.CurrentLocation(1)+Padding],...
                'YLimMode','auto')
%             ZoomProfileKids = get(handles.ZoomProfile,'Children');
%             delete(ZoomProfileKids)
%             LineProfileKids = get(handles.LineProfile,'Children');
%             ZoomProfileKids = copyobj(LineProfileKids,handles.ZoomProfile);
    end
else ZoomProfileKids = get(handles.ZoomProfile,'Children');
    delete(ZoomProfileKids)
    LineProfileKids = get(handles.LineProfile,'Children');
    delete(LineProfileKids)
end
set(hObject,'UserData',Zoomdata)
ZoomData.ZoomLocation = [ZoomRow ZoomCol];
set(handles.ZoomImage,'UserData',ZoomData)
% ****
% Copy Figure handles method
MainImageKids = get(handles.MainImage,'Children');
ZoomImageKids = get(handles.ZoomImage,'Children');
delete(ZoomImageKids)
ZoomImageKids = copyobj(MainImageKids,handles.ZoomImage);
% UnusedH = axes(handles.ZoomImage);
% axis ij
axis(handles.ZoomImage,'ij')
box(handles.ZoomImage,'on')
Padding = get(handles.ZoomPopup,'UserData');
Padding = Padding.Padding;
set(handles.ZoomImage,...
    'xlim',[data.CurrentLocation(2)-Padding data.CurrentLocation(2)+Padding],...
    'ylim',[data.CurrentLocation(1)-Padding data.CurrentLocation(1)+Padding])

% Hints: contents = cellstr(get(hObject,'String')) returns ZoomPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ZoomPopup

% --- Executes during object creation, after setting all properties.
function ZoomPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ZoomPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes when selected object is changed in ZoomColorMap.
function ZoomColorMap_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in ZoomColorMap 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
axes(handles.ZoomImage);
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'ZoomGrey'
        % Set colour map to grey.
        colormap gray
    case 'ZoomJet'
        % Set colour map to jet.
        colormap jet
    otherwise
end

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over HorizPosSlide.
function HorizPosSlide_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to HorizPosSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Turn off vertical line control
set(handles.VerPosSlide,'Enable','off')
set(handles.VerPosText,'Enable','off')
set(handles.VerPosLab,'Enable','off')
% Turn on horizontal line control
set(handles.HorizPosSlide,'Enable','on')
set(handles.HorizPosText,'Enable','on')
set(handles.HorizPosLab,'Enable','on')

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over HorizPosText.
function HorizPosText_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to HorizPosText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
HorizPosSlide_ButtonDownFcn(handles.HorizPosSlide,eventdata,handles)

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over HorizPosLab.
function HorizPosLab_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to HorizPosLab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
HorizPosSlide_ButtonDownFcn(handles.HorizPosSlide,eventdata,handles)

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over VerPosSlide.
function VerPosSlide_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to VerPosSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Turn off horizontal line control
set(handles.HorizPosSlide,'Enable','off')
set(handles.HorizPosText,'Enable','off')
set(handles.HorizPosLab,'Enable','off')
% Turn on vertical line control
set(handles.VerPosSlide,'Enable','on')
set(handles.VerPosText,'Enable','on')
set(handles.VerPosLab,'Enable','on')

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over VerPosText.
function VerPosText_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to VerPosText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Turn off horizontal line control
VerPosSlide_ButtonDownFcn(handles.VerPosSlide,eventdata,handles)

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over VerPosLab.
function VerPosLab_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to VerPosLab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Turn off horizontal line control
VerPosSlide_ButtonDownFcn(handles.VerPosSlide,eventdata,handles)

% --- Executes on button press in Start.
function Start_Callback(hObject, eventdata, handles)
% hObject    handle to Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Lock phases
data = get(handles.MainImage,'UserData');
PhaseNum = str2double(get(handles.PhaseNumText,'String'));
PhaseLock = questdlg('Phase Names will now be locked, do you wish to rename them?',...
    'Locking Phases!','Yes','No','Cancel','No');
% Ensure the user has selected a test line: added 2017-08-22 JRBO
if ~isfield(data,'CurrentLineIntensity')
    errordlg('Please select a testline before starting')
    return
else
end

switch PhaseLock
    case 'Yes'
        for n = 1:PhaseNum
            eval(['set(handles.Phase',num2str(n),'Edit,''Enable'',''on'')'])
%             eval(['set(handles.Phase',num2str(n),'Text,''Enable'',''on'')'])
        end
        return
    case 'No'
        for n = 1:PhaseNum
            eval(['set(handles.Phase',num2str(n),'Edit,''Enable'',''off'')'])
%             eval(['set(handles.Phase',num2str(n),'Text,''Enable'',''off'')'])
        end
    case 'Cancel'
        return
end
% Save phase information into MainImage UserData
data.PhaseInfo =  get(handles.PhasePanel,'UserData');
set(handles.MainImage,'UserData',data)
data = get(handles.MainImage,'UserData');
% Control access to parameters
set(handles.HorizPosSlide,'Enable','off')
set(handles.HorizPosText,'Enable','off')
set(handles.HorizPosLab,'Enable','off')
set(handles.VerPosSlide,'Enable','off')
set(handles.VerPosText,'Enable','off')
set(handles.VerPosLab,'Enable','off')
set(handles.AngleSlide,'Enable','off')
set(handles.AngleText,'Enable','off')
set(handles.AngleLab,'Enable','off')
set(handles.LinePercLab,'Enable','off')
set(handles.LinePercText,'Enable','off')
set(handles.LinePercSlide,'Enable','off')
set(handles.BasicIntThrLab,'Enable','off')
set(handles.BasicIntThrText,'Enable','off')
set(handles.BasicIntThrSlide,'Enable','off')
set(handles.HorizGrdPitLab,'Enable','off')
set(handles.HorizGrdPitText,'Enable','off')
set(handles.HorizGrdPitSlide,'Enable','off')
set(handles.VerGrdPitLab,'Enable','off')
set(handles.VerGrdPitText,'Enable','off')
set(handles.VerGrdPitSlide,'Enable','off')
set(handles.PhaseNumLab,'Enable','off')
set(handles.PhaseNumText,'Enable','off')
set(handles.PhaseNumSlide,'Enable','off')
set(handles.PixelSizeLab,'Enable','off')
set(handles.PixelSizeEdit,'Enable','off')
set(handles.PixelSizeSlide,'Enable','off')
set(handles.SingLineBut,'Enable','off')
set(handles.GridBut,'Enable','off')
set(handles.SingCircBut,'Enable','off')
set(handles.ConcCircBut,'Enable','off')
% Control access to interface navigation
set(handles.Start,'Enable','off')
set(handles.Stop,'Enable','on')
set(handles.Previous,'Enable','off')
set(handles.Next,'Enable','on')
set(handles.YES,'Enable','on')
set(handles.NO,'Enable','on')
set(handles.UNDO,'Enable','on')
set(handles.NextUnclassified,'Enable','on')
set(handles.Export,'Enable','off')
% Control access to file navigation
set(handles.ProjectName,'Enable','off')
set(handles.OpenFile,'Enable','off')
set(handles.OpenFolder,'Enable','off')
set(handles.Files,'Enable','off')
set(handles.PevImage,'Enable','off')
set(handles.NextImage,'Enable','off')
set(handles.Output,'Enable','off')
% Control access to other features
set(handles.MedFilt,'Enable','off')
% Store Line Setup params in LineSetupPanel
data.HorizontalPosition = get(handles.HorizPosSlide,'Value');
data.VerticalPosition = get(handles.HorizPosSlide,'Value');
data.Angle = get(handles.HorizPosSlide,'Value');
data.LinePercentage = get(handles.LinePercSlide,'Value');
data.BasicIntensityThreshold = get(handles.BasicIntThrSlide,'Value');
data.HorizontalGridPitch = get(handles.HorizGrdPitSlide,'Value');
data.VerticalGridPitch = get(handles.VerGrdPitSlide,'Value');
data.NumberOfPhases = get(handles.PhaseNumSlide,'Value');
data.PixelSize = get(handles.PixelSizeSlide,'Value');
set(handles.LineSetupPanel,'UserData',data)

% Activate CurrentLocation information
set(handles.LocationText,'Enable','on')
% Perform basic operations on extracted line profile
CurrentLineIntensity = data.CurrentLineIntensity;
% Take first derivative
dCurrentLineIntensity=diff(double(CurrentLineIntensity));
% Correct slope location in terms of CurrentLineIntensity after differential
dx=1:length(CurrentLineIntensity)-1;
% determine averave slope based on nearest neighbours in dCurrentLineIntensity
MeanLineSlope=(dCurrentLineIntensity(2:end)+dCurrentLineIntensity(1:end-1))/2;
% Locate the local slope maxima and minima and get their co-ordinates
MaxMeanLineSlope=imregionalmax(MeanLineSlope);
MinMeanLineSlope=imregionalmin(MeanLineSlope);
LocalMax = find(MaxMeanLineSlope);
LocalMin = find(MinMeanLineSlope);
% Correct slope location in terms of CurrentLineIntensity after smoothing
dx2=dx(2:end);
% Trim CurrentLineIntensity to match dx2
CLI = CurrentLineIntensity(2:end-1);
% Extract auto detected edge pixel locations and intensities
switch get(handles.LineSetupPanel,'SelectedObject')
    case handles.SingLineBut
        % Set Interface Statistics, Current Line
        set(handles.CurrentLine,'String','Current Line 1/1')
        switch length(CurrentLineIntensity)
            case data.info.Width
%                 disp('Horizontal Line')
                AutoMin(:,1) = dx2(MinMeanLineSlope); % AutoMinX
                AutoMin(:,2) = uint16(ones(length(dx2(MinMeanLineSlope)),1))*data.LineRowNo; %AutoMinY
                AutoMin(:,3) = CLI(MinMeanLineSlope); % AutoMinI
                AutoMin(:,4) = uint16(zeros(length(dx2(MinMeanLineSlope)),1));
                AutoMax(:,1) = dx2(MaxMeanLineSlope); % AutoMaxX
                AutoMax(:,2) = uint16(ones(length(dx2(MaxMeanLineSlope)),1))*data.LineRowNo; % AutoMaxY
                AutoMax(:,3) = CLI(MaxMeanLineSlope); % AutoMaxI
                AutoMax(:,4) = uint16(ones(length(dx2(MaxMeanLineSlope)),1));
                Auto = cat(1,AutoMin,AutoMax);
                % Create Auto column 5 to mark manual identification of
                % boundaries. 0 = auto detected & unclassified, 1 =
                % identified boundaries, -1 = false boundaries
                Auto(:,5) = 0;
                data.Auto = sortrows(Auto,1);
                data.Mode = 'Single Horizontal';
                % Initalise CurrentLocation
                data.CurrentLocation(1) = data.Auto(1,2);
                data.CurrentLocation(2) = data.Auto(1,1);
                set(handles.LocationText,'String',sprintf('Current Location\n [%d %d]',data.CurrentLocation(1),data.CurrentLocation(2)))
                 % Store Auto data and CurrentLocation in MainImage's UserData
                 set(handles.MainImage,'UserData',data)   
                % Plot CurrentLocation marker in MainImage
                MainImageKids = get(handles.MainImage,'Children');
                for n=1:length(MainImageKids)
                    if strcmp(get(MainImageKids(n),'Tag'),'LocationMarker')
                        delete(MainImageKids(n))
                    else
                    end
                end
                axes(handles.MainImage)
                LocationMarker = line(Auto(1,1),Auto(1,2),...
                    'LineStyle','none','MarkerEdgeColor','r',...
                    'Marker','o','Tag','LocationMarker');
                data.LocationMarker = LocationMarker;
                data.CurrentAuto = 1;
                set(handles.MainImage,'UserData',data)
                % UpdateZoomImage with CurrentLocation
                ZoomPopup_Callback(handles.ZoomPopup, eventdata, handles)
                % Plot CurrentLocation marker in LineProfile
                axes(handles.LineProfile)
                LineProfData.LocationMarker = line(Auto(1,1),Auto(1,3),...
                    'LineStyle','none','MarkerEdgeColor','r',...
                    'Marker','o','Tag','LocationMarker');
                LineProfData.LineOrientation = 'Horizontal';
                set(handles.LineProfile,'UserData',LineProfData)
                % Plot CurrentLocation marker in ZoomProfile
                LineKids = get(handles.LineProfile,'Children');
                ZoomKids = get(handles.ZoomProfile,'Children');
                delete(ZoomKids)
                ZoomKids = copyobj(LineKids,handles.ZoomProfile);
                Padding = get(handles.ZoomPopup,'UserData');
                Padding = Padding.Padding;
                set(handles.ZoomProfile,'xlim',[data.CurrentLocation(2)-Padding data.CurrentLocation(2)+Padding])
                % Set Interface statistics, number of interfaces detected
                set(handles.InterfaceText,'String',sprintf('%d Interfaces',length(Auto)))
            case data.info.Height
%                 disp('Vertical Line')
                AutoMin(:,2) = dx2(MinMeanLineSlope); % AutoMinY
                AutoMin(:,1) = uint16(ones(length(dx2(MinMeanLineSlope)),1))*data.LineColNo; %AutoMinX
                AutoMin(:,3) = CLI(MinMeanLineSlope); % AutoMinI
                AutoMin(:,4) = uint16(zeros(length(dx2(MinMeanLineSlope)),1));
                AutoMax(:,2) = dx2(MaxMeanLineSlope); % AutoMaxY
                AutoMax(:,1) = uint16(ones(length(dx2(MaxMeanLineSlope)),1))*data.LineColNo; % AutoMaxX
                AutoMax(:,3) = CLI(MaxMeanLineSlope); % AutoMaxI
                AutoMax(:,4) = uint16(ones(length(dx2(MaxMeanLineSlope)),1));
                Auto = cat(1,AutoMin,AutoMax);
                % Create Auto column 5 to mark manual identification of
                % boundaries. 0 = auto detected & unclassified, 1 =
                % identified boundaries, -1 = false boundaries
                Auto(:,5) = 0;
                data.Auto = sortrows(Auto,2);
                data.Mode = 'Single Vertical';
                % Initalise CurrentLocation
                data.CurrentLocation(1) = data.Auto(1,2);
                data.CurrentLocation(2) = data.Auto(1,1);
                set(handles.LocationText,'String',sprintf('Current Location\n [%d %d]',data.CurrentLocation(1),data.CurrentLocation(2)))
                 % Store Auto data and CurrentLocation in MainImage's UserData
                 set(handles.MainImage,'UserData',data)   
                % Plot CurrentLocation marker in MainImage
                MainImageKids = get(handles.MainImage,'Children');
                for n=1:length(MainImageKids)
                    if strcmp(get(MainImageKids(n),'Tag'),'LocationMarker')
                        delete(MainImageKids(n))
                    else
                    end
                end
                axes(handles.MainImage)
                LocationMarker = line(Auto(1,1),Auto(1,2),...
                    'LineStyle','none','MarkerEdgeColor','r',...
                    'Marker','o','Tag','LocationMarker');
                data.LocationMarker = LocationMarker;
                data.CurrentAuto = 1;
                set(handles.MainImage,'UserData',data)
                % UpdateZoomImage with CurrentLocation
                ZoomPopup_Callback(handles.ZoomPopup, eventdata, handles)
                % Plot CurrentLocation marker in LineProfile
                axes(handles.LineProfile)
                LineProfData.LocationMarker = line(Auto(1,2),Auto(1,3),...
                    'LineStyle','none','MarkerEdgeColor','r',...
                    'Marker','o','Tag','LocationMarker');
                LineProfData.LineOrientation = 'Vertical';
                set(handles.LineProfile,'UserData',LineProfData)
                % Plot CurrentLocation marker in ZoomProfile
                LineKids = get(handles.LineProfile,'Children');
                ZoomKids = get(handles.ZoomProfile,'Children');
                delete(ZoomKids)
                ZoomKids = copyobj(LineKids,handles.ZoomProfile);
                Padding = get(handles.ZoomPopup,'UserData');
                Padding = Padding.Padding;
                set(handles.ZoomProfile,'xlim',[data.CurrentLocation(1)-Padding data.CurrentLocation(1)+Padding])
                % Set Interface statistics, number of interfaces detected
                set(handles.InterfaceText,'String',sprintf('%d Interfaces',length(Auto)))     
        end
        TempData = get(handles.MainImage,'UserData');  
        switch data.Mode
            case 'Single Horizontal'
                if isfield(TempData,'Rows')
                    Rows = TempData.Rows;
                    Rows(TempData.LineRowNo) = 1;
                    TempData.Rows = Rows;
                    set(handles.MainImage,'UserData',TempData)
                else Rows(TempData.LineRowNo) = 1;
                    TempData.Rows = Rows;
                    set(handles.MainImage,'UserData',TempData)
                end
            case 'Single Vertical'
                TempData = get(handles.MainImage,'UserData');
                if isfield(TempData,'Cols')
                    Cols = TempData.Cols;
                    Cols(TempData.LineColNo) = 1;
                    TempData.Cols = Cols;
                    set(handles.MainImage,'UserData',TempData)
                else Cols(TempData.LineColNo) = 1;
                    TempData.Cols = Cols;
                    set(handles.MainImage,'UserData',TempData)
                end
        end
    case handles.GridBut
    case SingCircBut
    case ConcCircBut
end
% *************************************************************************
% ****DEVELOPMENT TOOL FUNCTIONALITY ONLY**********************************
% fh = figure;
% hold on
% grid on
% plot(1:length(CurrentLineIntensity),CurrentLineIntensity,'-ob',...
%     'MarkerFaceColor','w')
% plot(x+.5,dCurrentLineIntensity,'-r','Marker','.')
% plot((1:(length(x)-1))+1,MeanLineSlope,'*k')
% x2=dx(2:end);
% CLI = CurrentLineIntensity(2:end-1);
% plot(x2(MaxMeanLineSlope),CLI(MaxMeanLineSlope),'^m','MarkerFaceColor','m')
% plot(x2(MinMeanLineSlope),CLI(MinMeanLineSlope),'vm','MarkerFaceColor','m')
% *************************************************************************
% *************************************************************************

% --- Executes on button press in Stop.
function Stop_Callback(hObject, eventdata, handles)
% hObject    handle to Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for unclassified interfaces
data = get(handles.MainImage,'UserData');
Unclassified = find(data.Auto(data.Auto(:,5)==0,:));
if length(Unclassified)>0
    button = questdlg('There are unclassified interfaces remaining, do you wish to classify them?',...
        'UNCLASSIFED INTERFACES REMAINING','Yes');
    switch button
        case 'Yes'
            NextUnclassified_Callback(handles.NextUnclassified, eventdata, handles)
            return
        case 'No'
            
        case 'Cancel'
            return
    end
end

% Control access to parameters
set(handles.AngleSlide,'Enable','on')
set(handles.AngleText,'Enable','on')
set(handles.AngleLab,'Enable','on')
set(handles.BasicIntThrLab,'Enable','on')
set(handles.BasicIntThrText,'Enable','on')
set(handles.BasicIntThrSlide,'Enable','on')
set(handles.PhaseNumLab,'Enable','on')
set(handles.PhaseNumText,'Enable','on')
set(handles.PhaseNumSlide,'Enable','on')
set(handles.PixelSizeLab,'Enable','on')
set(handles.PixelSizeEdit,'Enable','on')
set(handles.PixelSizeSlide,'Enable','on')
switch get(handles.LineSetupPanel,'SelectedObject')
    case handles.SingLineBut
        set(handles.HorizPosSlide,'Enable','on')
        set(handles.HorizPosText,'Enable','on')
        set(handles.HorizPosLab,'Enable','on')
        set(handles.VerPosSlide,'Enable','on')
        set(handles.VerPosText,'Enable','on')
        set(handles.VerPosLab,'Enable','on')
        set(handles.LinePercLab,'Enable','on')
        set(handles.LinePercText,'Enable','on')
        set(handles.LinePercSlide,'Enable','on')
    case handles.GridBut
        set(handles.HorizGrdPitLab,'Enable','on')
        set(handles.HorizGrdPitText,'Enable','on')
        set(handles.HorizGrdPitSlide,'Enable','on')
        set(handles.VerGrdPitLab,'Enable','on')
        set(handles.VerGrdPitText,'Enable','on')
        set(handles.VerGrdPitSlide,'Enable','on')
    case SingCircBut
    case ConcCircBut
end
set(handles.SingLineBut,'Enable','on')
set(handles.GridBut,'Enable','on')
set(handles.SingCircBut,'Enable','on')
set(handles.ConcCircBut,'Enable','on')
% Control access to interface navigation
set(handles.Start,'Enable','on')
set(handles.Stop,'Enable','off')
set(handles.Previous,'Enable','off')
set(handles.Next,'Enable','off')
set(handles.YES,'Enable','off')
set(handles.NO,'Enable','off')
set(handles.UNDO,'Enable','off')
set(handles.NextUnclassified,'Enable','off')
% Control access to file navigation
set(handles.ProjectName,'Enable','on')
set(handles.OpenFile,'Enable','on')
set(handles.OpenFolder,'Enable','on')
set(handles.Files,'Enable','on')
set(handles.PevImage,'Enable','on')
set(handles.NextImage,'Enable','on')
set(handles.Output,'Enable','on')
% Control access to other features
set(handles.MedFilt,'Enable','on')

% Plot segmented line profile segments
Manual = data.Auto(data.Auto(:,5)==1,:);

% --- Executes during object creation, after setting all properties.
function Start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes when selected object is changed in LineSetupPanel.
function LineSetupPanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in LineSetupPanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'SingLineBut'
        disp('Single line analysis enabled')
        % These controls off
        set(handles.HorizGrdPitLab,'Enable','off')
        set(handles.HorizGrdPitText,'Enable','off')
        set(handles.HorizGrdPitSlide,'Enable','off')
        set(handles.VerGrdPitLab,'Enable','off')
        set(handles.VerGrdPitText,'Enable','off')
        set(handles.VerGrdPitSlide,'Enable','off')
        % These controls on
        set(handles.HorizPosSlide,'Enable','on')
        set(handles.HorizPosText,'Enable','on')
        set(handles.HorizPosLab,'Enable','on')
        set(handles.VerPosSlide,'Enable','on')
        set(handles.VerPosText,'Enable','on')
        set(handles.VerPosLab,'Enable','on')
        set(handles.LinePercLab,'Enable','on')
        set(handles.LinePercText,'Enable','on')
        set(handles.LinePercSlide,'Enable','on')
        % Set Interface Statistics, Current Line
        set(handles.CurrentLine,'String','Current Line 1/1')
    case 'GridBut'
        disp('Grid analysis enabled')
        % These controls off
        set(handles.HorizPosSlide,'Enable','off')
        set(handles.HorizPosText,'Enable','off')
        set(handles.HorizPosLab,'Enable','off')
        set(handles.VerPosSlide,'Enable','off')
        set(handles.VerPosText,'Enable','off')
        set(handles.VerPosLab,'Enable','off')
        set(handles.LinePercLab,'Enable','off')
        set(handles.LinePercText,'Enable','off')
        set(handles.LinePercSlide,'Enable','off')
        set(handles.HorizGrdPitLab,'Enable','off')
        set(handles.HorizGrdPitText,'Enable','off')
        set(handles.HorizGrdPitSlide,'Enable','off')
        set(handles.VerGrdPitLab,'Enable','off')
        set(handles.VerGrdPitText,'Enable','off')
        set(handles.VerGrdPitSlide,'Enable','off')
        % These controls on
        set(handles.HorizGrdPitLab,'Enable','on')
        set(handles.HorizGrdPitText,'Enable','on')
        set(handles.HorizGrdPitSlide,'Enable','on')
        set(handles.VerGrdPitLab,'Enable','on')
        set(handles.VerGrdPitText,'Enable','on')
        set(handles.VerGrdPitSlide,'Enable','on')
    case 'SingCircBut'
        % These controls off
        disp('Single circle analysis enabled')
        set(handles.HorizGrdPitLab,'Enable','off')
        set(handles.HorizGrdPitText,'Enable','off')
        set(handles.HorizGrdPitSlide,'Enable','off')
        set(handles.VerGrdPitLab,'Enable','off')
        set(handles.VerGrdPitText,'Enable','off')
        set(handles.VerGrdPitSlide,'Enable','off')
        set(handles.HorizPosSlide,'Enable','off')
        set(handles.HorizPosText,'Enable','off')
        set(handles.HorizPosLab,'Enable','off')
        set(handles.VerPosSlide,'Enable','off')
        set(handles.VerPosText,'Enable','off')
        set(handles.VerPosLab,'Enable','off')
        set(handles.LinePercLab,'Enable','off')
        set(handles.LinePercText,'Enable','off')
        set(handles.LinePercSlide,'Enable','off')
        set(handles.HorizGrdPitLab,'Enable','off')
        set(handles.HorizGrdPitText,'Enable','off')
        set(handles.HorizGrdPitSlide,'Enable','off')
        set(handles.VerGrdPitLab,'Enable','off')
        set(handles.VerGrdPitText,'Enable','off')
        set(handles.VerGrdPitSlide,'Enable','off')
        % These controls on
    case 'ConcCircBut'
        disp('Concentric circle analysis enabled')
        % These controls off
        set(handles.HorizGrdPitLab,'Enable','off')
        set(handles.HorizGrdPitText,'Enable','off')
        set(handles.HorizGrdPitSlide,'Enable','off')
        set(handles.VerGrdPitLab,'Enable','off')
        set(handles.VerGrdPitText,'Enable','off')
        set(handles.VerGrdPitSlide,'Enable','off')
        set(handles.HorizPosSlide,'Enable','off')
        set(handles.HorizPosText,'Enable','off')
        set(handles.HorizPosLab,'Enable','off')
        set(handles.VerPosSlide,'Enable','off')
        set(handles.VerPosText,'Enable','off')
        set(handles.VerPosLab,'Enable','off')
        set(handles.LinePercLab,'Enable','off')
        set(handles.LinePercText,'Enable','off')
        set(handles.LinePercSlide,'Enable','off')
        set(handles.HorizGrdPitLab,'Enable','off')
        set(handles.HorizGrdPitText,'Enable','off')
        set(handles.HorizGrdPitSlide,'Enable','off')
        set(handles.VerGrdPitLab,'Enable','off')
        set(handles.VerGrdPitText,'Enable','off')
        set(handles.VerGrdPitSlide,'Enable','off')
        % These controls on
    otherwise
end

% --- Executes during object creation, after setting all properties.
function LineSetupPanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LineSetupPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function SingLineBut_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SingLineBut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% set(handles.LineSetupPanel,'SelectedObject',hObject)


% --- Executes on key press with focus on ManSeg and none of its controls.
function ManSeg_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to ManSeg (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
% Set the behaviour for various key presses in the main window

% During interface navigation once START button is activated
%   LEFT ARROW      activates the Previous button
%   RIGHT ARROW     activates the Next button
%   UP ARROW        activates the YES button
%   DOWN ARROW      activates the NO button
%   BACKSPACE       activates the UNDO button
%   DELETE          activates the UNDO button
%   RETURN          activates the NEXTUNCLASSIFIED button

switch get(handles.Start,'Enable')
    case 'on'
    case 'off'
        switch eventdata.Key
            %Interface navigation keys
            case 'rightarrow'
                Next_Callback(handles.Next, eventdata, handles)
            case 'leftarrow'
                Previous_Callback(handles.Previous, eventdata, handles)
            case 'uparrow'
                YES_Callback(handles.YES, eventdata, handles)
            case 'downarrow'
                NO_Callback(handles.NO, eventdata, handles)
            case 'backspace'
                UNDO_Callback(handles.UNDO, eventdata, handles)
            case 'delete'
                UNDO_Callback(handles.UNDO, eventdata, handles)
            case 'return'
                NextUnclassified_Callback(handles.NextUnclassified, eventdata, handles)
            % Segment navigation keys
            % Numbers on keyboard
            case '1'
                if strcmp(get(handles.Segment,'Visible'),'on')
                    Phase1Edit_ButtonDownFcn(handles.Phase1Edit, eventdata, handles)
                end
            case '2'
                if strcmp(get(handles.Segment,'Visible'),'on') && strcmp(get(handles.Phase2Edit,'Visible'),'on')
                    Phase2Edit_ButtonDownFcn(handles.Phase2Edit, eventdata, handles)
                end
            case '3'
                if strcmp(get(handles.Segment,'Visible'),'on') && strcmp(get(handles.Phase3Edit,'Visible'),'on')
                    Phase3Edit_ButtonDownFcn(handles.Phase3Edit, eventdata, handles)
                end
            case '4'
                if strcmp(get(handles.Segment,'Visible'),'on') && strcmp(get(handles.Phase4Edit,'Visible'),'on')
                    Phase4Edit_ButtonDownFcn(handles.Phase4Edit, eventdata, handles)
                end
            case '5'
                if strcmp(get(handles.Segment,'Visible'),'on') && strcmp(get(handles.Phase5Edit,'Visible'),'on')
                    Phase5Edit_ButtonDownFcn(handles.Phase5Edit, eventdata, handles)
                end
            case '6'
                if strcmp(get(handles.Segment,'Visible'),'on') && strcmp(get(handles.Phase6Edit,'Visible'),'on')
                    Phase6Edit_ButtonDownFcn(handles.Phase6Edit, eventdata, handles)
                end
            case '7'
                if strcmp(get(handles.Segment,'Visible'),'on') && strcmp(get(handles.Phase7Edit,'Visible'),'on')
                    Phase7Edit_ButtonDownFcn(handles.Phase7Edit, eventdata, handles)
                end
            case '8'
                if strcmp(get(handles.Segment,'Visible'),'on') && strcmp(get(handles.Phase8Edit,'Visible'),'on')
                    Phase8Edit_ButtonDownFcn(handles.Phase8Edit, eventdata, handles)
                end
            case '9'
                if strcmp(get(handles.Segment,'Visible'),'on') && strcmp(get(handles.Phase9Edit,'Visible'),'on')
                    Phase9Edit_ButtonDownFcn(handles.Phase9Edit, eventdata, handles)
                end
            case '0'
                if strcmp(get(handles.Segment,'Visible'),'on') && strcmp(get(handles.Phase0Edit,'Visible'),'on')
                    Phase10Edit_ButtonDownFcn(handles.Phase10Edit, eventdata, handles)
                end
            % Numbers on number keypad
            case 'numpad1'
                if strcmp(get(handles.Segment,'Visible'),'on')
                    Phase1Edit_ButtonDownFcn(handles.Phase1Edit, eventdata, handles)
                end
            case 'numpad2'
                if strcmp(get(handles.Segment,'Visible'),'on') && strcmp(get(handles.Phase2Edit,'Visible'),'on')
                    Phase2Edit_ButtonDownFcn(handles.Phase2Edit, eventdata, handles)
                end
            case 'numpad3'
                if strcmp(get(handles.Segment,'Visible'),'on') && strcmp(get(handles.Phase3Edit,'Visible'),'on')
                    Phase3Edit_ButtonDownFcn(handles.Phase3Edit, eventdata, handles)
                end
            case 'numpad4'
                if strcmp(get(handles.Segment,'Visible'),'on') && strcmp(get(handles.Phase4Edit,'Visible'),'on')
                    Phase4Edit_ButtonDownFcn(handles.Phase4Edit, eventdata, handles)
                end
            case 'numpad5'
                if strcmp(get(handles.Segment,'Visible'),'on') && strcmp(get(handles.Phase5Edit,'Visible'),'on')
                    Phase5Edit_ButtonDownFcn(handles.Phase5Edit, eventdata, handles)
                end
            case 'numpad6'
                if strcmp(get(handles.Segment,'Visible'),'on') && strcmp(get(handles.Phase6Edit,'Visible'),'on')
                    Phase6Edit_ButtonDownFcn(handles.Phase6Edit, eventdata, handles)
                end
            case 'numpad7'
                if strcmp(get(handles.Segment,'Visible'),'on') && strcmp(get(handles.Phase7Edit,'Visible'),'on')
                    Phase7Edit_ButtonDownFcn(handles.Phase7Edit, eventdata, handles)
                end
            case 'numpad8'
                if strcmp(get(handles.Segment,'Visible'),'on') && strcmp(get(handles.Phase8Edit,'Visible'),'on')
                    Phase8Edit_ButtonDownFcn(handles.Phase8Edit, eventdata, handles)
                end
            case 'numpad9'
                if strcmp(get(handles.Segment,'Visible'),'on') && strcmp(get(handles.Phase9Edit,'Visible'),'on')
                    Phase9Edit_ButtonDownFcn(handles.Phase9Edit, eventdata, handles)
                end
            case 'numpad0'
                if strcmp(get(handles.Segment,'Visible'),'on') && strcmp(get(handles.Phase0Edit,'Visible'),'on')
                    Phase10Edit_ButtonDownFcn(handles.Phase10Edit, eventdata, handles)
                end
            case 'home'
            case 'end'
            case 'pageup'
            case 'pagedown'
        end
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over Author.
function Author_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Author (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure('Toolbar','none','Name','About ManSeg v0.2','Color',[225 235 250]/255,...
    'MenuBar','none','NumberTitle','off')
acknowledgement = {'ABOUT MANSEG V0.3','','Written and developed by Jacob R. Bowen',...
    'Fuel Cells and Solid State Chemistry Division',...
    'Risø National Laboratory for Sustainable Energy',...
    'Frederiksborgvej 399, 4000 Roskilde, Denmark',...
    '','This software is provided as is and without warranty.',...
    'Limited support is offered but not guaranteed by the author.',...
    'Contact: jrbo@risoe.dtu.dk','','','This program (up to version 0.3) has been made possible by',...
    'European Union funding via the FP7 RelHy project (www.relhy.eu)','',...
    'Copyright Jacob R. Bowen - All rights reserved'};
ack = text(0,0,acknowledgement);
axis off
xlim([-10 10])
ylim([-10 10])
set(ack, 'HorizontalAlignment','center','VerticalAlignment','middle')


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over Title.
function Title_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Title (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Author_ButtonDownFcn(handles.Author, eventdata, handles)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over NextUnclassified.
function NextUnclassified_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to NextUnclassified (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function Phase1Edit_Callback(hObject, eventdata, handles)
% hObject    handle to Phase1Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Phase1Edit as text
%        str2double(get(hObject,'String')) returns contents of Phase1Edit as a double
n = 1;
data = get(handles.PhasePanel,'UserData');
Phase = get(hObject,'String');
data.Phase{n} = Phase;
set(handles.PhasePanel,'UserData',data)

% --- Executes during object creation, after setting all properties.
function Phase1Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Phase1Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Phase2Edit_Callback(hObject, eventdata, handles)
% hObject    handle to Phase2Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Phase2Edit as text
%        str2double(get(hObject,'String')) returns contents of Phase2Edit as a double
n = 2;
data = get(handles.PhasePanel,'UserData');
Phase = get(hObject,'String');
data.Phase{n} = Phase;
set(handles.PhasePanel,'UserData',data)

% --- Executes during object creation, after setting all properties.
function Phase2Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Phase2Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Phase3Edit_Callback(hObject, eventdata, handles)
% hObject    handle to Phase3Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Phase3Edit as text
%        str2double(get(hObject,'String')) returns contents of Phase3Edit as a double
n = 3;
data = get(handles.PhasePanel,'UserData');
Phase = get(hObject,'String');
data.Phase{n} = Phase;
set(handles.PhasePanel,'UserData',data)

% --- Executes during object creation, after setting all properties.
function Phase3Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Phase3Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Phase4Edit_Callback(hObject, eventdata, handles)
% hObject    handle to Phase4Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Phase4Edit as text
%        str2double(get(hObject,'String')) returns contents of Phase4Edit as a double
n = 4;
data = get(handles.PhasePanel,'UserData');
Phase = get(hObject,'String');
data.Phase{n} = Phase;
set(handles.PhasePanel,'UserData',data)

% --- Executes during object creation, after setting all properties.
function Phase4Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Phase4Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Phase5Edit_Callback(hObject, eventdata, handles)
% hObject    handle to Phase5Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Phase5Edit as text
%        str2double(get(hObject,'String')) returns contents of Phase5Edit as a double
n = 5;
data = get(handles.PhasePanel,'UserData');
Phase = get(hObject,'String');
data.Phase{n} = Phase;
set(handles.PhasePanel,'UserData',data)

% --- Executes during object creation, after setting all properties.
function Phase5Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Phase5Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Phase6Edit_Callback(hObject, eventdata, handles)
% hObject    handle to Phase6Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Phase6Edit as text
%        str2double(get(hObject,'String')) returns contents of Phase6Edit as a double

n = 6;
data = get(handles.PhasePanel,'UserData');
Phase = get(hObject,'String');
data.Phase{n} = Phase;
set(handles.PhasePanel,'UserData',data)

% --- Executes during object creation, after setting all properties.
function Phase6Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Phase6Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Phase7Edit_Callback(hObject, eventdata, handles)
% hObject    handle to Phase7Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Phase7Edit as text
%        str2double(get(hObject,'String')) returns contents of Phase7Edit as a double
n = 7;
data = get(handles.PhasePanel,'UserData');
Phase = get(hObject,'String');
data.Phase{n} = Phase;
set(handles.PhasePanel,'UserData',data)

% --- Executes during object creation, after setting all properties.
function Phase7Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Phase7Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Phase8Edit_Callback(hObject, eventdata, handles)
% hObject    handle to Phase8Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Phase8Edit as text
%        str2double(get(hObject,'String')) returns contents of Phase8Edit as a double
n = 8;
data = get(handles.PhasePanel,'UserData');
Phase = get(hObject,'String');
data.Phase{n} = Phase;
set(handles.PhasePanel,'UserData',data)

% --- Executes during object creation, after setting all properties.
function Phase8Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Phase8Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Phase9Edit_Callback(hObject, eventdata, handles)
% hObject    handle to Phase9Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Phase9Edit as text
%        str2double(get(hObject,'String')) returns contents of Phase9Edit as a double
n = 9;
data = get(handles.PhasePanel,'UserData');
Phase = get(hObject,'String');
data.Phase{n} = Phase;
set(handles.PhasePanel,'UserData',data)

% --- Executes during object creation, after setting all properties.
function Phase9Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Phase9Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Phase10Edit_Callback(hObject, eventdata, handles)
% hObject    handle to Phase10Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Phase10Edit as text
%        str2double(get(hObject,'String')) returns contents of Phase10Edit as a double
n = 10;
data = get(handles.PhasePanel,'UserData');
Phase = get(hObject,'String');
data.Phase{n} = Phase;
set(handles.PhasePanel,'UserData',data)

% --- Executes during object creation, after setting all properties.
function Phase10Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Phase10Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function PhasePanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PhasePanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
PhaseColour = [255,0,0;...
    0,255,0;...
    0,0,255;...
    255,255,0;...
    0,255,255;...
    255,0,255;...
    255,153,0;...
    102,0,255;...
    82,48,48;...
    0,127,0];
Data.PhaseColour = PhaseColour;
set(hObject,'UserData',Data)
% Make the phases visible correspond to default PhaseNumText value
% for n = 2:10
%     eval(['set(handles.Phase',num2str(n),'Edit,''Visible'',''off'')'])
%     eval(['set(handles.Phase',num2str(n),'Text,''Visible'',''off'')'])
% end


% --- Executes on button press in Segment.
function Segment_Callback(hObject, eventdata, handles)
% hObject    handle to Segment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Set up function data
data=get(handles.MainImage,'UserData');
Segments = data.Segments;
Segment = data.Segment;
Manual = data.Manual;
n = data.CurrentSegmentNo; % UpdateSegmentColours advances n
CurrentLineIntensity = data.CurrentLineIntensity;
PhasePanelData=get(handles.PhasePanel,'UserData');
PhaseColour = PhasePanelData.PhaseColour;
%% Identify horizontal / vertical line profile to get correct co-ordinate
% from Manual
switch data.Mode
    case 'Single Horizontal'
        ManCol = 2;
    case 'Single Vertical'
        ManCol = 1;
end
% Get segment and its statistics
if n > length(Segments)
else
    CurrentSegment = Segments(n,1):Segments(n,2);
    CurrentSegment = CurrentSegment';
    CurrentSegment(:,2) = CurrentLineIntensity(Segments(n,1):Segments(n,2));
    if n == length(Segments)
        CurrentSegment(:,3) = ones(length(CurrentSegment),1)*Manual(n-1,ManCol);
    else
        CurrentSegment(:,3) = ones(size(CurrentSegment,1),1)*Manual(n,ManCol);
    end
    Segment(n).Mean = mean(CurrentSegment(:,2));
    Segment(n).std = std(CurrentSegment(:,2));
    Segment(n).No = length(CurrentSegment(:,2));
    Segment(n).Error = data.PixelSize/length(CurrentSegment(:,2));
    data.Segment = Segment;
    % Move CurrentLocation to the present segment
    if n == length(Segments)
        data.CurrentLocation(1) = Manual(n-1,2);
        data.CurrentLocation(2) = Manual(n-1,1);
    else
        data.CurrentLocation(1) = Manual(n,2);
        data.CurrentLocation(2) = Manual(n,1);
    end
    % Plot current line segment
    axes(handles.LineProfile);
    hCurrentSegment(n) = line(CurrentSegment(:,1),CurrentSegment(:,2),...
        'MarkerFaceColor','w',...
        'MarkerEdgeColor','k',...
        'MarkerSize',4,...
        'Marker','o',...
        'LineStyle','none');
    set(hCurrentSegment(n),'Tag','Segment')
    data.SegmentHandles = hCurrentSegment;
    % Plot current segment in Main Image
    axes(handles.MainImage);
    hCurrentImageSegment(n) = line(CurrentSegment(:,1),CurrentSegment(:,3),...
        'MarkerFaceColor','w',...
        'MarkerEdgeColor','k',...
        'MarkerSize',4,...
        'Marker','o',...
        'LineStyle','none');
    set(hCurrentImageSegment(n),'Tag','Segment')
    data.ImageSegmentHandles = hCurrentImageSegment;
end
%% Updating
% Update Segments to MainImage
set(handles.MainImage,'UserData',data)
%  Update ZoomImage and ZoomProfile views
ZoomPopup_Callback(handles.ZoomPopup, eventdata, handles)
% Update ZoomProfile
LineKids = get(handles.LineProfile,'Children');
ZoomKids = get(handles.ZoomProfile,'Children');
delete(ZoomKids)
ZoomKids = copyobj(LineKids,handles.ZoomProfile);
Padding = get(handles.ZoomPopup,'UserData');
Padding = Padding.Padding;
LineProfileData = get(handles.LineProfile,'UserData');
if strcmp(LineProfileData.LineOrientation,'Vertical')
    set(handles.ZoomProfile,'xlim',[data.CurrentLocation(1)-Padding data.CurrentLocation(1)+Padding])
elseif strcmp(LineProfileData.LineOrientation,'Horizontal')
    set(handles.ZoomProfile,'xlim',[data.CurrentLocation(2)-Padding data.CurrentLocation(2)+Padding])
end
% Update segment statistics panel
Phase = [data.Segment.Phase];
Classified = length(Phase);
set(handles.SegClassifiedText,'String',sprintf('Classified: %d',Classified))
if n > length(Segments)
else
    set(handles.SegmentNumText,'String',sprintf('Segment No: %d',n))
end
% Put in last segment error protection
% if n > length(Segments)
%    return 
% end
%% Output brief summary of line profile statistics
if n > length(Segments)
    Length = [data.Segment.No];
    MeanInt = [data.Segment.Mean];
    StdInt = [data.Segment.std];
    Error = [data.Segment.Error];
    MeanLength = mean(Length);
    StdLength = std(Length);
    Mean = [data.Segment.Mean];
    StdDev = [data.Segment.std];
    Phase = [data.Segment.Phase];
    SampleLength = sum(Length)*data.PixelSize;
    for k = 1:max(Phase)
        fase = find(Phase == k);
        Stats(k).MLI = data.PixelSize*mean(Length(fase));
        Stats(k).StdMLI = data.PixelSize*std(Length(fase));
        Stats(k).Uncertainty = 50*data.PixelSize/Stats(k).MLI;
%         The percentage of half the pixel size to the average intercept length
%         for the current phase
        Stats(k).Fraction = sum(Length(fase))/sum(Length);
        Stats(k).Segments = Length(fase);
        Stats(k).MeanIntensity = mean(MeanInt(fase));
        Stats(k).Intensities = MeanInt(fase);
        Stats(k).StdIntensity = mean(StdInt(fase));
        Stats(k).IntensityDev = StdInt(fase);
        Stats(k).No = length(Length(fase));
        Stats(k).Error = 100*sqrt(sum((0.5*data.PixelSize./Length(fase)).^2));
%         Sum of squares of the individual ratios (in %)  of the half pixel
%         size to the segment length for the current phase
        Stats(k).Sv = 4*Stats(k).Fraction/Stats(k).MLI;
    end
   
    % Output summary data
    h = figure('Name',get(handles.ProjectName,'String'));
    % Summary image
    hsub(1) = subplot(3,2,1);

    MainImageKids = get(handles.MainImage,'Children');
    hSummaryImage = copyobj(MainImageKids,hsub(1));
    axis auto
    axis image
    axis ij
    colormap gray
    set(gca,'XTick',[1;data.info.Width])
    set(gca,'XTickLabel',[0;round(data.PixelSize*data.info.Width)])
    set(gca,'YTick',[1;data.info.Height])
    set(gca,'YTickLabel',[0;round(data.PixelSize*data.info.Height)])
    box on
    xlabel('µm')
    ylabel('µm')
    FileData = get(handles.OpenFile,'UserData');
    title(FileData.file,'Interpreter', 'none') % BUGFIX 2013-11-26 fixed subscripting of file names
    % Histogram
    hsub(2) = subplot(3,2,2);
    hold on
    PhasePanelData = get(handles.PhasePanel,'UserData');
    MaxNo = max([Stats.No]);
    AllSegs = nan([MaxNo,max(Phase)]);
    for k = 1:max(Phase)
        AllSegs(1:length(Stats(k).Segments),k) = Stats(k).Segments;
    end
    hist(AllSegs)
    xlabel('Segment Length (Pixels)')
    ylabel('Counts')
    box on
    % Make hitosgram pretty
    BarHandles = findobj(gca,'Type','patch');
    BarHandles = flipud(BarHandles);
    PhasePaneUserData = get(handles.PhasePanel,'UserData');
    PhaseColour = PhasePaneUserData.PhaseColour;
    for q = 1:length(BarHandles)
        set(BarHandles(q),'FaceColor',PhaseColour(q,:)/255,'EdgeColor','k')
    end
    
%     legend(LegendString)
    % Line profile
    hsub(3) = subplot(3,2,[3 4]);
    LineProfileKids = get(handles.LineProfile,'Children');
    hSummaryProfile = copyobj(LineProfileKids,hsub(3));
    axis tight
    xlabel('Distance (Pixels)')
    ylabel('Image Intensity')
    box on
    % Summary statistics
    % TODO
    % COnvert text output to a table
    hsub(5) = subplot(3,2,5);
    StatsText{1} = sprintf('Phase | MLI   | MLI     | Uncertainty | Error | Phase    | No. | Intensity | Intensity | Sv');
    StatsText{2} = sprintf('No.   | (µm)  | Std.Dev | %%           | %%     | Fraction |     | Mean      | Std.Dev   | (1/µm)');
    StatsText{3} = sprintf('------------------------------------------------------------------------------------------------');
    for k = 1:max(Phase)
        StatsText{k+3} = sprintf('%d     | %0.2f  | %0.2f    | %0.2f        | %0.2f  | %0.2f     | %d  | %0.2f    | %0.2f  | %0.2f ',...
            k,...
            Stats(k).MLI,...
            Stats(k).StdMLI,...
            Stats(k).Uncertainty,...
            Stats(k).Error,...
            Stats(k).Fraction,...
            Stats(k).No,...
            Stats(k).MeanIntensity,...
            Stats(k).StdIntensity,...
            Stats(k).Sv);
    end
    hStatsText = text(0,0,StatsText,'FontSize',8);
    set(hStatsText,'FontName','FixedWidth')
    axis off
    xlim([0 10])
    ylim([-10 10])
    set(hStatsText, 'HorizontalAlignment','left','VerticalAlignment','middle')
    % Image & project information
    hsub(6) = subplot(3,2,6);
    ImageText1 = sprintf('Project: %s',get(handles.ProjectName,'String'));
    ImageText2 = sprintf('Pixel Size: %0.4f µm',data.PixelSize);
    ImageText3 = sprintf('Image Width: %d pixels',data.info.Width);
    ImageText4 = sprintf('Image Height: %d pixels',data.info.Height);
    ImageText5 = sprintf('Image Bit Depth: %d',data.info.BitDepth);
    switch data.Mode
        case 'Single Horizontal'
            ImageText6 = sprintf('Image Row Number: %d',data.LineRowNo);
        case 'Single Vertical'
            ImageText6 = sprintf('Image Column Number: %d',data.LineColNo);
    end
    ImageText7 = sprintf('Sample Length: %0.2f µm (%d pixels)',SampleLength, sum(Length));
    ImageText8 = sprintf('ManSeg %s',data.Version);
    ImageText9 = datestr(now);
    ImageText10 = version;
    hImageText = text(0,0,{ImageText1,ImageText2,ImageText3,ImageText4,...
        ImageText5,ImageText6,ImageText7,ImageText8,ImageText9,ImageText10});
    axis off
    xlim([0 10])
    ylim([-10 10])
    set(hImageText, 'HorizontalAlignment','left','VerticalAlignment','middle')
    % Prepare for outputting a table of chord lengths in µm
    % NEW FUNC: 07-08-2014
    for k = 1:max(Phase)
        ChordTableLength(k) = Stats(k).No;
    end
    Chords = zeros(max(ChordTableLength),k);
    Chords = Chords*NaN;
    for k = 1:max(Phase)
        fase = find(Phase == k);
        Chords(1:ChordTableLength(k),k) = data.PixelSize*Length(fase);
        TableData(k,:) = {Stats(k).MLI,...
            Stats(k).StdMLI,...
            Stats(k).Uncertainty,...
            Stats(k).Error,...
            Stats(k).Fraction,...
            Stats(k).No,...
            Stats(k).MeanIntensity,...
            Stats(k).StdIntensity,...
            Stats(k).Sv};
    end
%     Make table summary of output suitable for copy paste
f = figure('Name','Statistical Summary');
    % Column names and column format
    columnname  = {'MLI','StdMLI','Uncertainty (%)','Error (%)','Phase fraction',...
        'No. of segments','Mean Intensity','StdDev. Intensity','Sv'};
    columnformat  = {'numeric','numeric','numeric','numeric','numeric',...
        'numeric','numeric','numeric','numeric'};
    % Create the uitable
    T1 = uitable(f,'Data', TableData,... 
            'ColumnName', columnname ,...
            'ColumnFormat', columnformat ,...
            'RowName',num2cell([1:max(Phase)]));
%     T1.Position(3:4) = T1.Extent(3:4);
%     Make table psegments and their phases suitable for copy paste
f2 = figure('Name','List of segments and phase');
    SegData = [Phase',Length'];
    % Column names and column format
    columnname2  = {'Segment Phase','Segment Length'};
    columnformat2  = {'numeric','numeric'};
    % Create the uitable
    Tt2 = uitable(f2,'Data', SegData,... 
            'ColumnName', columnname2 ,...
            'ColumnFormat', columnformat2 ,...
            'RowName',[]);
%     Tt2.Position(3:4) = Tt2.Extent(3:4);
 %     Make table of all segment lengths
    figure('Name','Segment lengths in µm for each phase');
    t = uitable;
    set(t,'Data',Chords)
%     t.Position(3:4) = t.Extent(3:4);
%     cnames = {'X-Data','Y-Data','Z-Data'};
%     rnames = {'First','Second','Third'};
%     t = uitable('Parent',f,'Data',dat,'ColumnName',cnames,... 
%             'RowName',rnames,'Position',[20 20 360 100]);
    % Save segmented data to output file
    % Get file and path info
    FileUserData = get(handles.OpenFile,'UserData');
    OpenFolderUserData = get(handles.OpenFolder,'UserData');
    % Tidy 
    filenumber = FileUserData.filenumber;
    directoryname = OpenFolderUserData.path;
    FileUserData.Project = get(handles.ProjectName,'String');
    saveproject = [directoryname '\' FileUserData.Project];
    % Check for exisitng project file
    ProjectExist = exist(saveproject, 'file');
    if ~ProjectExist
        load(saveproject);
    end
    % Add file and line info to Project structure
    % FIX BUG HERE
    Project(filenumber).File = FileUserData;
    Project(filenumber).LineSetup = get(handles.LineSetupPanel,'UserData');
    % Extract relevant data from MainImage for Project storage
    MainImageUserData = get(handles.MainImage,'UserData');
    switch data.Mode
        case 'Single Horizontal'
            if isfield(Project,'Horizontal')
                Horizontal = Project(filenumber).Horizontal;
            end
            Horizontal(MainImageUserData.LineRowNo).Statistics = Stats;
            Horizontal(MainImageUserData.LineRowNo).Auto = MainImageUserData.Auto;
            Horizontal(MainImageUserData.LineRowNo).Manual = MainImageUserData.Manual;
            Horizontal(MainImageUserData.LineRowNo).Segments = MainImageUserData.Segments;
            Horizontal(MainImageUserData.LineRowNo).Segment = MainImageUserData.Segment;
            Project(filenumber).Horizontal = Horizontal;
        case 'Single Vertical'
            if isfield(Project,'Vertical')
                Vertical = Project(filenumber).Vertical;
            end
            Vertical(MainImageUserData.ColRowNo).Statistics = Stats;
            Vertical(MainImageUserData.ColRowNo).Auto = MainImageUserData.Auto;
            Vertical(MainImageUserData.ColRowNo).Manual = MainImageUserData.Manual;
            Vertical(MainImageUserData.ColRowNo).Segments = MainImageUserData.Segments;
            Vertical(MainImageUserData.ColRowNo).Segment = MainImageUserData.Segment;
            Project(filenumber).Vertical = Vertical;
    end
    % Tidy up prior to Project insertion
    MainImageUserData = rmfield(MainImageUserData,'CurrentImage');
    MainImageUserData = rmfield(MainImageUserData,'OriginalImage');
    MainImageUserData = rmfield(MainImageUserData,'CurrentLocation');
    MainImageUserData = rmfield(MainImageUserData,'CurrentAuto');
    MainImageUserData = rmfield(MainImageUserData,'Auto');
    MainImageUserData = rmfield(MainImageUserData,'Segment');
    MainImageUserData = rmfield(MainImageUserData,'Segments');
    MainImageUserData = rmfield(MainImageUserData,'Manual');
      
    Project(filenumber).MainImage = MainImageUserData; % #ok<NASGU>
    
    % SAVE!
    saveproject = [directoryname '\' FileUserData.Project];
    save(saveproject,'Project')
    return
end
%%
function GBdetect(handles,Phase)
% Function added 2017-08-22
if get(handles.PhaseNumSlide,'Value')>1
    data=get(handles.MainImage,'UserData');
    if data.CurrentSegmentNo==1
    else
        if ~get(handles.EnableGBs,'Value')
%             Check to see if GB tick box is checked
            PreviousPhase = data.Segment(data.CurrentSegmentNo-1).Phase;
            if PreviousPhase==Phase
                return
            end
        end
    end
end
function Phase1Edit_ButtonDownFcn(hObject, eventdata, handles)
%% Assign phase number, advance segments number and call Segment
Phase = 1;
% Call GBdetect to control what happens when grain boundaries are
% activated. GBDetect enables consequtive segments to have the same phase.
% Statistical analysis of grain sizes in multiphase materials is not
% implemented and requires manual calculation of statistics from the output
% of individual segment analysis and neighbour detection.
GBdetect(handles,Phase)

UpdateSegmentColours(Phase,handles, eventdata)

function Phase2Edit_ButtonDownFcn(hObject, eventdata, handles)
%% Assign phase number, advance segments number and call Segment
Phase = 2;
% Call GBdetect to control what happens when grain boundaries are
% activated. GBDetect enables consequtive segments to have the same phase.
% Statistical analysis of grain sizes in multiphase materials is not
% implemented and requires manual calculation of statistics from the output
% of individual segment analysis and neighbour detection.
GBdetect(handles,Phase)

UpdateSegmentColours(Phase, handles, eventdata)

function Phase3Edit_ButtonDownFcn(hObject, eventdata, handles)
%% Assign phase number, advance segments number and call Segment
Phase = 3;
% Call GBdetect to control what happens when grain boundaries are
% activated. GBDetect enables consequtive segments to have the same phase.
% Statistical analysis of grain sizes in multiphase materials is not
% implemented and requires manual calculation of statistics from the output
% of individual segment analysis and neighbour detection.
GBdetect(handles,Phase)

UpdateSegmentColours(Phase, handles, eventdata)

function Phase5Edit_ButtonDownFcn(hObject, eventdata, handles)
%% Assign phase number, advance segments number and call Segment
Phase = 5;
% Call GBdetect to control what happens when grain boundaries are
% activated. GBDetect enables consequtive segments to have the same phase.
% Statistical analysis of grain sizes in multiphase materials is not
% implemented and requires manual calculation of statistics from the output
% of individual segment analysis and neighbour detection.
GBdetect(handles,Phase)

UpdateSegmentColours(Phase, handles, eventdata)

function Phase6Edit_ButtonDownFcn(hObject, eventdata, handles)
%% Assign phase number, advance segments number and call Segment
Phase = 6;
% Call GBdetect to control what happens when grain boundaries are
% activated. GBDetect enables consequtive segments to have the same phase.
% Statistical analysis of grain sizes in multiphase materials is not
% implemented and requires manual calculation of statistics from the output
% of individual segment analysis and neighbour detection.
GBdetect(handles,Phase)

UpdateSegmentColours(Phase, handles, eventdata)

Segment_Callback(handles.Segment, eventdata, handles)
function Phase7Edit_ButtonDownFcn(hObject, eventdata, handles)
%% Assign phase number, advance segments number and call Segment
Phase = 7;
% Call GBdetect to control what happens when grain boundaries are
% activated. GBDetect enables consequtive segments to have the same phase.
% Statistical analysis of grain sizes in multiphase materials is not
% implemented and requires manual calculation of statistics from the output
% of individual segment analysis and neighbour detection.
GBdetect(handles,Phase)

UpdateSegmentColours(Phase, handles, eventdata)

function Phase8Edit_ButtonDownFcn(hObject, eventdata, handles)
%% Assign phase number, advance segments number and call Segment
Phase = 8;
% Call GBdetect to control what happens when grain boundaries are
% activated. GBDetect enables consequtive segments to have the same phase.
% Statistical analysis of grain sizes in multiphase materials is not
% implemented and requires manual calculation of statistics from the output
% of individual segment analysis and neighbour detection.
GBdetect(handles,Phase)

UpdateSegmentColours(Phase, handles, eventdata)

function Phase9Edit_ButtonDownFcn(hObject, eventdata, handles)
%% Assign phase number, advance segments number and call Segment
Phase = 9;
% Call GBdetect to control what happens when grain boundaries are
% activated. GBDetect enables consequtive segments to have the same phase.
% Statistical analysis of grain sizes in multiphase materials is not
% implemented and requires manual calculation of statistics from the output
% of individual segment analysis and neighbour detection.
GBdetect(handles,Phase)

UpdateSegmentColours(Phase, handles, eventdata)

function Phase10Edit_ButtonDownFcn(hObject, eventdata, handles)
%% Assign phase number, advance segments number and call Segment
Phase = 0;
% Call GBdetect to control what happens when grain boundaries are
% activated. GBDetect enables consequtive segments to have the same phase.
% Statistical analysis of grain sizes in multiphase materials is not
% implemented and requires manual calculation of statistics from the output
% of individual segment analysis and neighbour detection.
GBdetect(handles,Phase)

UpdateSegmentColours(Phase, handles, eventdata)

function Phase4Edit_ButtonDownFcn(hObject, eventdata, handles)
%% Assign phase number, advance segments number and call Segment
Phase = 4;
% Call GBdetect to control what happens when grain boundaries are
% activated. GBDetect enables consequtive segments to have the same phase.
% Statistical analysis of grain sizes in multiphase materials is not
% implemented and requires manual calculation of statistics from the output
% of individual segment analysis and neighbour detection.
GBdetect(handles,Phase)

UpdateSegmentColours(Phase, handles, eventdata)

function UpdateSegmentColours(Phase, handles, eventdata)
%%
data=get(handles.MainImage,'UserData');
n = data.CurrentSegmentNo;
Segment = data.Segment;
Segment(n).Phase = Phase;
data.Segment = Segment;
data.CurrentSegmentNo = n+1;
set(handles.MainImage,'UserData',data)
% Update segment line colour
% hCurrentSegment = data.SegmentHandles;
PhasePaneUserData = get(handles.PhasePanel,'UserData');
PhaseColour = PhasePaneUserData.PhaseColour;
h = data.SegmentHandles;
axes(handles.ZoomProfile);
set(h(n),'Color',PhaseColour(Phase,:)/255,...
    'Marker','none',...
    'LineWidth',3,...
    'LineStyle','-')
% Update line segment colour in MainImage
h2 = data.ImageSegmentHandles;
% axes(handles.MainImage);
set(h2(n),'Color',PhaseColour(Phase,:)/255,...
    'Marker','none',...
    'LineWidth',3,...
    'LineStyle','-')

Segment_Callback(handles.Segment, eventdata, handles)


% --- Executes on key press with focus on YES and none of its controls.
function YES_KeyPressFcn(hObject, eventdata, handles)
%% hObject    handle to YES (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)



function ProjectName_Callback(hObject, eventdata, handles)
%% hObject    handle to ProjectName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ProjectName as text
%        str2double(get(hObject,'String')) returns contents of ProjectName as a double
ProjectName = get(hObject,'String');
% Get file and path info
OpenFolderUserData = get(handles.OpenFolder,'UserData');
if isfield(OpenFolderUserData,'path')
    directoryname = OpenFolderUserData.path;
else
    msgbox('Please open the folder for your project first')
    return
end
% Create ManSeg output project data structure
Project = struct;
% SAVE!
saveproject = [directoryname '\' ProjectName];
save(saveproject,'Project')
% Activate Select Output data location
set(handles.Output,'Enable','on')
% Lock project name
set(handles.ProjectName,'Enable','off')


% --- Executes on button press in MedFilt.
function MedFilt_Callback(hObject, eventdata, handles)
% hObject    handle to MedFilt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MedFilt

switch get(hObject,'Value')
    case 0
        OpenFile_Callback(hObject, eventdata, handles)
    case 1
        OpenFile_Callback(hObject, eventdata, handles)
        data=get(handles.MainImage,'UserData');
        PreFilt=data.CurrentImage;
        PostFilt=medfilt2(PreFilt,'symmetric');%Apply median filter
        data.CurrentImage=PostFilt;
        set(handles.MainImage,'UserData',data)
        % Plot zoom of image data in ZoomAxes according to ZoomPopup
        BitDepth = data.info.BitDepth;
        axes(handles.MainImage);
        AxesKids=get(gca,'Children');
        set(AxesKids,'CData',PostFilt)
        ZoomPopup_Callback(handles.ZoomPopup, eventdata, handles)
    otherwise
end


% --- Executes on button press in Help.
function Help_Callback(hObject, eventdata, handles)
% hObject    handle to Help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = figure('Toolbar','none','Name','Segmening Instructions','Color',[225 235 250]/255,...
                    'MenuBar','none','NumberTitle','off');
                HelpText = {'Use the following keys to allocate individual segments',...
                    'to phases.','',...
                    'Note: to activate key strokes click set the ManSeg window',...
                    'in focus by clicking on a light blue background portion of',...
                    ' the window',...
                    '','For each segment press the number corresponding to the',...
                    'the phase (or click on the corresponding phase in the )',...
                    'phase panel.','','Use the ''Home'' key to identify contiguous ',...
                    'segments at the beginning of a line profile that should not be ',...
                    'counted as a phase. This is useful if you have rotated the image.',...
                    'Correspondingly use the ''End'' key to identify contiguous',...
                    'line segments at the end of a line profile.','',...
                    'Use the ''Page Up'' and Page Down'' keys to navigate forth and',...
                    'back along the line segments in case you wish to correct',...
                    'the allocation of a segment.','',...
                    'The segment will automatically advance on selection of a phase.',...
                    'Once all segments are allocated you will be asked for final confirmation.'};
                HText = text(0,0,HelpText);
                axis off
                xlim([-10 10])
                ylim([-10 10])
                set(HText, 'HorizontalAlignment','center','VerticalAlignment','middle')


% --- Executes on button press in EnableGBs.
function EnableGBs_Callback(hObject, eventdata, handles)
% hObject    handle to EnableGBs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of EnableGBs
GB = get(hObject,'Value');

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over EnableGBs.
function EnableGBs_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to EnableGBs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
