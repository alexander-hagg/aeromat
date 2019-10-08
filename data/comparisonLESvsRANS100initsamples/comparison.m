figure(1);
hold off;
xAxes = 1:length(RANSreloaded);
scatter(xAxes,RANSreloaded,'filled');
hold on;
scatter(xAxes,LESC,'filled');

plot(repelem(xAxes,2,1),[RANSreloaded,LESC]','k');

legend('RANS incompressible','LES compressible');

ylabel('cD');
xlabel('id');
title('Comparison RANS(i) and LES(c) 100 mirrors');

%% Best performing shapes (lowest drag)

perc = 25;

[sortRANS,sortRANSid] = sort(RANSreloaded);
[sortLESC,sortLESCid] = sort(LESC);

sortRANSid = sortRANSid(1:perc);
sortLESCid = sortLESCid(1:perc);
same = intersect(sortRANSid,sortLESCid);
length(same)/perc