clear all; close all; clc;

Mx = readmatrix('Data/Accelerometer_data/45deg_drop/30cm-z-x45deg.csv');
My = readmatrix('Data/Accelerometer_data/45deg_drop/30cm-z-y45deg.csv');

% Begin cropping
lower = 9;
upper = 15;

aT = Mx(:, end);
N = length(aT);
select = false(1, N);
for k = 1:N
    if aT(k) > lower
        if aT(k) > upper
            break;
        end
        select(k) = true;
    end
end
Mx = Mx(select', :);
Mx(:, 1) = Mx(:, 1) - Mx(1, 1);

aT = My(:, end);
N = length(aT);
select = false(1, N);
for k = 1:N
    if aT(k) > lower
        if aT(k) > upper
            break;
        end
        select(k) = true;
    end
end
My = My(select', :);
My(:, 1) = My(:, 1) - My(1, 1);

meanMx = mean(Mx(:, 2:end), 1);
meanMy = mean(My(:, 2:end), 1);

% % Plots
% figure(1);
% plot(Mx(:, 1), Mx(:, 2:end));
% title('Drop data for rotation of 45^{\circ} in x');
% xlabel('Time [s]');
% ylabel('Acceleration [m/s^2]');
% legend('x', 'y', 'z', 'Total');
% grid on;
% grid minor;
% 
% figure(2);
% plot(My(:, 1), My(:, 2:end));
% title('Drop data for rotation of 45^{\circ} in y');
% xlabel('Time [s]');
% ylabel('Acceleration [m/s^2]');
% legend('x', 'y', 'z', 'Total');
% grid on;
% grid minor;