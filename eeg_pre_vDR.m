
function eeg_pre_vDR()
%=========================================================================%
% BVD - BRG edits Summer 2016
%=========================================================================%
global RUN; eeglab -redraw;

pre.sf=RUN.set.sf;
pre.filter_ica=RUN.set.filter_ica;
pre.filter_dta=RUN.set.filter_dta;
pre.thresh_ica=RUN.set.thresh_ica;
pre.thresh_dta=RUN.set.thresh_dta;
pdir='';
for iSubj = 1:length(RUN.dir.subjects)
    % Skip subject if already processed   
    try % Don't let single subjects break it all
    sdisp(RUN.dir.subjects{iSubj},2);
    if RUN.dir.plot(iSubj)==0, continue; end
    
    if (exist(fullfile(RUN.dir.pro,[RUN.dir.subjects{iSubj} '.mat']),'file') && RUN.dir.overwrite==0)
        display('...skipping');     
        continue;
    end
    %--------------------%
    % EEG Preprocess 
    %--------------------%     
    RUN.dir.filt=RUN.dir.pre;
    if ~exist(fullfile(RUN.dir.filt,[RUN.dir.subjects{iSubj} '_filt2.set']),'file')
        EEG=eeg_basic(1,pre,iSubj,pdir); 
        EEG = pop_saveset(EEG, 'filename',[RUN.dir.subjects{iSubj} '_filt2.set'],'filepath',RUN.dir.filt);
    else 
        EEG = pop_loadset('filename',[RUN.dir.subjects{iSubj} '_filt2.set'],'filepath',RUN.dir.filt);
    end
    
    % This work is all super quick...
    % 11, 12, 13 are trials, epoch 11 and 12
    [EEG,~,~]=DR_epoch(EEG,iSubj);   
    
    % Add channel info prior to interpt
    EEG = pop_chanedit(EEG, 'lookup',fullfile(fileparts(which('eeglab.m')), ...
        RUN.template.elp),'load',{RUN.template.ica 'filetype' 'autodetect'});
   
    tmpChn = EEG.chanlocs;

    if ~isempty(RUN.subj{iSubj}.pre.interp)
        EEG = pop_select(EEG,'nochannel',RUN.subj{iSubj}.pre.interp);
    end

    %-------------------------%
    % Add ICA component back into EEG
    %-------------------------%
    if RUN.dir.resp==1
        EEG_ica=pop_loadset('filename',[RUN.dir.subjects{iSubj} '_ica_resp.set'],'filepath',RUN.dir.pre);
        RUN.subj{iSubj}.pre.ICA=RUN.subj{iSubj}.pre.ICAresp; sav_str='_resp';
    else
        EEG_ica=pop_loadset('filename',[RUN.dir.subjects{iSubj} '_ica.set'],'filepath',RUN.dir.pre);
        sav_str='';
    end
    % Add in the saved ICA weights
    EEG.icawinv = EEG_ica.icawinv;
    EEG.icasphere = EEG_ica.icasphere;
    EEG.icaweights = EEG_ica.icaweights;
    EEG.icachansind = EEG_ica.icachansind;
    clear EEG_ica;
    
    % Remove component
    if ~isempty(RUN.subj{iSubj}.pre.ICA) 
        EEG = pop_subcomp(EEG,[RUN.subj{iSubj}.pre.ICA],0); 
    end

    % interpolerate back in lost channel
    if ~isempty(RUN.subj{iSubj}.pre.interp), EEG = pop_interp(EEG,tmpChn,'spherical'); end
    
    %-------------------------%
    % Finalize
    %-------------------------%    
    % re-reference the data
    EEG=eeg_reference(EEG,iSubj); % We rereference here
    
    % threshold check
    %remove baseline [in miliseconds]
%     EEG = pop_rmbase( EEG, RUN.pre.baseline); -> done while epoch
    
%     RUN.set.thresh_dta=[-150 150]; % For 1001
    EEG = pop_eegthresh(EEG,1,1:64,RUN.set.thresh_dta(1),RUN.set.thresh_dta(2),RUN.set.thresh_epc(1),RUN.set.thresh_epc(2),0,0);

    % Save to fieldtrip as well
    EEG = pop_saveset(EEG, 'filename',[RUN.dir.subjects{iSubj} '_final' sav_str '.set'],'filepath',RUN.dir.pro);
%     EEG = pop_loadset('filename',[RUN.dir.subjects{iSubj} '_final' sav_str '.set'],'filepath',RUN.dir.pro);
  
    data = eeglab2fieldtrip(EEG,'preprocessing');
    % These are essential for data conversion to work
    data.EEGepoch = EEG.epoch;
    data.EEGurevent= EEG.urevent;
    data.EEGevent=EEG.event;
    data.trialsN=EEG.trialsN;
    % data.accepted_events=index;
    % data.tkill=tkill;
    data.reject=EEG.reject;
    save(fullfile(RUN.dir.pro,[RUN.dir.subjects{iSubj} sav_str '.mat']),'data');

    clear EEG; clear data;

    catch err
        sdisp([RUN.dir.subjects{iSubj} ': FAILED'],1);
        keyboard;
    end
end
 
    
