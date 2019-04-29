function [Acc,Labelsave]=DR_decode_v2(D,Class,t2)
Labelsave=[];

Nobs=size(D,1);  
Nt=size(D,3);

I=squeeze(mean(mean(D))); % Prevent breaking for NaNs

for ii=1:Nt
    if isnan(I(ii)), continue; end
%     for kk=1:Nobs
%         Mdl=fitcecoc(squeeze(D(setdiff(1:Nobs,kk),:,ii)),Class(setdiff(1:Nobs,kk)),'Learner',t2);
%         label(1,kk)=predict(Mdl,squeeze(D(kk,:,ii))); % This is slower than I'd expect
%     end
%     Acc(ii)=mean(label==Class); 
%     Labelsave{ii}=label; clear label;
    Mdl=fitcecoc(squeeze(D(:,:,ii)),Class,'Learner',t2,'Leaveout','on');
    Acc(ii)=mean(Mdl.kfoldPredict'==Class); 

end

    