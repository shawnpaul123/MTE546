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

M = readmatrix('Data/Accelerometer_data/3axis_drop/15cm-y.csv');
t = M(:, 1);
ax = M(:, 2);
ay = M(:, 3);
az = M(:, 4);
aT = M(:, end);
N = length(t);

lower = 8;
upper = 15;
select = false(1, N);
for i = 1:N
    if aT(i) > lower
        if aT(i) > upper
            break;
        end
        select(i) = true;
    end
end

figure(1);
plot(M(select, 1), M(select, 2:end));
legend('ax', 'ay', 'az', 'tot');

grid on;
grid minor;
xlabel("Time [s]")
ylabel("Total acceleration [m/s^2]");
title("Raw accelerometer data");

figure(2);
plot(M(:, 1), M(:, 2:end));
legend('ax', 'ay', 'az', 'tot');

grid on;
grid minor;
xlabel("Time [s]")
ylabel("Total acceleration [m/s^2]");
title("Raw accelerometer data");

% N = 1:5;
% legendCell = cellstr(num2str(N', 'Sample %-d'));
% legend(legendCell);