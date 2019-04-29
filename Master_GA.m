RUN.dir.subjects={'1000','1001','3781','3782','108','112','113'}; 


RUN.dir.plot=true(1,7);

RUN.dir.pro='F:\Data2\Geib\DynamicReactivation\pro\v0\';

save_dir='F:\Data2\Geib\DynamicReactivation\results\';
RUN.template.plt3='F:\Data2\Geib\EEG\EEG_v1-master\templates\layoutmw64_2.mat';
load(RUN.template.plt3);

c=1; for ii=1:length(RUN.dir.subjects)
    if (RUN.dir.plot(ii)==0), continue; end
    cfg_erp.file{c}=fullfile(RUN.dir.pro,[RUN.dir.subjects{ii} '_timelock.mat']);   
    cfg_Fz.file{c}=fullfile(RUN.dir.pro,[RUN.dir.subjects{ii} '_freqlock.mat']);
    cfg_erpR.file{c}=fullfile(RUN.dir.pro,[RUN.dir.subjects{ii} '_timelock_resp.mat']);   
    cfg_FzR.file{c}=fullfile(RUN.dir.pro,[RUN.dir.subjects{ii} '_freqlock_resp.mat']);
c=c+1; end
cfg_erp.type='ERP'; 
cfg_Fz.type='FRQ';
cfg_erpR.type='ERP'; 
cfg_FzR.type='FRQ';

% for ii=1:7,ii
%     X=load(cfg_erp.file{ii}); X.timelock.Enc_Face{1}.time([1 end])
% end

%-------------------------------------------------------------------------%
% GA Land
%-------------------------------------------------------------------------%
% ERPers
ga=ft_ga_custom(cfg_erp); ga_str='ERP';
save(fullfile(save_dir,['GA7_' ga_str '.mat']),'ga'); clear ga;
ga=ft_ga_custom(cfg_erpR); ga_str='ERP';
save(fullfile(save_dir,['GA7R_' ga_str '.mat']),'ga'); clear ga;
% POWERs
ga=ft_ga_custom(cfg_Fz); ga_str='FRQ';
save(fullfile(save_dir,['GA7_' ga_str '.mat']),'ga'); clear ga;
ga=ft_ga_custom(cfg_FzR); ga_str='FRQ';
save(fullfile(save_dir,['GA7R_' ga_str '.mat']),'ga'); clear ga;

for A=1:2
    switch A
        case 1, ga_str='ERP'; load(fullfile(save_dir,['GA7_' ga_str '.mat']),'ga'); 
        case 2, ga_str='ERP'; load(fullfile(save_dir,['GA7R_' ga_str '.mat']),'ga'); 
    end
    fn=fieldnames(ga);
    for ii=1:length(fn)
        for jj=1:length(ga.(fn{ii}).cfg.previous)
            C{A}(ii,jj)=sum(ga.(fn{ii}).cfg.previous{jj}.trials);
        end
    end
end