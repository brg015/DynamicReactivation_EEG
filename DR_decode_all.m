% D1 - training data [Trial X Feature X Time]
% D2 - test data [Trial X Feature X Time]
% Class
%   .TRN = TRN labels
%   .TRN_I = Index of TRN trials (out of all)
%   *same format for TST
% t2 - classifier information
% t  - t.trn (time to train on*)

function [Acc,Labelsave,Evd,Mdl]=DR_decode_all(D1,D2,Class,t2,train_time,decoder)
Acc=[]; Labelsave={}; Evd={}; Mdl={};
%-------------------------------------------------------------------------%
% Get some of the basics
%-------------------------------------------------------------------------%
% Get information on the testing set
% *if we are training-testing within phase, this is also fine because the
% size of the train and test sets is equal
Nobs=size(D2,1); % Number of observations 
Nt=size(D2,3);   % Number of time points
% Determine if we are training and testing on all time points or just 1
% *if match_time is false we train on one timepoint and test all
match_time=isempty(train_time);
% Prevent training set from crashing if NaNs exist
I=squeeze(mean(mean(D2))); % Prevent breaking for NaNs

%-------------------------------------------------------------------------%
if ~match_time % i.e. train on one test on all
    %---------------------------------------------------------------------%
    % Make awesome encoding model, kick out bad trials too
    %---------------------------------------------------------------------%
    % Squeeze data into time dimension of interest
    D1=squeeze(D1(:,:,train_time)); % [Class X Feature]

    a=corr(D1','type','Spearman');
    imagesc(a([find(Class.TRN==1) find(Class.TRN==0)],[find(Class.TRN==1) find(Class.TRN==0)]));

    Mdl=fitcecoc(D1,Class.TRN,'FitPosterior',1,'Learner',t2); 
    for ii=1:size(D1,1)
        [label(ii),~,~,Posterior(ii,:)]=predict(Mdl,squeeze(D1(ii,:)));
        cEvd(ii)=Posterior(ii,Class.TRN(ii)+1);
    end
    I_excellent=cEvd>0.7;
keyboard;

    clear label Posterior cEvd;
    A=Class.TRN(I_excellent);
    B=D1(I_excellent,:);
    Mdl=fitcecoc(B,A,'FitPosterior',1,'Learner',t2); 
    for ii=1:sum(I_excellent)
        [label(ii),~,~,Posterior(ii,:)]=predict(Mdl,squeeze(B(ii,:)));
        cEvd(ii)=Posterior(ii,A(ii)+1);
    end
   mean(cEvd>0.5)

    a=corr(B','type','Spearman');
    imagesc(a([find(A==1) find(A==0)],[find(A==1) find(A==0)]));
keyboard;
    %---------------------------------------------------------------------%
    % Now try to decode
    %---------------------------------------------------------------------%
    clear label Posterior cEvd;
    for ii=1:size(D2,3) % Time
        for jj=1:size(D2,1) % Trial
            [label(jj),~,~,Posterior(jj,:)]=predict(Mdl,squeeze(D2(jj,:,ii)));
            cEvd(jj,ii)=Posterior(ii,Class.TST(jj)+1); % [trial X time]
        end
    end

    I0=find(Class.TST==0); I0=[I0 I0];
    I1=find(Class.TST==1); I1=[I1 I1]; % allow to wrap around
    for ii=1:size(D2,3) % Time
        for jj=1:size(D2,1) % Trial
            if sum(jj==I0)>0 % I0 trial
                L=find(jj==I0);
                S=[I0(L:L+1)];
                IN=mean(squeeze(D2(S,:,ii)));
            else % I1 trial
                L=find(jj==I1);
                S=[I0(L:L+1)];
                IN=mean(squeeze(D2(S,:,ii)));
            end
            [label(jj),~,~,Posterior(jj,:)]=predict(Mdl,IN);
            cEvd(jj,ii)=Posterior(ii,Class.TST(jj)+1); % [trial X time]
            clear IN L S;
        end
    end


    plot(decoder.smt.time,mean(cEvd))
keyboard;

    House_Evd=Posterior(Class.TRN==0,1);
    Face_Evd=Posterior(Class.TRN==1,2);

    Acc(ii)=mean(Mdl.kfoldPredict'==Class); 

else % train/test all time points
    
end
% 
% for jj=1:Nt
%     if isnan(I(jj)), continue; end
% 
%     [label,~,~,Posterior]=predict(Mdl,squeeze(D2(:,:,jj))); % This is slower than I'd expect
%     Acc(jj)=mean(label'==Class.TST); 
%     Labelsave{jj}=label'; clear label;
%     % Postsave{jj}=Posterior;
%     for kk=1:length(Posterior)
%         Evd{jj}(kk)=Posterior(kk,Class.TST(kk)+1);
%     end
%     clear Posterior;
% end

% [Posterior, label, Class.TST']