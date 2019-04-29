function DynRxn(xmn,t)
global RUN;
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
    load(fullfile(RUN.dir.pro,[RUN.dir.subjects{iSubj} '.mat']),'data');
    load(fullfile(RUN.dir.pro,[RUN.dir.subjects{iSubj} suffix '.mat']),'freqlock');
    %---------------------------------------------------------------------%
    % Resegment the data
    %---------------------------------------------------------------------%
    % I2 -> included trials
    % Ieeg -> Included EEG times
    % Ifrq -> Included FRQ times
    %---------------------------------------------------------------------%
    keyboard;
    switch xmn.data 
        case 'EtoE'
            I=strcmp(RUN.subj{1}.beh.Phase(:),'1');
            I2=(I & ~data.reject.rejthresh'); clear I;
            E1=I2;
            E2=I2;
        case 'EtoR'
            I1=strcmp(RUN.subj{1}.beh.Phase(:),'1');
            I2=strcmp(RUN.subj{1}.beh.Phase(:),'2');
            I3=(strcmp(RUN.subj{1}.beh.RetRemVivid(:),'1') | strcmp(RUN.subj{1}.beh.RetRemDim(:),'1'));
            I=(I1 | (I2 & I3)); % Included trials
            E1=I1;
            E2=I2 & I3;
            clear I1 I2 I3;
            I2=(I & ~data.reject.rejthresh'); clear I;
            E1=E1 & I2; E1=E1(I2);% Encoding trials
            E2=E2 & I2; E2=E2(I2);% Retrieval trials
    end

    % Super easy to chop up freq
    Ifrq=(freqlock.time>=t.beg & freqlock.time<=t.end);
    
    % Results look surprisingly good w/o this transform wtf?
    freqlock.powspctrm=log10(freqlock.powspctrm(I2,xmn.chan,:,Ifrq));
    freqlock.time=freqlock.time(Ifrq);
    
    data2.time_freq=freqlock.time;
    for ii=1:size(freqlock.powspctrm,1)
        A=squeeze(freqlock.powspctrm(ii,:,:,:));
        for jj=1:size(A,3)
            B=A(:,:,jj);
            data2.freq(ii,:,jj)=B(:); clear B;
        end
        clear A;
    end
    
    % Time is harder to parse
    Ieeg=(data.time{1}>=t.beg & data.time{1}<=t.end);
    ra=floor(t.EEG/(1/t.sf)); % resample at this resolution
    ra2=floor(t.cov/(1/t.sf));
    
    data2.time=data.time{1}(Ieeg);
    data2.time_resample=data2.time(1:ra:length(data2.time));
    data2.time_resample_cov=data2.time(1:ra2:length(data2.time));

    data2.label=data.label;
    data2.elec=data.elec;

    % Runs fairly fast
    c=1; for ii=find(I2)'
        % 1) Raw EEG data
        % data2.raw(c,:,:)=data.trial{ii}(:,Ieeg);
        % 2) Downsample data
        c2=1; for jj=find(xmn.chan)
            A=conv(data.trial{ii}(jj,:),ones(ra,1),'same'); % Smooth
            B=A(Ieeg);                                      % Resample
            C=B(1:ra:length(B));                            % Segment
            data2.smooth(c,c2,:)=C; clear A B C;            % Assign
            c2=c2+1;
        end % For each channel
        % 3) Correlation structure
        c2=1; for jj=1:length(data2.time_resample_cov)
            I3=(data.time{1}>=data2.time_resample_cov(jj)-t.cov2/2 & data.time{1}<=data2.time_resample_cov(jj)+t.cov2/2);
            A=data.trial{ii}(xmn.chan,I3);    
            B=corr(A'); 
            C=B(tril(ones(size(B)),-1)==1); % Reshape already
            data2.cov(c,:,c2)=C; clear A B C I3;
            c2=c2+1;
        end
        c=c+1;
    end
    clear data freqlock;
    %---------------------------------------------------------------------%
    % Decoding analysis
    %---------------------------------------------------------------------%
    % Just need data2 really
    t2=templateLinear('Learner','logistic','Lambda',xmn.lambda,'Regularization','ridge'); 

    % Setup classes
    A=strcmp(RUN.subj{iSubj}.beh.Face,'1'); Class=A(I2); clear A;

    D=double(data2.cov);
    [Acc.cov,Acc.cov_label]=DR_decode(D,Class,E1,E2,t2);
    
    D=double(data2.smooth);
    [Acc.smt,Acc.smt_label]=DR_decode(D,Class,E1,E2,t2);
%   
    D=double(data2.freq);
    [Acc.frq,Acc.frq_label]=DR_decode(D,Class,E1,E2,t2);
    
    data2.cov=[];
    data2.smooth=[];
    data2.freq=[];
    data2.acc=Acc;
    data2.t=t;
    data2.xmn=xmn;
    
    save(fullfile('F:\Data2\Geib\DynamicReactivation\decoding\',...
        ['Acc_' RUN.dir.subjects{iSubj} '_' xmn.data '_' num2str(xmn.lambda*100) '_' xmn.str '.mat']),'data2');
end




























