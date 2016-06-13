function findHistory_eng(history,lengthHistMax,mat,th,CountPZ,mat_dateStart,mat_dateEnd,fid,fidHist,Encod,flag,dateStartHist)

%history is a string in which all the mined events are concatenated through "_"
%flag indicates if the function is invoked by the MainCFM (1) or from itself (0)

%if the history length is greater than lengthHistMax, return to MainCFM 
indU = strfind(history,'_');
if length(indU)>=lengthHistMax
    return 
end

%check how many time an event is the first event of histories  (count e percentage)
tab=tabulate(mat(:,2));

% Compute the support (supp) for each first event
supp=tab(:,2)/length(mat(:,1));

%select the first events where the thresholds (th and count of patients undergoing the history until the event) are verified 
selected=tab((find(supp>=th & tab(:,2)>=CountPZ)),1); % selected CountPZains event codes of the ones who verify the support conditions


% if the only event selected is a zero, this means that all the history are ended; in this case return to the invoking function
selected((selected==0))=[];

if isempty(selected)==1
    return
else
    for k=1:length(selected)
        
        clear mat_new
        clear mat_dateStart_new
        clear mat_dateEnd_new
        
        %add the k event to the history
        history_new=strcat(history,'_',num2str(selected(k)));
            
        %create the data matrix (dimension, rows = number of patients, columns = history length at the step) with all the history that start with the k event
        mat_new=mat((mat(:,2)==selected(k)),:);
        
        %count the number of patients that have the k event as the first one in the history
        num_paz=length(mat_new(:,1));
        
        %update data matrix, delete the first event
        mat_new(:,2)=[];
        
        %create the corresponding dates matrix 
        mat_dateStart_new=mat_dateStart((mat(:,2)==selected(k)),:)
        mat_dateEnd_new=mat_dateEnd((mat(:,2)==selected(k)),:)
        
        %count the number of patients for which the history ends at this step
        n_out=length(find(mat_new(:,2)==0));
        
        %write the number of patients that are discharged from the process (in the out event)
        fprintf(fid,'E%sOUT [label="out\\n%d pts\\n", style="dashed"];\n',history_new,n_out);
        
        % compute for each patient the duration of the k event and statistics (median, percentiles)
        eventDuration=mat_dateEnd_new(:,2)-mat_dateStart_new(:,2);
        eventDuration_med_perc=['median:' num2str(round(median(eventDuration))) '-25prctile:' num2str(round(prctile(eventDuration,25))) '-75prctile:' num2str(round(prctile(eventDuration,75)))];
        
        %write the information about the event 
        fprintf(fid,'E%s [label="%s\\n%d pts\\n%s days", style="rounded, bold", color="%s"];\n',history_new,Encod{(selected(k)==cell2mat(Encod(:,1))),2},num_paz,eventDuration_med_perc,Encod{(selected(k)==cell2mat(Encod(:,1))),3});
        
        %find the patients for which the history ends at this step
        pazEnd=mat_new(find(mat_new(:,2)==0),1);
        
        if not(isempty(pazEnd))
           fprintf(fidHist,'%s|',history_new);
           for c = 1:length(pazEnd)
               fprintf(fidHist,'%d,',pazEnd(c));
           end
           fprintf(fidHist,'\n');
        end

        %find start dates for the mined histories 
        dateStartHist_new=dateStartHist((mat(:,2)==selected(k)));
        
        %considering those patients that are at the end of the history, compute the total duration of the process for them 
        if isempty(pazEnd)
            historyDuration=0;
        else
            for l=1:length(pazEnd)
                dateStartHist_pazEnd(l)=dateStartHist_new(find(pazEnd(l)==mat_new(:,1)));
            end
            historyDuration=median(mat_dateEnd_new((mat_new(:,2)==0),2)-dateStartHist_pazEnd');
        end
        
        clear pazEnd
        clear dateStartHist_pazEnd
        
        %write the information (number of patients and history duration) on the branch to the out event
        fprintf(fid,'E%s -> E%sOUT [style="filled", label="\\n %d pts\\ntotal duration (median):%0.f days\\n"];\n',history_new,history_new,n_out,historyDuration);
         
        if flag==0
            
            %compute the statistics about time between consecutive events (the end of the previous one and the start of the following one)
            eventDistance=mat_dateStart_new(:,2)-mat_dateEnd_new(:,1);
            eventDistance_med_perc=['median:' num2str(round(median(eventDistance))) '-25prctile:' num2str(round(prctile(eventDistance,25))) '-75prctile:' num2str(round(prctile(eventDistance,75)))];
            
            %write the information (number of patients and time between events) on the branch between events
            fprintf(fid,'E%s -> E%s [style="filled", label="\\n %d pts\\n %s days\\n"];\n',history,history_new,num_paz,eventDistance_med_perc);
                
        end
        
		%update date matrices 
        mat_dateStart_new(:,1)=[];
        mat_dateEnd_new(:,1)=[];
        
        findHistory_eng(history_new,lengthHistMax,mat_new,th,CountPZ,mat_dateStart_new,mat_dateEnd_new,fid,fidHist,Encod,0,dateStartHist_new);      
            
    end
end
 
    
   