function [EEG2,indices,R]=DR_epoch(EEG,iSubj)
global RUN;
indices=[]; R=[];
% if subj==7, missing 6 item block 9 = trial 9*28+6 = 258
% replace cue code (10) with (11) so epochs are 'right'
% manually remove trial later
if iSubj==7, EEG.event(625).type='11'; end

if ~RUN.dir.resp
    [EEG2,index] = pop_epoch(EEG,{'11','12','13'},RUN.pre.epoch, 'newname', ...
        ' resampled epochs', 'epochinfo', 'yes');
    tkill=[]; R=[]; EEG2.tkill=[];
    indices = index;
    EEG2 = pop_rmbase( EEG2, RUN.pre.baseline);    
    EEG2.tkill=tkill;
    EEG2.trialsN=index;
else
    % We just need prestim baseline here
    [EEG2,index2] = pop_epoch(EEG,{'11','12','13'},[-.5 .5], 'newname', ...
        ' resampled epochs', 'epochinfo', 'yes');
    
    A=cell2num(RUN.subj{iSubj}.beh.rxn); Resp=NaN(1,700); RT=NaN(1,700);
    c=1; for ii=1:length(EEG.event)
        % Find a trial start
        if (strcmp(EEG.event(ii).type,'11') || strcmp(EEG.event(ii).type,'12') ...
            || strcmp(EEG.event(ii).type,'13'))
            T(c)=EEG.event(ii).latency;
            E(c)=ii;
            EpochIndex(c)=str2num(EEG.event(ii).type);             
            if (strcmp(EEG.event(ii+1).type,'1') || ...
                strcmp(EEG.event(ii+1).type,'2') || ...
                strcmp(EEG.event(ii+1).type,'3') || ...
                strcmp(EEG.event(ii+1).type,'4') || ...
                strcmp(EEG.event(ii+1).type,'5') || ...
                strcmp(EEG.event(ii+1).type,'6') || ...
                strcmp(EEG.event(ii+1).type,'7') || ...
                strcmp(EEG.event(ii+1).type,'8'))
            
                if (abs(A(c)-(EEG.event(ii+1).latency-T(c))*4)<20 && A(c)~=0)
                    % Found a response a RT is approx correct
                    Resp(c)=str2num(EEG.event(ii+1).type);
                    RT(c)=(EEG.event(ii+1).latency-T(c))*4;
                    EEG.event(ii+1).type='100'; % Overwrite old codes
                elseif (abs(A(c)-(EEG.event(ii+1).latency-T(c)))<20)
                    display('RTs are mixed up in DR_epoch');
                    keyboard; 
                end
            end
            c=c+1; % Trial count increases
        end
    end
    % THese should be about same
    % plot(cell2num(RUN.subj{1}.beh.rxn),'r'); hold on;
    % plot(RT,'b');
    %-------------------------------%
    % Micro QA
    %-------------------------------%
    if ~(length(EpochIndex)==700)
        display('Wrong number of epochs detected in DR_epoch');
        keyboard;
    end
    % Epoch this

    trials_accepted=setdiff(1:700,find(isnan(RT)));
    [EEG3,index3] = pop_epoch(EEG,{'100'},RUN.pre.epoch, 'newname', ...
        ' resampled epochs', 'epochinfo', 'yes');
    trials_accepted=trials_accepted(index3);

    % Remove da baseline
    twin=(EEG2.times<=0 & EEG2.times>=-100);
    c=1; for ii=trials_accepted
        % Don't have to match
        L=false(1,700); L(ii==index2)=true; 
        mV=mean(EEG2.data(:,twin,L),2); % Channel X 1
        rmV=repmat(mV,1,length(EEG3.times));
        
        EEG3.data(:,:,c)=EEG3.data(:,:,c)-rmV; 
        EEG3.trialsN(c)=ii; c=c+1;
        clear rMV mV;       
    end
    EEG2=EEG3;
end
    
    % %-------------------------------------------------------------------------%
% % Baseline based upon RT
% %-------------------------------------------------------------------------%
% % rts is a 1*ntrials matrix containing the rt for each trial in seconds
% RT_temp=RT(indices);
% for iTrial = 1:size(EEG2.data,3)
%     % take the mean of the data for each channel prior to stimulus onset (based
%     % on rts), replicate this matrix until the size of your original data and
%     % subtract these mean values from your original epoch
%     % 1) mean values
%     RTt=RT_temp(iTrial);
%     twin=(EEG2.times<-1*RTt & EEG2.times>-1*RTt-200);
%     mV=mean(EEG2.data(:,twin,iTrial),2); % Channel X 1
%     rmV=repmat(mV,1,length(EEG2.times));
%     EEG2.data(:,:,iTrial)=EEG2.data(:,:,iTrial)-rmV; 
%     clear rMV mV twin RTt;
% end
% 
% EEG2.tkill=tkill;


    
end
%-------------------------------------------------------------------------%
% Identify included trials as = tkill
%-------------------------------------------------------------------------%







