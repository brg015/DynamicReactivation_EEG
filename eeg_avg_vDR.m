function eeg_avg_vDR()
global RUN;

for ii=1:length(RUN.dir.subjects)
    if RUN.dir.plot(ii)
        
if RUN.dir.resp==1, sav_str='_resp'; else, sav_str=''; end

EEG = pop_loadset('filename',[RUN.dir.subjects{ii} '_final' sav_str '.set'],'filepath',RUN.dir.pro);
EEG = pop_eegthresh(EEG,1,setdiff(1:64,31),-150,150,EEG.xmin,EEG.xmax,0,0);
% I(ii)=sum(EEG.reject.rejthresh);
% figure(ii); imagesc(EEG.reject.rejthreshE);
        
load(fullfile(RUN.dir.pro,[RUN.dir.subjects{ii} sav_str '.mat']));
data.reject=EEG.reject; clear EEG;
%-------------------------------------------------------------------------%     
% Make booleans
%-------------------------------------------------------------------------%  
% RUN.subj{X}.beh
% figure(1); set(gcf,'color','w');
% for ii=1:7
beh=RUN.subj{ii}.beh; 
if RUN.dir.resp
    fn=fieldnames(beh);
    for jj=1:length(fn)
        beh.(fn{jj})=beh.(fn{jj})(data.trialsN);
    end
end
% subplot(3,3,ii); histogram(cell2num(beh.rxn)); set(gca,'xlim',[0 10000]);
% end

if RUN.dir.resp==1, data.reject.rejthresh(cell2num(beh.rxn)>5000)=1; end
if ii==7, data.reject.rejthresh(258)=1; end

booleans.Enc_Int=strcmp(beh.EncDiff,'1');
booleans.Enc_Smp=strcmp(beh.EncDiff,'2');

booleans.Enc_RemVivid=strcmp(beh.EncRemVivid,'1');
booleans.Enc_RemVivid_Face=strcmp(beh.EncRemVivid,'1') & strcmp(beh.Face,'1');
booleans.Enc_RemVivid_Plce=strcmp(beh.EncRemVivid,'1') & strcmp(beh.Face,'0');

booleans.Enc_RemDim=strcmp(beh.EncRemDim,'1');
booleans.Enc_RemDim_Face=strcmp(beh.EncRemDim,'1') & strcmp(beh.Face,'1');
booleans.Enc_RemDim_Plce=strcmp(beh.EncRemDim,'1') & strcmp(beh.Face,'0');

booleans.Enc_For=strcmp(beh.EncFor,'1');
booleans.Enc_Face=strcmp(beh.Face,'1') & strcmp(beh.Phase,'1');
booleans.Enc_Plce=strcmp(beh.Face,'0') & strcmp(beh.Phase,'1');

booleans.Ret_RemVivid_Face=strcmp(beh.RetRemVivid,'1') & strcmp(beh.Face,'1');
booleans.Ret_RemVivid_Plce=strcmp(beh.RetRemVivid,'1') & strcmp(beh.Face,'0');
booleans.Ret_RemVivid=strcmp(beh.RetRemVivid,'1');

booleans.Ret_RemDim_Face=strcmp(beh.RetRemDim,'1') & strcmp(beh.Face,'1');
booleans.Ret_RemDim_Plce=strcmp(beh.RetRemDim,'1') & strcmp(beh.Face,'0');
booleans.Ret_RemDim=strcmp(beh.RetRemDim,'1');

booleans.Ret_RemFam_Face=strcmp(beh.RetFam,'1') & strcmp(beh.Face,'1');
booleans.Ret_RemFam_Plce=strcmp(beh.RetFam,'1') & strcmp(beh.Face,'0');
booleans.Ret_RemFam=strcmp(beh.RetFam,'1');

booleans.Ret_For=strcmp(beh.RetFor,'1');
booleans.Ret_CR=strcmp(beh.RetCR,'1');
fn=fieldnames(booleans);
% for jj=1:length(fn)
%     Count(ii,jj)=sum(booleans.(fn{jj}));
% end
clear beh;
save(fullfile(RUN.dir.pro,[RUN.dir.subjects{ii} sav_str '_booleans.mat']),'booleans');
%-------------------------------------------------------------------------%     
% Timelock via booleans - keeping this independent for now
%-------------------------------------------------------------------------%
try
for iConditions = 1 : length(fn)
    % ERP
    cfg=[];             
    cfg.trials = (booleans.(fn{iConditions}) & ~data.reject.rejthresh);
    cfg.keeptrials='no';
    if sum(cfg.trials)>0
        timelock.(fn{iConditions}){1}=ft_timelockanalysis(cfg, data); 
        % csd_timelock.(fn{iConditions}){1}=ft_timelockanalysis(cfg, CSD.data); 
    else
        timelock.(fn{iConditions}){1}=[]; 
        % csd_timelock.(fn{iConditions}){1}=[]; 
    end
end
save(fullfile(RUN.dir.pro,[RUN.dir.subjects{ii} '_timelock' sav_str '.mat']),'timelock');

load(fullfile(RUN.dir.pro,[RUN.dir.subjects{ii} sav_str '_DPSS.mat']));
for jj=1:length(fn)
    sfdata.(fn{jj}){1}=freqlock;
    if sum(~booleans.(fn{jj}))~=length(booleans.(fn{jj}))
        sfdata.(fn{jj}){1}.powspctrm((~booleans.(fn{jj}) | data.reject.rejthresh),:,:,:)=[];
        % Can't save trials here, so simplify
        sfdata.(fn{jj}){1}.powspctrm=log10(sfdata.(fn{jj}){1}.powspctrm);
        if size(sfdata.(fn{jj}){1}.powspctrm,1)>0
            sfdata.(fn{jj}){1}=ft_freqdescriptives([],sfdata.(fn{jj}){1});
        else
            sfdata.(fn{jj}){1}=[]; 
        end
    else
        sfdata.(fn{jj}){1}=[]; 
    end
end
save(fullfile(RUN.dir.pro,[RUN.dir.subjects{ii} '_freqlock' sav_str]),'sfdata'); 

clear data;
clear sfdata freqlock;
catch err
    keyboard;
end
    end
end