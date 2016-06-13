
% format for file: 5 columns
% Column 1: case identifier (e.g patient ID)
% Column 2: start date of the event (format dd/mm/yyyy)
% Column 3: end date of the event (format dd/mm/yyyy)
% Column 4: event name (string)
% Column 5: event type (for colours) 

% CountPZ		= Minimum number of patients that undergo an event
% PercCount		= if PercCount==1 la variable CountPZ is computed as a proportion on  
%				  the entire population (it should be between 0 and 1)
% LengthMax		= History maximum length to compute
% Threshold		= Support threshold

clear all
CountPZ = 50;
PercCount = 0;
LengthMax = 5;
Threshold = 0;

% In this example we built a palette of 20 colours - in the case you have
% more than 20 different type of events it's possible to update the palette
% adding new colours - http://www.graphviz.org/doc/info/colors.html
color_palette = {'firebrick1';
'blue';
'chartreuse2'; 
'deeppink1'; 
'darkorange';   
'darkorchid1';
'gold';    
'salmon'; 
'turquoise1'; 
'plum';
'red'; 
'dodgerblue';
'orangered';
'turquoise';
'mediumorchid';
'gold';
'coral';
'yellowgreen';
'hotpink'};

% [idcod dateStart dateEnd eventStr evColour]=textread('fileFarmaciConTerapiaPre.txt','%d %s %s %s %s','delimiter','\t');
[idcod_orig dateStart dateEnd eventStr_orig evColour_orig]=textread('Example.txt','%d %s %s %s %s','delimiter','\t');

% Converts date to numeric values
dateStart_num_orig = datenum(dateStart,'dd/mm/yyyy');
dateEnd_num_orig = datenum(dateEnd,'dd/mm/yyyy');

% Sort data
iu = unique(idcod_orig);
dateStart_num = [];
dateStart_str = [];
dateEnd_num = [];
eventStr = [];
evColour = [];
idcod = [];
for i = 1:length(iu)
    ip = find(idcod_orig==iu(i));
    dateIstrp = dateStart(ip);
    dateFp = dateEnd_num_orig(ip);
    evp = eventStr_orig(ip);
    evcp = evColour_orig(ip);
    idcodp = idcod_orig(ip);
    [ds ind_sort] = sort(dateStart_num_orig(ip));
    dateStart_num = [dateStart_num;ds];
    dateEnd_num = [dateEnd_num;dateFp(ind_sort)];
    eventStr = [eventStr;evp(ind_sort)];
    evColour = [evColour;evcp(ind_sort)];
    idcod = [idcod;idcodp(ind_sort)];
    dateStart_str = [dateStart_str;dateIstrp(ind_sort)];
end



% Each event is identified by a numeric code
evUniqueStr=unique(eventStr);
unique_color = unique(evColour);

evNum=zeros(length(eventStr),1);
for i=1:length(evUniqueStr)
    evNum(strcmp(evUniqueStr(i),eventStr))=i;
    ev_ind = find(strcmp(evUniqueStr(i),eventStr));
    corr_color = evColour(ev_ind(1));
    col_unique_ev{i,1} = evColour(ev_ind(1));
    col_unique_evNum(i,1) = find(strcmp(corr_color,unique_color));
end

% Each event type is identified by a colour

ev_unici_num = (1:length(evUniqueStr))';


% Create a matrix of the events colour
mat_color_event = color_palette(col_unique_evNum,:);

evUniqueStr=[evUniqueStr;'out']
ev_unici_num=[ev_unici_num;0]
mat_color_event = [mat_color_event; 'black'];

Encod=[num2cell(ev_unici_num) evUniqueStr mat_color_event];

idcodUnique=unique(idcod); %idcodUnique patient code
np=length(idcodUnique);  %idcodUnique unique patient code, np patient number

% For each patient / sequence, the number of events is computed

for k=1:length(idcodUnique)
    lengthHist(k,1)=length(find(idcodUnique(k)==idcod));
end

% Maximum history length
lengthHistMax=max(lengthHist);

%launch a matrix (n, m) n= number of patients, m= number of events in the longest history 
mat=zeros(length(idcodUnique),lengthHistMax+2); % + 2 for out and id (check)

%id and patients' history, one for each row, null value are substitute with “0”
%create two matrix for date start and end of events  


for k=1:length(idcodUnique)
    %events matrix
    mat(k,1)=idcodUnique(k);
    ind_paz=[];
    ind_paz=find(idcodUnique(k)==idcod);
    mat(k,2:(length(ind_paz)+1))=evNum(ind_paz)';
    %ini and end date matrix
    mat_dateStart(k,1)=0;
    mat_dateStart(k,2:(length(ind_paz)+1))=(dateStart_num(ind_paz))';
    mat_dateEnd(k,1)=0;
    mat_dateEnd(k,2:(length(ind_paz)+1))=(dateEnd_num(ind_paz))';
end

% Create the .dot file to design the graph and the header 
%NOME FILE --> PARAMETRICO

fid=fopen('HISTdot_EventLog_ENG.dot','w');
fprintf(fid,'digraph G {\n');
fprintf(fid,' size="6,10"; fontname="Arial"; fontsize="12";\n');
fprintf(fid,'  node [shape="box",fontname="Arial",fontsize="12"];\n');


% Save the start date of the history for each patient
dateStartHist=mat_dateStart(:,2);

% Write the Histories file
fidHist=fopen('HIST_EventLog_ENG.txt','w');


% in this case the number of patients has to be calculated 
if PercCount==1 
    if CountPZ>1
        warning('Please insert a value between 0 and 1');
    else
    CountPZ=round(np*CountPZ);     %np NON DEFINITO
    end
end


% Invoke the function to mine careflows 

findHistory_eng('',LengthMax,mat,Threshold,CountPZ,mat_dateStart,mat_dateEnd,fid,fidHist,Encod,1,dateStartHist);

fprintf(fid,'}');
fclose(fid);
fclose(fidHist);

