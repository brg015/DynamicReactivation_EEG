function DynRxn_v2(xmn,t)
global RUN;
% v2 updates
% -> better naming structure
% decoder
%   .info
%       .N      : number of total trials
%       .reject : number rejected trials
%-------------------------------------------------------------------------%
% Playground
%-------------------------------------------------------------------------%
% Where is information?
% -> Frequency content
% -> Phase?
% -> EEG - but at what resolution
% -> Covariance - but at what resolution
suffix='_DPSS';

for iSubj=1:length(RUN.dir.subjects)
    % Load in the data
    sdisp(RUN.dir.subjects{iSubj},2);
    load(fullfile(RUN.dir.pro,[RUN.dir.subjects{iSubj} '.mat']),'data');
    load(fullfile(RUN.dir.pro,[RUN.dir.subjects{iSubj} suffix '.mat']),'freqlock');
    %---------------------------------------------------------------------%
    % Resegment the data
    %---------------------------------------------------------------------%
    % I2 -> included trials
    % Ieeg -> Included EEG times
    % Ifrq -> Included FRQ times
    %---------------------------------------------------------------------%
    switch xmn.data 
        case 'EtoE'
            I=strcmp(RUN.subj{iSubj}.beh.Phase(:),'1');
            I2=(I & ~data.reject.rejthresh'); 
            E1=I2;
            E2=I2;
            
            decoder.info.reject=sum(data.reject.rejthresh' & I);
            decoder.info.N=sum(I2);
            clear I;
        case 'EtoR'
            I1=strcmp(RUN.subj{iSubj}.beh.Phase(:),'1');
            I2=strcmp(RUN.subj{iSubj}.beh.Phase(:),'2');
            I3=(strcmp(RUN.subj{iSubj}.beh.RetRemVivid(:),'1') | strcmp(RUN.subj{iSubj}.beh.RetRemDim(:),'1') | ...
                strcmp(RUN.subj{iSubj}.beh.RetFam(:),'1') | strcmp(RUN.subj{iSubj}.beh.RetFor(:),'1'));
            I=(I1 | (I2 & I3)); % Included trials
            E1=I1;
            E2=I2 & I3;
            clear I1 I2 I3;
            I2=(I & ~data.reject.rejthresh'); 
            E1=E1 & I2; E1=E1(I2);% Encoding trials
            E2=E2 & I2; E2=E2(I2);% Retrieval trials
            
            decoder.info.reject=sum(data.reject.rejthresh' & I);
            decoder.info.N=sum(I2);
            clear I;
    end

    % Super easy to chop up freq
    Ifrq=(freqlock.time>=t.beg & freqlock.time<=t.end);
    
    % NO log10 here, we do this later
    freqlock.powspctrm=freqlock.powspctrm(I2,xmn.chan,:,Ifrq);
    freqlock.time=freqlock.time(Ifrq);
    
    decoder.frq.time=freqlock.time;
    for ii=1:size(freqlock.powspctrm,1)
        A=squeeze(freqlock.powspctrm(ii,:,:,:));
        for jj=1:size(A,3)
            B=A(:,:,jj); % chan X freq
            % Resorted B is chan THEN freq
            % i.e. [chan1.freq1, chan2.freq1, ...]
            decoder.frq.val(ii,:,jj)=B(:); clear B;
        end % Time
        clear A;
    end % Trial
    decoder.frq.chn_index=repmat(1:sum(xmn.chan),1,length(freqlock.freq));
    decoder.frq.frq_index=reshape(repmat(freqlock.freq,sum(xmn.chan),1),1,[]);
    
    % Time is harder to parse
    Ieeg=(data.time{1}>=t.beg & data.time{1}<=t.end);
    ra=floor(t.EEG/(1/t.sf)); % resample at this resolution
    ra2=floor(t.cov/(1/t.sf));
    
    data.time=data.time{1}(Ieeg);
    
    decoder.smt.time=data.time(1:ra:length(data.time));
    decoder.cov.time=data.time(1:ra2:length(data.time));

    decoder.info.label=data.label;
    decoder.info.elec=data.elec;

    % Runs fairly fast
    c=1; for ii=find(I2)'
        % 1) Raw EEG data
        % data.raw(c,:,:)=data.trial{ii}(:,:);
        % 2) Downsample data
        c2=1; for jj=find(xmn.chan)
            A=conv(data.trial{ii}(jj,:),ones(ra,1),'same'); % Smooth
            B=A(Ieeg);                                      % Resample
            C=B(1:ra:length(B));                            % Segment
            decoder.smt.val(c,c2,:)=C; clear A B C;            % Assign
            c2=c2+1;
        end % For each channel
        % 3) Correlation structure
%         c2=1; for jj=1:length(decoder.cov.time)
%             I3=(data.time>=decoder.cov.time(jj)-t.cov2/2 & data.time<=decoder.cov.time(jj)+t.cov2/2);
%             A=data.trial{ii}(xmn.chan,I3);    
%             B=corr(A'); 
%             C=B(tril(ones(size(B)),-1)==1); % Reshape already
%             decoder.cov.val(c,:,c2)=C; clear A B C I3;
%             c2=c2+1;
%         end
        c=c+1;
    end
    clear data freqlock;
    
%     plot(data.time{1},squeeze(mean(data.raw(Class==1,44,:))),'b'); hold on;
%     plot(data.time{2},squeeze(mean(data.raw(Class==0,44,:))),'r');
% 
%     plot(decoder.smt.time,squeeze(mean(D(Class==1,43,:))),'b'); hold on;
%     plot(decoder.smt.time,squeeze(mean(D(Class==0,43,:))),'r');
    %---------------------------------------------------------------------%
    % Decoding analysis
    %---------------------------------------------------------------------%
    % Just need decoder (trial X feature X time)
    t2=templateLinear('Learner','logistic','Lambda',xmn.lambda,'Regularization','ridge'); 

    % Setup classes
    A=strcmp(RUN.subj{iSubj}.beh.Face,'1'); Class=A(I2); clear A;
    switch xmn.data
        case 'EtoE'
            decoder.info.TrainNfaces=sum(Class==1);
            decoder.info.TrainNplaces=sum(Class==0);
            decoder.info.TestNfaces=sum(Class==1);
            decoder.info.TestNplaces=sum(Class==0);
        case 'EtoR'
            decoder.info.TrainNfaces=sum(Class(E1)==1);
            decoder.info.TrainNplaces=sum(Class(E1)==0);
            decoder.info.TestNfaces=sum(Class(E2)==1);
            decoder.info.TestNplaces=sum(Class(E2)==0);
    end
%     D=double(decoder.cov.val);
%     [decoder.cov.acc,decoder.cov.label]=DR_decode(D,Class,E1,E2,t2);

    D=double(decoder.smt.val);    
    [decoder.smt.acc,decoder.smt.label]=DR_decode(D,Class,E1,E2,t2);

    % Alpha?
    Ifrq=(decoder.frq.frq_index>=8 & decoder.frq.frq_index<=14);
    D=log10(double(decoder.frq.val(:,Ifrq,:)));
    [decoder.frq.alpha.acc,decoder.frq.alpha.label]=DR_decode(D,Class,E1,E2,t2);
    
    Ifrq=(decoder.frq.frq_index<=8);
    D=log10(double(decoder.frq.val(:,Ifrq,:)));
    [decoder.frq.theta.acc,decoder.frq.theta.label]=DR_decode(D,Class,E1,E2,t2);
    
    Ifrq=(decoder.frq.frq_index>14 & decoder.frq.frq_index<=24);
    D=log10(double(decoder.frq.val(:,Ifrq,:)));
    [decoder.frq.beta.acc,decoder.frq.beta.label]=DR_decode(D,Class,E1,E2,t2);
    
%     decoder.cov.val=[];
    decoder.smt.val=[];
    decoder.frq.val=[];
    decoder.info.t=t;
    decoder.info.xmn=xmn;
    
    save(fullfile('F:\Data2\Geib\DynamicReactivation\decoding\',...
        ['Acc_' RUN.dir.subjects{iSubj} '_' xmn.data '_' num2str(xmn.lambda*100) '_' xmn.str '.mat']),'decoder');
end




























