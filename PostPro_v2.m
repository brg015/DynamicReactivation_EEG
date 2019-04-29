clear;
global RUN;

RUN.dir.subjects={'1000','1001','3781','3782','108','112','113'}; 
RUN.dir.plot=true(1,7);
RUN.dir.ver='v0';
RUN.dir.pro='F:\Data2\Geib\DynamicReactivation\pro\v0\';

subjects=RUN.dir.subjects;
str={'RtoR'}; strI=1;
lambda=[0.01 1 100 1000];          lambdaI=4;
ana={'RtoR'};        anaI=1;
wrk_dir='F:\Data2\Geib\DynamicReactivation\decoding_RtoR\';
% Rows = Train
% Col = Test
eeg_DR_setup()

% plot(decoder.smt.time,decoder.smt.acc(logical(eye(size(decoder.smt.acc)))))
% X=decoder.frq.time; Y=decoder.frq.beta.acc(logical(eye(size(decoder.frq.beta.acc))));
% plot(X(1:length(Y)),Y);

title_str={'EtoE low' 'EtoE high' 'EtoR low' 'EtoR high'};
c=1; 
for anaI=[1]
    for lambdaI=[4]
for iSubj=1:length(subjects)
    load(fullfile(wrk_dir,['Acc_' subjects{iSubj} '_' ana{anaI}, ...
       '_' num2str(lambda(lambdaI)*100) '_' str{strI} '.mat']),'decoder');
   
   % Stolen from DynRxn_v2 (cause info ain't saved)
   % should functionalize*
   load(fullfile(RUN.dir.pro,[RUN.dir.subjects{iSubj} '.mat']),'data');
    switch decoder.info.xmn.data 
        case 'EtoE'
            I=strcmp(RUN.subj{1}.beh.Phase(:),'1');
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
            E1=I1;         E1s=E1;
            E2=I2 & I3;    E2s=E2;
            I2=(I & ~data.reject.rejthresh'); 
            E1=E1 & I2; E1=E1(I2);% Encoding trials
            E2=E2 & I2; E2=E2(I2);% Retrieval trials
            
            decoder.info.reject=sum(data.reject.rejthresh' & I);
            decoder.info.N=sum(I2);
    end
    % E1 is bleh
    % E2 has comparison info
%     A{c}(iSubj,:,:)=decoder.frq.theta.acc;
%     B{c}(iSubj,:,:)=decoder.frq.alpha.acc;
%     C{c}(iSubj,:,:)=decoder.frq.beta.acc;
    D{c}(iSubj,:,:)=decoder.smt.acc;
    switch decoder.info.xmn.data
        case 'EtoR'
            % Divide into types
            beh=RUN.subj{iSubj}.beh;
            Viv=strcmp(beh.RetRemVivid,'1'); Viv=Viv(I3 & ~data.reject.rejthresh');
            Dim=strcmp(beh.RetRemDim,'1');   Dim=Dim(I3 & ~data.reject.rejthresh');
            Fam=strcmp(beh.RetFam,'1');      Fam=Fam(I3 & ~data.reject.rejthresh');
            Fac=strcmp(beh.Face,'1');        Fac=Fac(I3 & ~data.reject.rejthresh');
            for aa=1:length(decoder.smt.time)
                for bb=1:length(decoder.smt.time)
                    decoder.smt.acc_viv(aa,bb)=mean(decoder.smt.label{aa,bb}(Viv)==Fac(Viv)');
                    decoder.smt.acc_dim(aa,bb)=mean(decoder.smt.label{aa,bb}(Dim)==Fac(Dim)');
                    decoder.smt.acc_fam(aa,bb)=mean(decoder.smt.label{aa,bb}(Fam)==Fac(Fam)');
                end
            end
            D_Viv{c}(iSubj,:,:)=decoder.smt.acc_viv;
            D_Dim{c}(iSubj,:,:)=decoder.smt.acc_dim;
            D_Fam{c}(iSubj,:,:)=decoder.smt.acc_fam;
    end  
end
c=c+1;
    end
end

keyboard;
figure(1); set(gcf,'color','w');
IN=D; 
% t=decoder.frq.time(1:size(IN{1},3));
t=decoder.smt.time(1:size(IN{end},3));
L=1:146; t2=t(L); P='line'; cset={'r' 'g' 'b' 'k'};
S=1:7;

PL=[1,2]; c=1;
for ii=PL
    V=squeeze(mean(IN{ii}(S,:,:),1));
    switch P
        case 'surf'
            subplot(1,2,c); 
            if (ii==1 | ii==2)
                surf(t(L),t(L),V(L,L)); view([90,90]); colorbar; caxis([.4 .6]); colormap jet;
            else
                 surf(t(L),t(L),V(L,L)); view([90,90]); colorbar; caxis([.4 .6]); colormap jet;
                 shading(gca,'interp');
            end
            set(gca,'xlim',[t2(1) t2(end)]); set(gca,'ylim',[t2(1) t2(end)]);
            xlabel('test time (ms)'); ylabel('train time (ms)'); title(title_str{ii});
        case 'line'
            V=V(logical(eye(size(V))));
            plot(t(L),V(L),cset{ii},'linewidth',3);
            xlabel('time (ms)'); hold on;
            if ii==4, 
                legend(title_str([PL])); 
                set(gca,'xlim',[t2(1) t2(end)]); grid; grid minor;
                xlabel('time (s)'); ylabel('Accuracy');
                set(gca,'fontsize',14)
            end
    end
    c=c+1;
end

plot(t(L),V(L,28),'r','linewidth',3); hold on;
plot(t(L),V(L,127),'b','linewidth',3); 
set(gca,'xlim',[t2(1) t2(end)]); grid; grid minor;
xlabel('time (s)'); ylabel('Accuracy');
set(gca,'fontsize',14); grid; grid minor;
legend({'150ms','2525ms'});










