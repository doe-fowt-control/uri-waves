% Compute gradient of tt using Savitsky-Golay least sqauredifferentiation

[b,g] = sgolay(3,11);

for i=1:N
    ttrow(:)   = tt(i,:);
    txg(i,1:M) = 0;
    txg(i,:)   = conv(ttrow,1/(-dxy) * g(:,2), 'same');
end

for j=1:M
    ttclm(:)   = tt(:,j);
    tyg(1:N,j) = 0;
    tyg(:,j)   = conv(ttclm,1/(-dxy) * g(:,2), 'same');
end

% Noramalize txg and tyg
dtg  = sqrt(txg.^2 + tyg.^2); 
txn = txg./dtg;
tyn = tyg./dtg;