function [Acc,Labelsave,Evd,Mdl]=DR_decode_EtoR(D1,D2,Class,t2)
Acc=[]; Labelsave={};

Nobs=size(D2,1);  
Nt=size(D2,3);

I=squeeze(mean(mean(D2))); % Prevent breaking for NaNs

Mdl=fitcecoc(D1,Class.TRN,'FitPosterior',1,'Learner',t2); 
%                 [label,~,~,Posterior]=predict(Mdl,squeeze(D(:,:,jj)));   

for jj=1:Nt
    if isnan(I(jj)), continue; end

    [label,~,~,Posterior]=predict(Mdl,squeeze(D2(:,:,jj))); % This is slower than I'd expect
    Acc(jj)=mean(label'==Class.TST); 
    Labelsave{jj}=label'; clear label;
    % Postsave{jj}=Posterior;
    for kk=1:length(Posterior)
        Evd{jj}(kk)=Posterior(kk,Class.TST(kk)+1);
    end
    clear Posterior;
end

% [Posterior, label, Class.TST']