clear all; close all; clc;

% for i = 1:5
%     M = readmatrix(strcat("Data/Sofa drops/30cm-drop", string(i), ".csv"));
%     t = M(:, 1);
%     aT = M(:, end);
%     
%     % Clip out beginning
%     idx = aT > 5.0;
%     t = t(idx);
%     t = t - t(1);
%     aT = aT(idx);
%     
%     plot(t, aT);
%     hold on;
% end

M = readmatrix('Data/Sofa drops/5cm-drop4.csv');
plot(M(:, 1), M(:, 2:end-1));
legend('ax', 'ay', 'az');

grid on;
grid minor;
xlabel("Time [s]")
ylabel("Total acceleration [m/s^2]");
title("Raw accelerometer data for 30 cm drop");

% N = 1:5;
% legendCell = cellstr(num2str(N', 'Sample %-d'));
% legend(legendCell);