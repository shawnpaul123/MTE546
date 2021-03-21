close all; clear all;
caseName = 'Baseline';
%goal-> generate thetha from ekf
filename = 'Simulation\baseline-ekfdata.csv';
filename2 = 'Simulation\baseline-thetha_hist.csv';
data = readmatrix(filename);
%read the sensor data
t = data(:, 1);
vx = data(:, 4);
vy = data(:, 5);
%soft sensor implementation
thetha = atan2(vy,vx);
%save soft senosr data
M = [t  thetha];
writematrix(M, ['Simulation/' caseName '-SoftSensorThetha.csv']);
%plot soft sensor thetha along with actual thetha
data2 = readmatrix(filename2);
t2 = data2(:, 1);
thetha_real = data2(:, 2);
%plot graph of softsensor and real thetha
figure(1);
plot(t, thetha, t, thetha_real);
xlabel('Time [s]');
ylabel('Thetha vs Thetha Pred [rad]');
title('Comparing Soft Sensor and Real Orientation');
legend('Soft Sensor', 'Real Orientation');
saveas(figure(1),'Plots/Soft_Sensor.fig');




