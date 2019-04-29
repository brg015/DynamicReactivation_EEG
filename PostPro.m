clear;
subjects={'1000','1001','3781','3782'}; 
str={'all','back','front'}; strI=3;
lambda=[0.01 100];          lambdaI=1;
ana={'EtoE','EtoR'};        anaI=1;
wrk_dir='F:\Data2\Geib\DynamicReactivation\pro\v0\';
% Rows = Train
% Col = Test


title_str={'EtoE low' 'EtoE high' 'EtoR low' 'EtoR high'};
c=1; 
for anaI=[1,2]
    for lambdaI=[1:2]
for iSubj=1:length(subjects)

    if iSubj~=2
        B=load(fullfile(wrk_dir,['Acc_' subjects{iSubj} '_' ana{anaI}, ...
           '_' num2str(lambda(lambdaI)*100) '_' str{strI} '.mat']),'data2');
    else
        B=load(fullfile(wrk_dir,['Acc_frq_' subjects{iSubj} '_' ana{anaI}, ...
           '_' num2str(lambda(lambdaI)*100) '_' str{strI} '.mat']),'data2');
    end
    Acc=B.data2.acc;
    
%     figure(iSubj); set(gcf,'color','w');
%     subplot(1,2,1);
    A{c}(iSubj,:,:)=Acc.frq;
%     t=B.data2.time_freq(1:length(A));
%     surf(t,t,A); view([90,90]); colorbar; caxis([.3 .7]); colormap jet;
%     set(gca,'xlim',[t(1) t(end)]); set(gca,'ylim',[t(1) t(end)]);
%     xlabel('test time (ms)'); ylabel('train time (ms)');
    
%     subplot(1,2,2);
    C{c}(iSubj,:,:)=Acc.smt;
%     t=B.data2.time_resample;
%     surf(t,t,C); view([90,90]); colorbar; caxis([.3 .7]); colormap jet;
%     set(gca,'xlim',[t(1) t(end)]); set(gca,'ylim',[t(1) t(end)]);
%     xlabel('test time (ms)'); ylabel('train time (ms)');
end
c=c+1;
    end
end

figure(1); set(gcf,'color','w');
for ii=1:4
    subplot(2,2,ii); 
    t=B.data2.time_freq(1:length(A{ii}));
    surf(t,t,squeeze(mean(A{ii}))); view([90,90]); colorbar; caxis([.3 .7]); colormap jet;
    set(gca,'xlim',[t(1) t(end)]); set(gca,'ylim',[t(1) t(end)]);
    xlabel('test time (ms)'); ylabel('train time (ms)'); title(title_str{ii});
end

figure(2); set(gcf,'color','w');
for ii=1:4
    subplot(2,2,ii); 
    t=B.data2.time_resample;
    if (ii==1 | ii==2)
    surf(t,t,squeeze(mean(C{ii}))); view([90,90]); colorbar; caxis([.2 .8]); colormap jet;
    else
         surf(t,t,squeeze(mean(C{ii}))); view([90,90]); colorbar; caxis([.4 .6]); colormap jet;
   
    end
    set(gca,'xlim',[t(1) t(end)]); set(gca,'ylim',[t(1) t(end)]);
    xlabel('test time (ms)'); ylabel('train time (ms)'); title(title_str{ii});
end












