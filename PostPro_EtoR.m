clear;
global RUN;

RUN.dir.subjects={'1000','1001','3781','3782','108','112','113'}; 
RUN.dir.plot=true(1,7);
RUN.dir.ver='v0';
RUN.dir.pro='F:\Data2\Geib\DynamicReactivation\pro\v0\';

subjects=RUN.dir.subjects;
str={'all_resp_late' 'all_resp_early' 'all_resp_mid'};     strI=1;
lambda=[1 100 1000 10000];  lambdaI=3;
ana={'EtoR'};         anaI=1;
wrk_dir='F:\Data2\Geib\DynamicReactivation\decoding\';
% Rows = Train
% Col = Test
eeg_DR_setup()

% plot(decoder.smt.time,decoder.smt.acc(logical(eye(size(decoder.smt.acc)))))
% X=decoder.frq.time; Y=decoder.frq.beta.acc(logical(eye(size(decoder.frq.beta.acc))));
% plot(X(1:length(Y)),Y);

for strI=1:3
    ii=strI;
for iSubj=1:length(subjects)
    load(fullfile(wrk_dir,['Acc_' RUN.dir.subjects{iSubj} '_' ana{anaI}, ...
        '_' num2str(lambda(lambdaI)*100) '_' str{strI} '.mat']),'decoder');
    load(fullfile('F:\Data2\Geib\DynamicReactivation\decoding\',[RUN.dir.subjects{iSubj} '_bool_resp']),'booleans','Class');
    
    Viv=booleans.Ret_RemVivid;
    Dim=booleans.Ret_RemDim;
    Fam=booleans.Ret_RemFam;
    For=booleans.Ret_For;
    LOW=(For | Fam | Dim);
    Fac=Class.TST;
    
    XY='label';
    for bb=1:length(decoder.smt.time)
%         decoder.smt.acc(bb)=mean(decoder.smt.(XY){bb}==Fac);
%         decoder.smt.acc_viv(bb)=mean(decoder.smt.(XY){bb}(Viv)==Fac(Viv));
%         decoder.smt.acc_dim(bb)=mean(decoder.smt.(XY){bb}(Dim)==Fac(Dim));
%         decoder.smt.acc_fam(bb)=mean(decoder.smt.(XY){bb}(Fam)==Fac(Fam));
%         decoder.smt.acc_low(bb)=mean(decoder.smt.(XY){bb}(LOW)==Fac(LOW));
        Dviv_bias(bb)=mean(Fac(Viv));
          decoder.smt.acc(bb)=mean(decoder.smt.evd{bb});
        decoder.smt.acc_viv(bb)=mean(decoder.smt.evd{bb}(Viv));
        decoder.smt.acc_dim(bb)=mean(decoder.smt.evd{bb}(Dim));
        decoder.smt.acc_fam(bb)=mean(decoder.smt.evd{bb}(Fam));
        decoder.smt.acc_low(bb)=mean(decoder.smt.evd{bb}(LOW));
    end
 
    D{ii}(iSubj,:)=decoder.smt.acc;

    DViv{ii}(iSubj,:)=decoder.smt.acc_viv;
    DVivb{ii}(iSubj,:)=Dviv_bias;
    DDim{ii}(iSubj,:)=decoder.smt.acc_dim;
    DFam{ii}(iSubj,:)=decoder.smt.acc_fam;
    DLow{ii}(iSubj,:)=decoder.smt.acc_low;
end
end

keyboard;
figure(1); set(gcf,'color','w'); N=1;
plot(decoder.smt.time,nanmean(D{N}),'b','linewidth',3); hold on;
% plot(decoder.smt.time,nanmean(DLow{N}),'b:','linewidth',3); hold on;
plot(decoder.smt.time,nanmean(D{N+1}),'k','linewidth',3); hold on;
% plot(decoder.smt.time,nanmean(DLow{N+1}),'k:','linewidth',3); hold on;
plot(decoder.smt.time,nanmean(D{N+2}),'r','linewidth',3); hold on;
% plot(decoder.smt.time,nanmean(DLow{N+2}),'r:','linewidth',3); hold on;

% legend({'Late Viv' 'Late Low' 'Early Viv' 'Early Low' 'Mid Viv' 'Mid Low'});
legend({'Late','Early'})
set(gca,'fontsize',16);
set(gca,'ylim',[.35 .65]); grid; grid minor;

plot(decoder.smt.time,DViv{N},'linewidth',3); legend;







