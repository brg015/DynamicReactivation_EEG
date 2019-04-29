function [Acc,Labelsave]=DR_decode(D,Class,E1,E2,t2)

Nobs=size(D,1);  
Nt=size(D,3);

I=squeeze(mean(mean(D))); % Prevent breaking for NaNs

EtoE=sum(E1==E2)==length(E1);


for ii=1:Nt
    if isnan(I(ii)), continue; end
    for jj=1:Nt
        if isnan(I(jj)), continue; end
        if (ii==jj && EtoE) % Comparing in same time
            % Only need this for EtoE
            for kk=1:Nobs
                Mdl=fitcecoc(squeeze(D(setdiff(1:Nobs,kk),:,ii)),Class(setdiff(1:Nobs,kk)),'Learner',t2);
                label(1,kk)=predict(Mdl,squeeze(D(kk,:,jj))); % This is slower than I'd expect
            end
            Acc(ii,jj)=mean(label==Class); 
            Labelsave{ii,jj}=label; clear label;
            
        elseif ~EtoE % Comparing between trians
%                 Mdl=fitcecoc(squeeze(D(:,:,ii)),Class,'FitPosterior',1,'Learner',t);
%                 [label,~,~,Posterior]=predict(Mdl,squeeze(D(:,:,jj)));   
            if EtoE
%                 Mdl2=fitcecoc(squeeze(D(:,:,ii)),Class,'Learner',t2);
%                 label2=predict(Mdl2,squeeze(D(:,:,jj))); 
%                 Acc(ii,jj)=mean(label2==Class');
                % Treat like encoding leave-one-out
                for kk=1:Nobs
                    Mdl=fitcecoc(squeeze(D(setdiff(1:Nobs,kk),:,ii)),Class(setdiff(1:Nobs,kk)),'Learner',t2);
                    label(1,kk)=predict(Mdl,squeeze(D(kk,:,jj))); % This is slower than I'd expect
                    %Z(kk)=corr(Mdl.BinaryLearners{1}.Beta(:),Mdl2.BinaryLearners{1}.Beta(:));
                end
                Acc(ii,jj)=mean(label==Class);
                
                
            else
                % This is still fine, the trials are different
                Mdl=fitcecoc(squeeze(D(find(E1),:,ii)),Class(E1),'Learner',t2);
                label=predict(Mdl,squeeze(D(find(E2),:,jj))); 
                Acc(ii,jj)=mean(label==Class(E2)');
            end
            Labelsave{ii,jj}=label;
            clear label Posterior Mdl.
        end
    end
end