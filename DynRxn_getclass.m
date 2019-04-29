function [Class,decoder]=DynRxn_getclass(xmn,TRN,TST,iSubj)
global RUN;
% Clean me up please!
switch xmn.data 
        case 'EtoE'
            fn=fieldnames(TRN.bool);
            % Only include trials correctly epoched
            % for jj=1:length(fn),TRN.bool.(fn{jj})=TRN.bool.(fn{jj})(TRN.data.trialsN); end
            I=strcmp(RUN.subj{iSubj}.beh.Phase(TRN.data.trialsN),'1'); % Enc is phase 1
            I2=(I' & ~TRN.data.reject.rejthresh');       % Nonrejected trials
            for jj=1:length(fn), TRN.bool.(fn{jj})=TRN.bool.(fn{jj})(I2); end
            decoder.info.bool=TRN.bool;
            
            E1=I2'; % Indexes into TRN
            E2=I2'; % Indexes into TST

            % decoder.info.reject=sum(TRN.data.reject.rejthresh(E1));
            decoder.info.N=sum(E1);
            
            % Setup classes
            A=strcmp(RUN.subj{iSubj}.beh.Face(TRN.data.trialsN),'1'); 
            Class.TRN=A(E1); clear A;
            Class.TRN_I=E1;
            A=strcmp(RUN.subj{iSubj}.beh.Face(TST.data.trialsN),'1'); 
            Class.TRN=A(E2); clear A;
            Class.TST_I=E2;
            
            clear I;
        case 'EtoR'
            I1=strcmp(RUN.subj{iSubj}.beh.Phase(TRN.data.trialsN),'1');
            I2=strcmp(RUN.subj{iSubj}.beh.Phase(TST.data.trialsN),'2');
            I3=(strcmp(RUN.subj{iSubj}.beh.RetRemVivid(TST.data.trialsN),'1') | ...
                strcmp(RUN.subj{iSubj}.beh.RetRemDim(TST.data.trialsN),'1') | ...
                strcmp(RUN.subj{iSubj}.beh.RetFam(TST.data.trialsN),'1') | ...
                strcmp(RUN.subj{iSubj}.beh.RetFor(TST.data.trialsN),'1'));
            % Training index
            E1=I1 & ~TRN.data.reject.rejthresh;
            E2=(I2 & I3) & ~TST.data.reject.rejthresh;

            % decoder.info.TRN.reject=sum(TRN.data.reject.rejthresh' & E1);
            decoder.info.TRN.N=sum(E1);
            
            % decoder.info.TST.reject=sum(TST.data.reject.rejthresh' & E2);
            decoder.info.TST.N=sum(E2);
            
            % Setup classes
            A=strcmp(RUN.subj{iSubj}.beh.Face(TRN.data.trialsN),'1'); 
            Class.TRN=A(E1); clear A;
            Class.TRN_I=E1;
            % 2/14 -> this looks wrong? Shouldn't it be 2?
            % Changed - maybe this will be saving grace...
            A=strcmp(RUN.subj{iSubj}.beh.Face(TST.data.trialsN),'1'); 
            Class.TST=A(E2); clear A;
            Class.TST_I=E2;
            fn=fieldnames(TRN.bool);
            % for jj=1:length(fn), TRN.bool.(fn{jj})=TRN.bool.(fn{jj})(TRN.data.trialsN); end
            for jj=1:length(fn), TRN.bool.(fn{jj})=TRN.bool.(fn{jj})(E1); end
            
            fn=fieldnames(TST.bool);
            % for jj=1:length(fn), TST.bool.(fn{jj})=TST.bool.(fn{jj})(TST.data.trialsN); end
            for jj=1:length(fn), TST.bool.(fn{jj})=TST.bool.(fn{jj})(E2); end
            
            clear I I1 I2 I3;
        case 'RtoR'
            fn=fieldnames(TRN.bool);
            % Only include trials correctly epoched
            % for jj=1:length(fn),TRN.bool.(fn{jj})=TRN.bool.(fn{jj})(TRN.data.trialsN); end
            I=strcmp(RUN.subj{iSubj}.beh.Phase(TRN.data.trialsN),'2'); % Enc is phase 1
            I(strcmp(RUN.subj{iSubj}.beh.old,'0'))=false;              % Remove new trials
            I2=(I' & ~TRN.data.reject.rejthresh');       % Nonrejected trials
            for jj=1:length(fn), TRN.bool.(fn{jj})=TRN.bool.(fn{jj})(I2); end
            decoder.info.bool=TRN.bool;
            
            E1=I2'; % Indexes into TRN
            E2=I2'; % Indexes into TST

            % decoder.info.reject=sum(TRN.data.reject.rejthresh(E1));
            decoder.info.N=sum(E1);
            
            % Setup classes
            A=strcmp(RUN.subj{iSubj}.beh.Face(TRN.data.trialsN),'1'); 
            Class.TRN=A(E1); clear A;
            Class.TRN_I=E1;
            A=strcmp(RUN.subj{iSubj}.beh.Face(TST.data.trialsN),'1'); 
            Class.TRN=A(E2); clear A;
            Class.TST_I=E2;
            
            clear I;
            
end