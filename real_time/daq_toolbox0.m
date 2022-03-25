% 3/25/22 Shawn Albertson
% simplest as possible script which reads data continuously, plots that
% data every time the buffer is filled, and adds the data to the workspace
clear
addpath 'C:\Users\Wavetank\Desktop\DoE FOWT\Wave Gauges\real_time\functions'

d = daq("ni");
% flush(d)
d.Rate = 30;

a0 = addinput(d, "PXI1Slot5", "ai0", "Voltage");
a2 = addinput(d, "PXI1Slot5", "ai2", "Voltage");
a4 = addinput(d, "PXI1Slot5", "ai4", "Voltage");
a6 = addinput(d, "PXI1Slot5", "ai6", "Voltage");



d.ScansAvailableFcn = @plotMyData;

d.ScansAvailableFcnCount = 60;

% start(dq, "Duration", 30)
start(d, "Continuous")


function plotMyData(obj, ~)
    [data, timestamps, ~] = read(obj, obj.ScansAvailableFcnCount, "OutputFormat", "Matrix");
    plot(timestamps, data)
    assignin('base', 'test', data)
%     [data, timestamps, ~] = read(obj, obj.ScansAvailableFcnCount, "OutputFormat", "Matrix");
%     plot(timestamps, data)
end




% n = 100;
% for i = 1:5
%     scanData = read(d,n);
%     pause(1)
% end

% start(dq, "Duration", seconds(5))
% data = read(dq);
% plot(timestamps, data)