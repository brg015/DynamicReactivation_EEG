function eeg_DR_setup()
global RUN;
% Word is actually 808ms prior
%=========================================================================%
% 1000
%=========================================================================%
% Notes
% -> stupid subject blinked too much
% -> 10/11 drop code at the start? I rejected this
% --> results in 700 epochs - good
% -> drop code responses to 13 look wrong (i.e afc tasks)
% ICA Notes
% -> {1,2,10} all look kind of like eye blinks
% -> {3,} looks like muscle noise?
s=1;
subj{s}.name='1000';
subj{s}.pre.interp=[];
subj{s}.pre.ICA=[1,2];
subj{s}.pre.ICAresp=[1,2];
subj{s}.missing_trials=[];
%=========================================================================%
% 1001
%=========================================================================%
% Notes
% -> LVEOG started very noisy, was fixed part way through
% -> 5,6 have some okay moments, but cleary ruin some trials
% -> drop codes to afc look fine, but code didn't change? I'm not sure what
%    has happened here. The other trials were changed to free response, but
%    the afc task was already like that
% ICA Notes
% -> 695 epochs? hmmm
% --> lost from ringing in LVEOG -> 109, 120, 329, 400, 609
% ---> find(ICrun.artfThreshIC) in eeg_icrun_vDR
% -> {1,2} look like blinks
s=s+1;
subj{s}.name='1001';
subj{s}.pre.interp=[5,6];
subj{s}.pre.ICA=[1,2];
subj{s}.pre.ICAresp=[1,2];
subj{s}.missing_trials=[109, 120, 329, 400, 609];
%=========================================================================%
% 1001_eye
%=========================================================================%
% s=s+1;
% subj{s}.name='1001_eye';
% subj{s}.pre.interp=[5,6];
% subj{s}.pre.ICA=[];
%=========================================================================%
% 3781
%=========================================================================%
% Notes
% -> 29 : channel is drifting everywhere (remove)
% -> lower occipital channels a bit noisy as is 27
% -> 30: has some moments of noise as well
% -> overall very nice data, but with some blinks
% ICA Notes
% -> {2,24} look like eyeblinks rm(2)
s=s+1;
subj{s}.name='3781';
subj{s}.pre.interp=[29];
subj{s}.pre.ICA=[2];
subj{s}.pre.ICAresp=[1];
subj{s}.missing_trials=[];
%=========================================================================%
% 3782
%=========================================================================%
% Notes
% -> This person does not blink
% -> weak LVEOG connection early on, takes the GA, at about 1000 fixes
% --> but have removed some segments from raw data
% --> extreme about 1350 as well
% ---> this persist in nearly all breaks, currently have rejected, but
%      might be worth including so filtering works better and just not
%      reject eye-blinks as they are so few
% -> 9 : channel has instanaous jumps at points, but easy to remove
% -> 60: remove for noise
% -> 53 : has some bad drift
% --> these weren't indexed correctly below, needs re-run
% ICA Notes
% -> {1} looks like eyeblinks
% -> {3} is also, it doesn't look like one, but its the GA stuff at start
s=s+1;
subj{s}.name='3782';
subj{s}.pre.interp=[59, 52];
subj{s}.pre.ICA=[1,3,4]; % 4 is cardiac
subj{s}.pre.ICAresp=[1,2,3];
subj{s}.missing_trials=[];
%=========================================================================%
% 108
%=========================================================================%
% 60 -> which is 59
s=s+1;
subj{s}.name='108';
subj{s}.pre.interp=[59];
subj{s}.pre.ICA=[1 2]; % 2 is noise in R mastoid? - uniform in all channels
subj{s}.pre.ICAresp=[1,2,3];
subj{s}.missing_trials=[];
%=========================================================================%
% 112
%=========================================================================%
% Some electrodes had high impedence
% 27, 28, 51 & 49
% 5,6 are also a mess
s=s+1;
subj{s}.name='112';
subj{s}.pre.interp=[27 28 50 49 5 6 17];
subj{s}.pre.ICA=[1,4];
subj{s}.pre.ICAresp=[1,2,4];
subj{s}.missing_trials=[];
%=========================================================================%
% 113
%=========================================================================%
% Some electrodes had high impedence
% Electrode 29 is left mastoid*
% 51, 33, 60, 22, 35, 36
%
% data isn't terrible, but many bad electrodes and left reference broke so
% electrode 29 was stuck in that socket
s=s+1;
subj{s}.name='113';
subj{s}.pre.interp=[50 32 59 22 34 35 5 6 30 52 53 60];
subj{s}.pre.ICA=[1];
subj{s}.pre.ICAresp=[1];
subj{s}.missing_trials=[];
% lost two trials in epoching, subject is worse than initially expected

for ii=1:length(RUN.dir.subjects)
    if ~strcmp(RUN.dir.subjects{ii},subj{ii}.name)
        error('Subject IDs defined wrong');
    end
end
%=========================================================================%
%% Add behave data
%=========================================================================%
for ii=1:length(RUN.dir.subjects)
    if RUN.dir.plot(ii)==0, continue; end
    % F:\Data2\Geib\DynamicReactivation\behav\subjectXXXX\DR_pro.csv has
    % all behave data
    D=excel_reader(fullfile('F:\Data2\Geib\DynamicReactivation\behav\',['subject' RUN.dir.subjects{ii}],'DR_pro.csv'));
    for jj=1:length(D)
        f=D{jj}.col;
        beh.(D{jj}.header{1}(2:end-1))=f;
    end
    subj{ii}.beh=beh; 
end

RUN.subj=subj;
%=========================================================================%
%% Set Processing Defualts
%=========================================================================%
switch RUN.dir.ver
    case 'v0'
        RUN.pre.ref=[32 64];
        % RTs are ~2.3 for vivid and dim
        if ~RUN.dir.resp
            RUN.pre.epoch=[-1 3];
            RUN.set.thresh_epc=[-1 3];
        elseif RUN.dir.resp
            RUN.pre.epoch=[-3 1];
            RUN.set.thresh_epc=[-3 1];
        end
        RUN.pre.baseline=[-100 0];

        RUN.set.filter_ica=[1 70];
        RUN.set.filter_dta=[0.05 70];
        RUN.set.sf=250;
        RUN.set.thresh_ica=[-500 1500];
        
        RUN.set.thresh_dta=[-100 100]; 

        RUN.set.reref='mastoid';
end

%=========================================================================%
cod_dir='F:\Data2\Geib\EEG\';
% template.erp=fullfile(cod_dir,'\EEG_v1-master\templates\layoutMartyFixed.mat');
% template.topo=fullfile(cod_dir,'\EEG_v1-master\templates\mw64_withMastoids_fixed.ced');


RUN.template.ced=fullfile(cod_dir,'\EEG_v1-master\templates\mw64_withMastoids_fixed.ced');
% These are used for ICA and channel removal
RUN.template.ica='mw64.ced';
RUN.template.elp='/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp';

% This shit needs cleaned the fuck up
RUN.template.plt=fullfile(cod_dir,'layoutmw64_ActiChamp.mat');
RUN.template.plt=fullfile(cod_dir,'layoutmw64.mat');
RUN.template.plt2=fullfile(cod_dir,'layoutmw64_martyPlot.mat');
RUN.template.plt3=fullfile(cod_dir,'layoutmw64.mat');

% From eeg_sea_enc_setup
% RUN.template.ced='mw64_withMastoids_fixed.ced';
% RUN.template.ica='mw64.ced';
% RUN.template.elp='/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp';
% RUN.template.plt='F:\SEA\Enc_EEG\EEG_v1-master\templates\layoutmw64_ActiChamp.mat';
% RUN.template.plt='F:\SEA\Enc_EEG\EEG_v1-master\templates\layoutmw64.mat';
% RUN.template.plt2='F:\SEA\Enc_EEG\EEG_v1-master\templates\layoutmw64_martyPlot.mat';
% RUN.template.plt3='C:\Users\brg13\Desktop\SEA\layoutmw64.mat';


        















