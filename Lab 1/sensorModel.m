clear all; close all; clc;

plotData = true;

% Read data
load('accel.mat');

dropDist = [5 10 15 20 25 30];
dropDir  = ['x' 'y' 'z'];

% Create sensor models
mdlX = fit(dropDist', accel(:, 1), 'poly1');
mdlY = fit(dropDist', accel(:, 2), 'poly1');
mdlZ = fit(dropDist', accel(:, 3), 'poly1');

% Calculate maximum error
errX = abs((mdlX(dropDist) - accel(:, 1))./mdlX(dropDist));
errY = abs((mdlY(dropDist) - accel(:, 1))./mdlY(dropDist));
errZ = abs((mdlZ(dropDist) - accel(:, 1))./mdlZ(dropDist));

disp(['Max error X: ', num2str(max(errX) * 100), '%']);
disp(['Max error Y: ', num2str(max(errY) * 100), '%']);
disp(['Max error Z: ', num2str(max(errZ) * 100), '%']);
disp(['Mean error X: ', num2str(mean(errX) * 100), '%']);
disp(['Mean error Y: ', num2str(mean(errY) * 100), '%']);
disp(['Mean error Z: ', num2str(mean(errZ) * 100), '%']);

% Plot distance vs. mean accel for each sensor
if plotData
    figure(1);
    hold on;
    scatter(dropDist, accel(:, 1), 'r');
    scatter(dropDist, accel(:, 2), 'g');
    scatter(dropDist, accel(:, 3), 'b');
    plot(mdlX, '--r');
    plot(mdlY, '--g');
    plot(mdlZ, '--b');
    plot(dropDist, -9.8*ones(size(dropDist)));

    title('Distance vs. mean acceleration');
    xlabel('Drop distance [cm]');
    ylabel('Mean acceleration [m/s^2]');
    grid on;
    grid minor;
    ylim([-10, inf]);
    legend('x', 'y', 'z', 'x model', 'y model', 'z model', 'g');
end