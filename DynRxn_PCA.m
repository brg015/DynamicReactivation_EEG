function [E,cEvd,Acc]=DynRxn_PCA(TRN,TST,time_ind,t2)

if ~isempty(TST), CROSS=true; else, CROSS=false; end
Num_PCA=2;
%-------------------------------------------------------------------------%
% Evaluate class labels
%-------------------------------------------------------------------------%
TRN.f1d=TRN.bool.(TRN.f1) & ~TRN.data.reject.rejthresh;
TRN.f2d=TRN.bool.(TRN.f2) & ~TRN.data.reject.rejthresh;

TRN.Class=false(1,length(TRN.f1d));
TRN.Class(TRN.f1d)=true;
TRN.Class(~(TRN.f1d | TRN.f2d))=[];
% Suggest we have different train/test sets
if CROSS
    TST.f1d=TST.bool.(TST.f1) & ~TST.data.reject.rejthresh;
    TST.f2d=TST.bool.(TST.f2) & ~TST.data.reject.rejthresh;

    TST.Class=false(1,length(TST.f1d));
    TST.Class(TST.f1d)=true;
    TST.Class(~(TST.f1d | TST.f2d))=[];
end
%-------------------------------------------------------------------------%
% Remove NaNs and format data
%-------------------------------------------------------------------------%
A=squeeze(TRN.smt.val(find(TRN.f1d | TRN.f2d),:,time_ind(1))); % ERP
B=squeeze(TRN.frq.val(find(TRN.f1d | TRN.f2d),:,time_ind(1))); % FRQ
C1=[A,B]; % Combine them and remove NaNs
clear A B;
if CROSS
    A=squeeze(TST.smt.val(find(TST.f1d | TST.f2d),:,time_ind(2))); % ERP
    B=squeeze(TST.frq.val(find(TST.f1d | TST.f2d),:,time_ind(2))); % FRQ
    C2=[A,B]; % Combine them and remove NaNs
    clear A B;
    kill=(isnan(mean(C1)) | isnan(mean(C2)));
    C1(:,kill)=[]; C2(:,kill)=[];
else
    kill=isnan(mean(C1)); 
    C1(:,kill)=[]; clear kill
end
% C1 is TRN data
% C2 is TST data
% -> these should have the same features
%-------------------------------------------------------------------------%
% Evaluate output initian
%-------------------------------------------------------------------------%
if CROSS 
    Nt=size(C2,1);
    C=C2;
    Class=TST.Class;
else
    Nt=size(C1,1);
    C=C1;
    Class=TRN.Class;
end

E(1:Nt)=NaN(1,Nt);
cEvd(1:Nt)=NaN(1,Nt);
Acc(1:Nt)=NaN;

% If we have no data then bounce
if (size(C1,2)==0 || size(C2,2)==0)
    disp('No data here'); return;
end
%-------------------------------------------------------------------------%
% If we're doing CROSS, then setup all the init conditions here
%-------------------------------------------------------------------------%
if CROSS
    [coeff,score,~,~,explained,mu]=pca(C1);

    for PCAuse=1:size(coeff,2)
        rData=score(:,PCAuse);        
        vC1=rData(TRN.Class==1);
        vC2=rData(TRN.Class==0);
        [~,~,~,stat]=ttest2(vC1,vC2);
        tDiff(PCAuse)=abs(stat.tstat);
    end
    
    [v,I]=sort(tDiff,'descend'); clear tDiff;
    PCAuse=I(1:Num_PCA);
    % BrainMaps
    % Bmaps=coeff(:,PCAuse);
    % sum(explained(PCAuse(1:2)))
    % cfg.position.pnt=TRN.data.elec.pnt;
    % cfg.position.label=TRN.data.label;
    
    rData=score(:,PCAuse);
    
    Mdl=fitcecoc(double(rData),double(TRN.Class),'FitPosterior',1,'Learner',t2,'leaveout','on');
    disp(['Training Accuracy = ' num2str(mean(Mdl.kfoldPredict==TRN.Class'))]); clear Mdl;
    Mdl=fitcecoc(double(rData),double(TRN.Class),'FitPosterior',1,'Learner',t2);

    clear rData v I 
    % Critical output here is
    % -> coeff,score,explained,mu
    % -> Mdl   
    % -> PCAuse
end
%-------------------------------------------------------------------------%
% Train it
%-------------------------------------------------------------------------%
for trialN=1:Nt % for each trial

testN=trialN;
% If we're CROSS we've already done this for all trials
if ~CROSS 
    trainN=setdiff(1:size(C,1),trialN);
    [coeff,score,~,~,explained,mu]=pca(C(trainN,:)); 
end
% coeff (coeff X PC#)
% score (obs X PC#)
% latent
% data == score*coeff'
% data_reduced == score(:,PC1:PCend) * coeff(:,PC1:PCend)'
% but we want the scores
% 1) Rotate the test data and center based upon existing data
TEST=(C(testN,:)-mu); 
TEST=TEST/coeff'; % scores for left-out trial (predicted)

% sData=score(:,1:20)*coeff(:,1:20)';
% Determine which PCAs to use
if ~CROSS
    for PCAuse=1:size(coeff,2)
        rData=score(:,PCAuse);        
        vC1=rData(Class(trainN)==1);
        vC2=rData(Class(trainN)==0);
        [~,~,~,stat]=ttest2(vC1,vC2);
        tDiff(PCAuse)=abs(stat.tstat);
    end
    [~,I]=sort(tDiff,'descend'); clear tDiff;
    PCAuse=I(1:Num_PCA);% This is what matters!
end

E(trialN)=sum(explained(PCAuse));
tData=TEST(PCAuse);
% imagesc([rData(Class==1,:); rData(Class==0,:)],[-100 100]);
% a=corr(rData');
% imagesc(a([find(Class==1), find(Class==0)],[find(Class==1), find(Class==0)]));
        
if ~CROSS
    rData=score(:,PCAuse);
    Mdl=fitcecoc(double(rData),Class(trainN),'FitPosterior',1,'Learner',t2);
end

[label,~,~,Posterior]=predict(Mdl,double(tData)); % This is slower than I'd expect
    
cEvd(trialN)=Posterior(double(Class(testN))+1);
Acc(trialN)=label==Class(testN);

clear I v rData tData;
%-------------------------------------------------------------------------%    
    end % trialN loop
end

