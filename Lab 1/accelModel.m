clear all; close all; clc;

% This code uses the sofa drops data
dataRoot = 'Data/Sofa drops/';
minAccel = 2.0;
plotAll = false;

heights = [5 10 15 20 25 30];
nHeights = size(heights, 2);
nSamples = 5;

x = reshape(repmat(heights, 5, 1), 1, []);
y = [];

accel = zeros(size(heights));
for ii = 1:nHeights
    aSamples = zeros(1, nSamples);
    for jj = 1:nSamples
        % Read data
        M = readmatrix(strcat(dataRoot, string(heights(ii)), 'cm-drop', ...
            string(jj), '.csv'));
        t = M(:, 1);
        aT = M(:, 4);     % Read z-accel
        
        % Clip out beginning wait
        idx = abs(aT) > minAccel;
        t = t(idx);
        t = t - t(1);
        aT = aT(idx);
        
        % Calculate mean acceleration for sample
        % aSamples(jj) = mean(aT);
        aSamples(jj) = rms(aT);
    end
    y = [y, aSamples];
end

% Build linear regression model
mdl = fitlm(x, y);

% Plot linear regression model
plot(mdl);
grid on;
grid minor;
xlabel('Drop height [cm]');
ylabel('RMS acceleration [m/s^2]');
title('Acceleration vs. drop height');