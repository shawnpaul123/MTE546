clear all; close all; clc;

for i = 1:5
    M = readmatrix(strcat("Sofa drops/30cm-drop", string(i), ".csv"));
    t = M(:, 1);
    aT = M(:, end);
    
    plot(t, aT);
    hold on;
end
grid on;
grid minor;
xlabel("Time [s]")
ylabel("Total acceleration [m/s^2]");
title("Raw accelerometer data for 30 cm drop");

N = 1:5;
legendCell = cellstr(num2str(N', 'Sample %-d'));
legend(legendCell);