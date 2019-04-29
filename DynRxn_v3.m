function DynRxn_v3(xmn,t)
global RUN;
% v3 updates
% -> better naming structure
% decoder
%   .info
%       .N      : number of total trials
%       .reject : number rejected trials
% -> other ish
FRQ=false;
%-------------------------------------------------------------------------%
% Playground
%-------------------------------------------------------------------------%
% Where is information?
% -> Frequency content
% -> Phase?
% -> EEG - but at what resolution
% -> Covariance - but at what resolution
suffix='_DPSS';
% Just need decoder (trial X feature X time)
t2=templateLinear('Learner','logistic','Lambda',xmn.lambda,'Regularization','ridge'); 
    
for iSubj=1:length(RUN.dir.subjects)
    %---------------------------------------------------------------------%
    % Load in the data
    %---------------------------------------------------------------------%
    % -> TRN and TST might be identical here, but have sufficient memory to
    % handle having both loaded in, so whatever
    sdisp(RUN.dir.subjects{iSubj},2);
    load(fullfile(RUN.dir.pro,[RUN.dir.subjects{iSubj} xmn.Train_str '.mat']),'data'); 
    TRN.data=data; clear data;
    load(fullfile(RUN.dir.pro,[RUN.dir.subjects{iSubj} xmn.Test_str '.mat']),'data'); 
    TST.data=data; clear data;
    if FRQ
        load(fullfile(RUN.dir.pro,[RUN.dir.subjects{iSubj} xmn.Train_str suffix '.mat']),'freqlock'); 
        TRN.freqlock=freqlock; clear freqlock;
        load(fullfile(RUN.dir.pro,[RUN.dir.subjects{iSubj} xmn.Test_str suffix '.mat']),'freqlock'); 
        TST.freqlock=freqlock; clear freqlock;
    end
    %---------------------------------------------------------------------%
    % Resegment the data
    %---------------------------------------------------------------------%
    % I2 -> included trials
    % Ieeg -> Included EEG times
    % Ifrq -> Included FRQ times
    %---------------------------------------------------------------------%
    load(fullfile(RUN.dir.pro,[RUN.dir.subjects{iSubj} xmn.Train_str '_booleans.mat']),'booleans'); 
    TRN.bool=booleans; clear booleans;
    load(fullfile(RUN.dir.pro,[RUN.dir.subjects{iSubj} xmn.Test_str '_booleans.mat']),'booleans'); 
    TST.bool=booleans; clear booleans;
    %---------------------------------------------------------------------%
    % Get class information & Frequency
    %---------------------------------------------------------------------% 
    [Class,decoder]=DynRxn_getclass(xmn,TRN,TST,iSubj);
    % I can't recall why this was added?
    % booleans=TST.bool;
    % save(fullfile('F:\Data2\Geib\DynamicReactivation\decoding\',[RUN.dir.subjects{iSubj} '_bool_resp']),'Class','booleans');
    % Get Frequency Information
    if FRQ
        TRN=DynRxn_frq(TRN.freqlock,t,xmn,TRN,Class.TRN_I);
        TST=DynRxn_frq(TRN.freqlock,t,xmn,TST,Class.TST_I);
    end   
    % And also get ERP information
    decoder.info.TRN.label=TRN.data.label;
    decoder.info.TRN.elec=TRN.data.elec;  
    TRN.smt=parse_eeg(TRN,t,xmn,Class.TRN_I,false);

    decoder.info.TST.label=TST.data.label;
    decoder.info.TST.elec=TST.data.elec;  
    TST.smt=parse_eeg(TST,t,xmn,Class.TST_I,false);

%  TRN.smt=parse_eeg(TRN,t,xmn,E1,true);
%       [decoder.smt.acc,decoder.smt.label,MdlE]=DR_decode_EtoR(TRN.smt.val,[],Class,t2);
%        t.trn=2.525; TRN.smt=parse_eeg(TRN,t,xmn,E1,true);
%       [decoder.smt.acc,decoder.smt.label,MdlL]=DR_decode_EtoR(TRN.smt.val,[],Class,t2);
      
%     plot(data.time{1},squeeze(mean(data.raw(Class==1,44,:))),'b'); hold on;
%     plot(data.time{2},squeeze(mean(data.raw(Class==0,44,:))),'r');
% 
%     plot(decoder.smt.time,squeeze(mean(D(Class==1,43,:))),'b'); hold on;
%     plot(decoder.smt.time,squeeze(mean(D(Class==0,43,:))),'r');
    %---------------------------------------------------------------------%
    % Decoding analysis
    %---------------------------------------------------------------------%
    switch xmn.data
        case 'EtoE'
            % Save some basic decoder information
            decoder.info.TrainNfaces=sum(Class.TRN==1);
            decoder.info.TrainNplaces=sum(Class.TRN==0);
            decoder.info.TestNfaces=sum(Class.TRN==1);
            decoder.info.TestNplaces=sum(Class.TRN==0);
            
            D=double(smt.val);    
            [decoder.smt.acc,decoder.smt.label]=DR_decode(D,Class,E1,E2,t2);
            decoder.smt.time=TRN.smt.time;
            
        case 'EtoR'
            decoder.info.TrainNfaces=sum(Class.TRN==1);
            decoder.info.TrainNplaces=sum(Class.TRN==0);
            decoder.info.TestNfaces=sum(Class.TST==1);
            decoder.info.TestNplaces=sum(Class.TST==0);
            
            D1=double(TRN.smt.val);   
            D2=double(TST.smt.val);
            decoder.smt.time=TST.smt.time;
            [decoder.smt.acc,decoder.smt.label,decoder.smt.evd]=DR_decode_EtoR(D1,D2,Class,t2);
        case 'RtoR'
            % Save some basic decoder information
            decoder.info.TrainNfaces=sum(Class.TRN==1);
            decoder.info.TrainNplaces=sum(Class.TRN==0);
            decoder.info.TestNfaces=sum(Class.TRN==1);
            decoder.info.TestNplaces=sum(Class.TRN==0);
            D=double(TRN.smt.val);    
            [decoder.smt.acc,decoder.smt.label]=DR_decode_v2(D,Class.TRN,t2);
            decoder.smt.time=TRN.smt.time; 
    end
%     D=double(decoder.cov.val);
%     [decoder.cov.acc,decoder.cov.label]=DR_decode(D,Class,E1,E2,t2);
%  TRN.smt=parse_eeg(TRN,t,xmn,E1,true);
%               [decoder.smt.acc,decoder.smt.label]=DR_decode_EtoR(D1,D2,Class,t2);
        

    % Alpha?
%     Ifrq=(decoder.frq.frq_index>=8 & decoder.frq.frq_index<=14);
%     D=log10(double(decoder.frq.val(:,Ifrq,:)));
%     [decoder.frq.alpha.acc,decoder.frq.alpha.label]=DR_decode(D,Class,E1,E2,t2);
%     
%     Ifrq=(decoder.frq.frq_index<=8);
%     D=log10(double(decoder.frq.val(:,Ifrq,:)));
%     [decoder.frq.theta.acc,decoder.frq.theta.label]=DR_decode(D,Class,E1,E2,t2);
%     
%     Ifrq=(decoder.frq.frq_index>14 & decoder.frq.frq_index<=24);
%     D=log10(double(decoder.frq.val(:,Ifrq,:)));
%     [decoder.frq.beta.acc,decoder.frq.beta.label]=DR_decode(D,Class,E1,E2,t2);
    
%     decoder.cov.val=[];
    decoder.smt.val=[];
    decoder.frq.val=[];
    decoder.info.t=t;
    decoder.info.xmn=xmn;
    
    save(fullfile('F:\Data2\Geib\DynamicReactivation\decoding_RtoR\',...
        ['Acc_' RUN.dir.subjects{iSubj} '_' xmn.data '_' num2str(xmn.lambda*100) '_' xmn.str '.mat']),'decoder');
end




























