function SwallowingDetectionSoftware
%   This function creates a figure with multiple Tabs.
%   The number of tabs can be changed and they are distributed evenly
%   across the top of the figure.  Content is provided for the first 5 tabs
%   to demo the program.  The demo uses the screen size to adjust the size
%   of the figure.  The program uses the ~ character for unused arguments,
%   so if you are not using 2009b, these should be changed to dummy
%   arguments (lines 209 and 233). guidata is set to the TabHandles cell
%   array and is used to pass all arguments and data to the functions.

%%   Set up some varables
%   First clear everything
        clear all
        clc
        close all;
        
%   Set Number of tabs and tab labels.  Make sure the number of tab labels
%   match the HumberOfTabs setting.
        NumberOfTabs = 3;               % Number of tabs to be generated
        TabLabels = {'Start Count'; 'Swallow Count'; 'Review Recordings'};
        if size(TabLabels,1) ~= NumberOfTabs
            errordlg('Number of tabs and tab labels must be the same','Setup Error');
            return
        end
        
%   Get user screen size
        SC = get(0, 'ScreenSize');
        MaxMonitorX = SC(3);
        MaxMonitorY = SC(4);
        
 %   Set the figure window size values
        MainFigScale = .6;          % Change this value to adjust the figure size
        MaxWindowX = round(MaxMonitorX*MainFigScale);
        MaxWindowY = round(MaxMonitorY*MainFigScale);
        XBorder = (MaxMonitorX-MaxWindowX)/2;
        YBorder = (MaxMonitorY-MaxWindowY)/2; 
        TabOffset = 0;              % This value offsets the tabs inside the figure.
        ButtonHeight = 40;
        PanelWidth = MaxWindowX-2*TabOffset+4;
        PanelHeight = MaxWindowY-ButtonHeight-2*TabOffset;
        ButtonWidth = round((PanelWidth-NumberOfTabs)/NumberOfTabs);
                
 %   Set the color varables.  
        White = [1  1  1];            % White - Selected tab color     
        BGColor = .9*White;           % Light Grey - Background color
            
%%   Create a figure for the tabs
        hTabFig = figure(...
            'Units', 'pixels',...
            'Toolbar', 'none',...
            'Position',[ XBorder, YBorder, MaxWindowX, MaxWindowY ],...
            'NumberTitle', 'off',...
            'Name', 'Tab Demo',...
            'MenuBar', 'none',...
            'Resize', 'off',...
            'DockControls', 'off',...
            'Color', White);
    
%%   Define a cell array for panel and pushbutton handles, pushbuttons labels and other data
    %   rows are for each tab + two additional rows for other data
    %   columns are uipanel handles, selection pushbutton handles, and tab label strings - 3 columns.
            TabHandles = cell(NumberOfTabs,3);
            TabHandles(:,3) = TabLabels(:,1);
    %   Add additional rows for other data
            TabHandles{NumberOfTabs+1,1} = hTabFig;         % Main figure handle
            TabHandles{NumberOfTabs+1,2} = PanelWidth;      % Width of tab panel
            TabHandles{NumberOfTabs+1,3} = PanelHeight;     % Height of tab panel
            TabHandles{NumberOfTabs+2,1} = 0;               % Handle to default tab 2 content(set later)
            TabHandles{NumberOfTabs+2,2} = White;           % Selected tab Color
            TabHandles{NumberOfTabs+2,3} = BGColor;         % Background color
            
%%   Build the Tabs
        for TabNumber = 1:NumberOfTabs
        % create a UIPanel
            TabHandles{TabNumber,1} = uipanel('Units', 'pixels', ...
                'Visible', 'off', ...
                'Backgroundcolor', White, ...
                'BorderWidth',1, ...
                'Position', [TabOffset TabOffset ...
                PanelWidth PanelHeight]);

        % create a selection pushbutton
            TabHandles{TabNumber,2} = uicontrol('Style', 'pushbutton',...
                'Units', 'pixels', ...
                'BackgroundColor', BGColor, ...
                'Position', [TabOffset+(TabNumber-1)*ButtonWidth PanelHeight+TabOffset...
                    ButtonWidth ButtonHeight], ...          
                'String', TabHandles{TabNumber,3},...
                'HorizontalAlignment', 'center',...
                'FontName', 'arial',...
                'FontWeight', 'bold',...
                'FontSize', 10);

        end

%%   Define the callbacks for the Tab Buttons
%   All callbacks go to the same function with the additional argument being the Tab number
        for CountTabs = 1:NumberOfTabs
            set(TabHandles{CountTabs,2}, 'callback', ...
                {@TabSellectCallback, CountTabs});
        end

%%   Define content for the Start Count page
    %   Open Sound File Pushbutton
        uicontrol('Parent', TabHandles{1,1}, ...
            'Units', 'pixels', ...
            'Position', [round(PanelWidth/2)+140 (2*ButtonHeight)-50 200 ButtonHeight], ...
            'String', 'Open Sound File', ...
            'Callback', @StartCountCallback , ...
            'Style', 'pushbutton',...
            'HorizontalAlignment', 'center',...
            'FontName', 'arial',...
            'FontWeight', 'bold',...
            'FontSize', 12);
 
    %   Build the text for the first tab
        Intro = {'--Start Count--';...
            ' ';...
            'Select below to open a sound file to count swallows.';...
            ' ';...
            'Please be patient while waiting for the neural network to load.';};
        
    %   Display it - Put the handle in TabHandles so that it can be deleted later 
        TabHandles{NumberOfTabs+3,1} = uicontrol('Style', 'text',... % 3rd item to be added to Tab Handles
            'Position', [ round(PanelWidth/4) 3*ButtonHeight ...
                round(PanelWidth/2) round(PanelHeight/2) ],...
            'Parent', TabHandles{1,1}, ...
            'string', Intro,...
            'BackgroundColor', White,...
            'HorizontalAlignment', 'center',...
            'FontName', 'arial',...
            'FontWeight', 'bold',...
            'FontSize', 14);
    
%%   Define default content for the Swallow Count Tab


%   Build default text for the Image tab
        Intro = {'Use the Open Image Tab to display an image here'};

    %   Display it - Put the handle in TabHandles so that it can be deleted later 
        TabHandles{NumberOfTabs+2,1} = uicontrol('Style', 'text',...
            'Position', [ round(PanelWidth/4) 3*ButtonHeight ...
                round(PanelWidth/2) round(PanelHeight/2) ],...
            'Parent', TabHandles{2,1}, ...
            'string', Intro,...
            'BackgroundColor', White,...
            'HorizontalAlignment', 'center',...
            'FontName', 'arial',...
            'FontWeight', 'bold',...
            'FontSize', 14);
	   
%%   Define View Past Recordings Tab content
    % Make a uicontrol that is a table that pulls the saved wav files from
    % the folder for step 1
    %   Build a table header
        TabHandles{NumberOfTabs+3,2}= uicontrol('Style', 'text',...
            'Position', [ round((PanelWidth-ButtonWidth)/2) PanelHeight-round(1.5*ButtonHeight) ...
                ButtonWidth ButtonHeight ],...
            'Parent', TabHandles{3,1}, ...
            'string', '  Tab 3 Table ',...
            'BackgroundColor', White,...
            'HorizontalAlignment', 'center',...
            'FontName', 'arial',...
            'FontWeight', 'bold',...
            'FontSize', 12);

    %   Build the data cell array to display
        DisplayData = cell(23,2);
        ColumnNames = {' File name ' ' Date and Time '};
        Width = PanelWidth/2-1;
        ColumnWidths = {Width Width};
        

    %   Create the table and add old swallow files to it
        oldfolder=cd(getenv('USERPROFILE'));
        mkdir 'WavFiles';
        cd('WavFiles');
        wavcell=struct2cell(dir('*.wav'));
        
        DisplayData(1:size(wavcell,2),1)=wavcell(1,:)';
        DisplayData(1:size(wavcell,2),2)=wavcell(3,:)';
        cd(oldfolder);
        TabHandles{NumberOfTabs+3,3}=uitable('Position',...
            [1 1 PanelWidth PanelHeight-2*ButtonHeight],...
            'Parent', TabHandles{3,1}, ...
            'ColumnName', ColumnNames,...
            'ColumnWidth', ColumnWidths,...
            'RowName', [],...
            'Data', DisplayData, 'CellSelectionCallback', @SelectedWavFileCallback);

        
        
%%   Define Tab 4 content
    %   Create a random RGB image and display it
            Img = rand(PanelHeight,PanelWidth,3);
            ImgOffset = 40;
            haxes4 = axes('Parent', TabHandles{4,1}, ...
                'Units', 'pixels', ...
                'Position', [ImgOffset ImgOffset ...
                    PanelWidth-2*ImgOffset PanelHeight-2*ImgOffset]);
            
            imagesc(Img,'Parent', haxes4);

%%   Save the TabHandles in guidata
        guidata(hTabFig,TabHandles);

%%   Make Tab 1 active
        TabSellectCallback(0,0,1);

end
%%   Callback for Tab Selection
function TabSellectCallback(~,~,SelectedTab)
%   All tab selection pushbuttons are greyed out and uipanels are set to
%   visible off, then the selected panel is made visible and it's selection
%   pushbutton is highlighted.

    %   Set up some varables
        TabHandles = guidata(gcf);
        NumberOfTabs = size(TabHandles,1)-3;
        White = TabHandles{NumberOfTabs+2,2};            % White      
        BGColor = TabHandles{NumberOfTabs+2,3};          % Light Grey
        
    %   Turn all tabs off
        for TabCount = 1:NumberOfTabs
            set(TabHandles{TabCount,1}, 'Visible', 'off');
            set(TabHandles{TabCount,2}, 'BackgroundColor', BGColor);
        end
        
    %   Enable the selected tab
        set(TabHandles{SelectedTab,1}, 'Visible', 'on');        
        set(TabHandles{SelectedTab,2}, 'BackgroundColor', White);

end

%%   Open Image File Callback
    function StartCountCallback(~,~)   
    %   Get TabHandles from guidata and set some varables
        TabHandles = guidata(gcf);
        NumberOfTabs = size(TabHandles,1)-3;
        PanelWidth = TabHandles{NumberOfTabs+1,2};
        PanelHeight = TabHandles{NumberOfTabs+1,3};

    %   Two persistent varables are needed
%         persistent StartWavDirectory hImageAxes
        
    %   Initilize the StartPicDirectory if first time through
%         if isempty(StartWavDirectory)
%             StartWavDirectory = cd;
%         end
    
    %   Get the file name from the user
        [WavNameWithTag, WavDirectory] = uigetfile({'*.wav','Sound Files'},...
            'Select a sound file');

%         if PicNameWithTag == 0,
%             %   If User canceles then display error message
%                 errordlg('You should select an Image File');
%             return
%         end
        
    %   Set the default directory to the currently selected directory
        StartWavDirectory = WavDirectory;

    %   Build path to file
        WavFilePath = strcat(WavDirectory,WavNameWithTag);
        
    %TODO: Save wav files to a directory under the src dir
        oldfolder=cd(getenv('USERPROFILE'));
        
        copyfile(WavFilePath, 'WavFiles');
        cd(oldfolder);
        
  
    %   Load and adjust the wav
        [y, fs] = audioread(WavFilePath);    % y = audio data
        % y is an m-by-n matrix where
        % m = number of audio samples read
        % n = number of audio channels in the file
        % fs = sample rate (Hz)
        
    %   Display sound file graphically
        dt = 1/fs;                                                  % seconds = 1/Hz
        t = 0:dt:(length(y)*dt)-dt;                                 % create x-axis for amplitude plot
        TopPlotOffset = 60;
        MidPlotOffset = 40;
        BottomPlotOffset = 100;
        haxes2 = axes('Parent', TabHandles{1,1}, ...
            'Units', 'pixels', ...
            'Position', [TopPlotOffset BottomPlotOffset PanelWidth-2*MidPlotOffset PanelHeight-2*TopPlotOffset]);
        scrollplot(plot(haxes2, t,y)); xlabel('Seconds'); ylabel('Amplitude');
        
    %   Setup sound file for neural network
        sInput = setupSoundFileForNN(y);
        
    %   Load NN and saved swallowCount
        load net.mat
        load swallows.mat
        
    %   Use NN to determine swallows in the sample
        sOutput = net(sInput);
        
    %   Determine the number of swallows in the sample
        swallowCount = sum(round(sOutput));
        
    %   Add this count to the existing count and save it
        swallows.count = swallows.count + swallowCount;
        save('swallows.mat', 'swallows');
        
    %   Hide page 1 text
        set(TabHandles{6,1}, 'Visible','off');
        
    %   Display swallow count for this file
        countText = {strcat(int2str(swallowCount), ' swallows')};
        
        %   Swallow Count Text - Put the handle in TabHandles so that it can be deleted later 
        TabHandles{NumberOfTabs+4,1} = uicontrol('Style', 'text',... % 4th item to be added to Tab Handles
            'Position', [ 50 15 300 50 ],...
            'Parent', TabHandles{1,1}, ...
            'string', countText,...
            'BackgroundColor', [1 1 1],... % white must be expressed as a 3 element vector from inside callback apparently
            'HorizontalAlignment', 'center',...
            'FontName', 'arial',...
            'FontWeight', 'bold',...
            'FontSize', 30);
    
    end
    
    function output = setupSoundFileForNN(y)
        valsPerTrial = 220503; % 220503 audio values in 5 seconds when fs = 44.1kHz
        
        % Make wav vector have correct number of elements for reshape
        extra = mod(length(y),valsPerTrial);
        y = y(1:end-extra);
        
        numTrials = length(y)/valsPerTrial;

        % Make input array from a single wav file
        input = zeros(valsPerTrial, numTrials);
        input(:,1:numTrials) = reshape(y, [valsPerTrial,numTrials]);
        
        % Perform FFT as pre-processing
        output = abs(fft(input));
    end
    
%%   Open Image File Callback    
    function SelectedWavFileCallback(TObject, eventdata, TableHandles)
        % hObject    handle to data_uitable (see GCBO)
        % eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
        %	Indices: row and column indices of the cell(s) currently selecteds
        % handles    structure with handles and user data (see GUIDATA)
        % disp(eventdata)
        TableHandles.datatable_row = eventdata.Indices(1);
        TableHandles.datatable_col = eventdata.Indices(2);
        wavdata=get(TObject,'Data');
        filename=wavdata(eventdata.Indices(1),1);
        filename=cell2mat(filename);
        oldfolder=cd(getenv('USERPROFILE'));
        cd('WavFiles');
        directory=pwd;
       cd(oldfolder);
        
  
        WavFilePath=fullfile(directory, filename);
        [y, fs] = audioread(WavFilePath);
         
        
        TabHandles = guidata(gcf);
       
        NumberOfTabs = size(TabHandles,1)-3;
          TabHandles{NumberOfTabs+3,3}.Visible='off';
          TabHandles{NumberOfTabs+3,2}.Visible='off';
      
        PanelWidth = TabHandles{NumberOfTabs+1,2};
        PanelHeight = TabHandles{NumberOfTabs+1,3};
      %Display sound file graphically
        dt = 1/fs;                                                  % seconds = 1/Hz
        t = 0:dt:(length(y)*dt)-dt;                                 % create x-axis for amplitude plot
        TopPlotOffset = 60;
        MidPlotOffset = 40;
      
        BottomPlotOffset = 100;
        haxes2 = axes('Parent', TabHandles{3,1}, ...
            'Units', 'pixels', ...
            'Position', [TopPlotOffset BottomPlotOffset PanelWidth-2*MidPlotOffset PanelHeight-2*TopPlotOffset]);
        scrollplot(plot(haxes2, t,y)); xlabel('Seconds'); ylabel('Amplitude');
        ButtonHeight = 40;
     TabHandles{NumberOfTabs+4,3}=uicontrol('Parent', TabHandles{3,1}, ...
            'Units', 'pixels', ...
            'Position', [round(PanelWidth/2)+140 (2*ButtonHeight)-50 200 ButtonHeight], ...
            'String', 'Back', ...
            'Callback', @BackButtonCallback , ...
            'Style', 'pushbutton',...
            'HorizontalAlignment', 'center',...
            'FontName', 'arial',...
            'FontWeight', 'bold',...
            'FontSize', 12);
        
        
    end
    function BackButtonCallback(~,~)
    TabHandles = guidata(gcf);
    NumberOfTabs = size(TabHandles,1)-3;
    TabHandles{NumberOfTabs+3,3}.Visible='on';
          TabHandles{NumberOfTabs+3,2}.Visible='on';
       d=allchild(gca)
        delete(d);
        axis off;
        
    end
    