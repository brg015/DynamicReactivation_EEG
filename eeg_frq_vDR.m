function eeg_frq_vDR()
global RUN;

% cfg_freq            = [];
% cfg_freq.keeptrials = 'yes';
% cfg_freq.output     = 'pow';
% cfg_freq.method     = 'mtmconvol';
% cfg_freq.taper = 'dpss';
% cfg_freq.foi =  logspace(log10(2),log10(30),34);
% cfg_freq.tapsmofrq  = 5*log10(cfg_freq.foi);
% cfg_freq.t_ftimwin =   [2./cfg_freq.foi(cfg_freq.foi<=4) ...
%     3./cfg_freq.foi(cfg_freq.foi> 4 & cfg_freq.foi<=8) ...
%     5./cfg_freq.foi(cfg_freq.foi> 8 & cfg_freq.foi<=14) ...
%     7./cfg_freq.foi(cfg_freq.foi> 14 &  cfg_freq.foi<=20) ...
%     10./cfg_freq.foi(cfg_freq.foi> 20 &  cfg_freq.foi<=30)];
% cfg_freq.keeptapers = 'no';
% cfg_freq.pad        = 'maxperlen';
% suffix='_DPSS';
% if RUN.dir.resp==1
%     sav_str='_resp'; 
%     cfg_freq.toi        = -3:0.05:1;
% else
%     sav_str=''; 
%     cfg_freq.toi        = -1:0.05:3;
% end 

cfg_freq            = [];
cfg_freq.keeptrials = 'yes';
cfg_freq.output     = 'pow';
cfg_freq.method     = 'mtmconvol';
cfg_freq.taper = 'dpss';
cfg_freq.foi =  logspace(log10(2),log10(30),34);
cfg_freq.tapsmofrq  = 5*log10(cfg_freq.foi);
cfg_freq.t_ftimwin =   [2./cfg_freq.foi(cfg_freq.foi<=4) ...
    3./cfg_freq.foi(cfg_freq.foi> 4 & cfg_freq.foi<=8) ...
    5./cfg_freq.foi(cfg_freq.foi> 8 & cfg_freq.foi<=14) ...
    7./cfg_freq.foi(cfg_freq.foi> 14 &  cfg_freq.foi<=20) ...
    10./cfg_freq.foi(cfg_freq.foi> 20 &  cfg_freq.foi<=30)];
cfg_freq.keeptapers = 'no';
cfg_freq.pad        = 'maxperlen';
suffix='_DPSS2';
if RUN.dir.resp==1
    sav_str='_resp'; 
    cfg_freq.toi        = -3:0.025:1;
else
    sav_str=''; 
    cfg_freq.toi        = -1:0.025:3;
end

    
for iSubj=2:length(RUN.subj), iSubj
    if RUN.dir.plot(iSubj)
        load(fullfile(RUN.dir.pro,[RUN.dir.subjects{iSubj} sav_str '.mat']),'data');
        data.time{1}([1 end])

        freqlock=ft_freqanalysis(cfg_freq, data); 
        save(fullfile(RUN.dir.pro,[RUN.dir.subjects{iSubj} sav_str suffix '.mat']),'freqlock');
        
        % load(fullfile(RUN.dir.pro,[RUN.dir.subjects{iSubj} sav_str suffix '.mat']),'freqlock');
        freqlock.time([1 end])
    end
end