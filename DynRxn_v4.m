function DynRxn_v4(xmn,t)
global RUN;
% v4 updates: fully customizing for this dataset, keeping it general is a
% giant pain in the ass
FRQ=true;
%-------------------------------------------------------------------------%
% Playground
%-------------------------------------------------------------------------%
% Where is information?
% -> Frequency content
% -> Phase?
% -> EEG - but at what resolution
% -> Covariance - but at what resolution
suffix='_DPSS2';
% Just need decoder (trial X feature X time)
t2=templateLinear('Learner','logistic','Lambda',xmn.lambda,'Regularization','ridge'); 
    
if strcmp(xmn.Train_str,xmn.Test_str), CROSS=false; else CROSS=true; end

for iSubj=1:length(RUN.dir.subjects)
    %---------------------------------------------------------------------%
    % Load in the data
    %---------------------------------------------------------------------%
    % -> TRN and TST might be identical here, but have sufficient memory to
    % handle having both loaded in, so whatever
    sdisp(RUN.dir.subjects{iSubj},2);
    
    load(fullfile(RUN.dir.pro,[RUN.dir.subjects{iSubj} xmn.Train_str '.mat']),'data'); 
    TRN.data=data; clear data;
    if CROSS
        load(fullfile(RUN.dir.pro,[RUN.dir.subjects{iSubj} xmn.Test_str '.mat']),'data'); 
        TST.data=data; clear data;
    end
        
    if FRQ
        load(fullfile(RUN.dir.pro,[RUN.dir.subjects{iSubj} xmn.Train_str suffix '.mat']),'freqlock'); 
        TRN.freqlock=freqlock; clear freqlock;
        if CROSS
            load(fullfile(RUN.dir.pro,[RUN.dir.subjects{iSubj} xmn.Test_str suffix '.mat']),'freqlock'); 
            TST.freqlock=freqlock; clear freqlock;
        end
    end
    %---------------------------------------------------------------------%
    load(fullfile(RUN.dir.pro,[RUN.dir.subjects{iSubj} xmn.Train_str '_booleans.mat']),'booleans'); 
    TRN.bool=booleans; clear booleans;
    if CROSS
        load(fullfile(RUN.dir.pro,[RUN.dir.subjects{iSubj} xmn.Test_str '_booleans.mat']),'booleans'); 
        TST.bool=booleans; clear booleans;
    end
    %---------------------------------------------------------------------%
    % Get class information & Frequency
    %---------------------------------------------------------------------% 
    % Reformat the data
    if FRQ
        TRN=DynRxn_frq(TRN.freqlock,t.TRN,xmn,TRN);
        TRN.t_sample.times=TRN.frq.time;
        TRN.t_sample.smooth=0.025;
        TRN.t_sample.sf=t.TRN.sf;
        TRN.t_sample.trn=t.TRN.trn;
        if CROSS
            TST=DynRxn_frq(TST.freqlock,t.TST,xmn,TST);
            TST.t_sample.times=TST.frq.time;
            TST.t_sample.smooth=0.025;
            TST.t_sample.sf=t.TST.sf;
        end
    end  
    % 4/24 changed function of parse_eeg (look up dummy) to allow for it to
    % perfectly overlap with the ERP data
    if CROSS
        TRN.smt=parse_eeg(TRN,TRN.t_sample,xmn,false);
        TST.smt=parse_eeg(TST,TST.t_sample,xmn,false);
    else
        TRN.smt=parse_eeg(TRN,TRN.t_sample,xmn,false);
    end 
%-------------------------------------------------------------------------%
% Infinite play space
%-------------------------------------------------------------------------%
% Read/write times are atrocious and when looking at non-response locked
% data we can use the same 'file' for everything, so let's do that
% Critical data here is
% -> ERP (TRN.smt)
% --> val (trial X channel X time)
% --> time (time vector)
% -> FRQ (TRN.frq)
% --> val (trial X feature X time)
% --> time (time vector)
% --> chn_index
% --> frq_index
%
% Lets train all potential models here as the read/write speeds make it
% shitty to re-load datasets, so lets just get it all in and go from there
%-------------------------------------------------------------------------%
% EtoE classification anlaysis
%-------------------------------------------------------------------------%
TRN.f1='Enc_Face'; % dimension 1
TRN.f2='Enc_Plce'; % dimension 2

TST.f1='Ret_RemVivid_Face'; % dimension 1
TST.f2='Ret_RemVivid_Plce'; % dimension 2

keyboard;
[~,time_mark]=min(abs(TRN.smt.time-t.TRN.trn));

c=1; for ii=1:length(TST.smt.time),ii
    [E(c,:),cEvd(c,:),Acc(c,:)]=DynRxn_PCA(TRN,TST,[time_mark,ii],t2);
    c=c+1;
end

figure(1);
subplot(1,3,1); plot(TST.smt.time,mean(Acc,2)); grid;
subplot(1,3,2); plot(TST.smt.time,mean(cEvd,2)); grid;
subplot(1,3,3); hist(cEvd(:));

save(fullfile('F:\Data2\Geib\DynamicReactivation\decoding_Spring2019\',...
    ['Acc_' RUN.dir.subjects{iSubj} '_' xmn.data '_' num2str(xmn.lambda*100) '_' xmn.str '.mat']),'decoder');

clear E cEvd Acc;

%-------------------------------------------------------------------------%
% EtoR classification anlaysis
%-------------------------------------------------------------------------%
TRN.f1='Enc_Face'; % dimension 1
TRN.f2='Enc_Plce'; % dimension 2

TST.f1='Ret_RemVivid_Face'; % dimension 1
TST.f2='Ret_RemVivid_Plce'; % dimension 2

keyboard;
[~,time_mark]=min(abs(TRN.smt.time-t.TRN.trn));

c=1; for ii=1:length(TST.smt.time),ii
    [E(c,:),cEvd(c,:),Acc(c,:)]=DynRxn_PCA(TRN,TST,[time_mark,ii],t2);
    c=c+1;
end

figure(1);
subplot(1,3,1); plot(TST.smt.time,mean(Acc,2)); grid;
subplot(1,3,2); plot(TST.smt.time,mean(cEvd,2)); grid;
subplot(1,3,3); hist(cEvd(:));

save(fullfile('F:\Data2\Geib\DynamicReactivation\decoding_Spring2019\',...
    ['Acc_' RUN.dir.subjects{iSubj} '_' xmn.data '_' num2str(xmn.lambda*100) '_' xmn.str '.mat']),'decoder');

clear E cEvd Acc;

end




























