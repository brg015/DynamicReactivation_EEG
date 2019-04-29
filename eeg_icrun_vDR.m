function eeg_icrun_vDR()
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
for iSubj =1:length(RUN.dir.subjects) % loop through subjects
    if RUN.dir.plot(iSubj)==0, continue; end
    sdisp(RUN.dir.subjects{iSubj},2);

    % Create subject directory
    save_1=fullfile(RUN.dir.QAL,'ICA');
    if ~exist(save_1,'dir'), mkdir(save_1); end   
    %---------------------------------------------------------------------%
    % EEG Preprocess 
    %---------------------------------------------------------------------% 
    RUN.dir.filt=RUN.dir.pre;
    pre_save=fullfile(RUN.dir.filt,[RUN.dir.subjects{iSubj} '_filter.set']);
    if (~exist(pre_save,'file'))
        EEG=eeg_basic(0,pre,iSubj,pdir);
        EEG=pop_saveset(EEG,'filename',[RUN.dir.subjects{iSubj} '_filter.set'],'filepath',RUN.dir.filt);
    else
        EEG=pop_loadset('filename',[RUN.dir.subjects{iSubj} '_filter.set'],'filepath',RUN.dir.filt);
    end

    %-------------------------%
    % Modify epoched events by study
    %-------------------------%
    % 11, 12, 13 are trials, epoch 11 and 12
%     keyboard;
    [EEG,~,~]=DR_epoch(EEG,iSubj);   

    %mark trials with extreme values for rejection ([electrodes:],min,max,timestart,timeend,)
    %leave eye blinks intact
    EEG = pop_eegthresh(EEG,1,setdiff(1:63,31),pre.thresh_ica(1),pre.thresh_ica(2),RUN.pre.epoch(1),RUN.pre.epoch(2),0,0);

    ICrun.artfThreshIC = EEG.reject.rejthresh;      % is the list of epochs to remove
    EEG = pop_rejepoch(EEG,ICrun.artfThreshIC,0);   % Removes the epochs from EEG
    %-------------------------%
    %ICA Calculations
    %-------------------------%
    EEG = pop_chanedit(EEG, 'lookup',fullfile(fileparts(which('eeglab.m')), ...
        RUN.template.elp),'load',{RUN.template.ica 'filetype' 'autodetect'});
    
    if ~isempty(RUN.subj{iSubj}.pre.interp)
        EEG = pop_select(EEG,'nochannel',RUN.subj{iSubj}.pre.interp);
    end
    % Extended ICA by default now 11/21/18
    EEG = pop_runica(EEG,'runica','chanind',[]);

    %save ICrun for eah subject 
%     RUN.dir.resp=1;
% for iSubj=1:length(RUN.dir.subjects),iSubj
     if ~RUN.dir.resp
        IC_file=[RUN.dir.subjects{iSubj} '_ica.set']; IC_str='_ica';
    else
        IC_file=[RUN.dir.subjects{iSubj} '_ica_resp.set']; IC_str='_ica_resp';
     end
    EEG = pop_saveset(EEG,'filename',IC_file,'filepath',RUN.dir.pre);
%     EEG = pop_loadset('filename',IC_file,'filepath',RUN.dir.pre);
%     EEG.xmin
% end

    pop_topoplot(EEG,0,1:EEG.nbchan);
    set(gcf,'position',[0 0 1280 1024]);
    export_fig(fullfile(save_1,[RUN.dir.subjects{iSubj} IC_str '.png']));
    close all;
end


