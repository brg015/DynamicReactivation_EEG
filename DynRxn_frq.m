function TRNorTST=DynRxn_frq(freqlock,t,xmn,TRNorTST)

Ifrq=(freqlock.time>=t.beg & freqlock.time<=t.end);
    
% NO log10 here, we do this later
freqlock.powspctrm=freqlock.powspctrm(:,xmn.chan,:,Ifrq);
freqlock.time=freqlock.time(Ifrq);

TRNorTST.frq.time=freqlock.time;
for ii=1:size(freqlock.powspctrm,1)
    A=squeeze(freqlock.powspctrm(ii,:,:,:));
    for jj=1:size(A,3)
        B=A(:,:,jj); % chan X freq
        % Resorted B is chan THEN freq
        % i.e. [chan1.freq1, chan2.freq1, ...]
        TRNorTST.frq.val(ii,:,jj)=B(:); clear B;
    end % Time
    clear A;
end % Trial
TRNorTST.frq.chn_index=repmat(1:sum(xmn.chan),1,length(freqlock.freq));
TRNorTST.frq.frq_index=reshape(repmat(freqlock.freq,sum(xmn.chan),1),1,[]);