function smt=parse_eeg(TRN,t,xmn,singleT)

 % Time is harder to parse
if ~singleT
    Ieeg=(TRN.data.time{1}>=t.times(1) & TRN.data.time{1}<=t.times(end));
    L=TRN.data.time{1}(Ieeg);
    for ii=1:length(t.times)
        [~,I]=min(abs(t.times(ii)-L));
        vI(ii)=I;
    end
else
    [~,I]=min(abs(TRN.data.time{1}-t.trn));
    Ieeg=false(1,length(TRN.data.time{1})); Ieeg(I)=true; 
    smt.time=TRN.data.time{1}(I); clear I;
end

ra=floor(t.smooth/(1/t.sf)); % Smooothing kernel
% ra2=floor(t.cov/(1/t.sf));

% decoder.cov.time=TRN.data.time(1:ra2:length(TRN.data.time));

% Runs fairly fast
c=1; for ii=1:length(TRN.data.trial)
    % 1) Raw EEG data
    % data.raw(c,:,:)=data.trial{ii}(:,:);
    % 2) Downsample data
    c2=1; for jj=find(xmn.chan)
        A=conv(TRN.data.trial{ii}(jj,:),ones(ra,1),'same'); % Smooth
        B=A(Ieeg);                                          % Chop
        smt.val(c,c2,:)=B(vI); clear A B C;            % Assign
        c2=c2+1;
    end % For each channel
    % 3) Correlation structure
%         c2=1; for jj=1:length(decoder.cov.time)
%             I3=(data.time>=decoder.cov.time(jj)-t.cov2/2 & data.time<=decoder.cov.time(jj)+t.cov2/2);
%             A=data.trial{ii}(xmn.chan,I3);    
%             B=corr(A'); 
%             C=B(tril(ones(size(B)),-1)==1); % Reshape already
%             decoder.cov.val(c,:,c2)=C; clear A B C I3;
%             c2=c2+1;
%         end
    c=c+1;
end

smt.time=t.times;
% if ~singleT
%     smt.time=linspace(t.beg,t.end,size(smt.val,3));
% end
