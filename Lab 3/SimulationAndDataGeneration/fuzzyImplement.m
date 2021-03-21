clear all; close all;

%% Test
% %read sensor data
file_sensor = 'Simulation\Baseline-SoftSensorThetha.csv';
data = readmatrix(file_sensor);
%read the sensor data
t = data(:, 1);
fs = 1/(t(2) - t(1));
thetaIn = data(:, 2);
thetaUnfiltered = thetaIn;

% Low pass filter w/ passband frequency 10 Hz
thetaIn = lowpass(thetaIn, 10, fs);

N = length(thetaIn);
thetaOut = zeros(size(thetaIn));

for i = 1:N
    % Shawn this is the part you need to implement, along with tweaking
    %   the delta parameter on line 30.
    % Only input scalars to the function because making it work
    %   with vectors too is a pain.
    thetaOut(i,:) = fuzzyStercore(thetaIn(i,:));
end

%% Plot results
%!plots
figure(1);
plot(t, ones(N, 1).*[-pi/2, 0, pi/2], 'k--');
hold on;
plot(t, thetaUnfiltered, 'g', t, thetaIn, 'b', t, thetaOut, 'r');
text(max(t)/2, -pi/2 + 0.1, '-\pi/2 rad');
text(max(t)/2, 0 + 0.1, '0 rad');
text(max(t)/2, pi/2 + 0.1, '\pi/2 rad')
xlabel('Time [s]');
ylabel('Angle [rad]');
title('Soft decision for phone angle');
legend('$$-\pi/2$$ rad', '0 rad', '$$\pi/2$$ rad', 'Est. orientation (unfiltered)', 'Estimated orientation $$\hat{\theta}$$', 'Cardinal direction $$\hat{\gamma}$$', 'interpreter', 'Latex');
grid on;
saveas(figure(1),'Plots/FuzzyOutput.fig');

%% Define function

function outputAngle = fuzzyStercore(inputAngle)
    % Define fuzzy function parameters
    thetaBars = [-pi/2, 0, pi/2, pi, 3*pi/2, 2*pi];
    delta = 1;        % Probably best to keep this between 0.8 and 1
    
    % Define function array for membership functions
    membershipArr = [mu(thetaBars(1), delta, inputAngle); ...
        mu(thetaBars(2), delta, inputAngle); ...
        mu(thetaBars(3), delta, inputAngle); ...
        mu(thetaBars(4), delta, inputAngle); ...
        mu(thetaBars(5), delta, inputAngle); ...
        mu(thetaBars(6), delta, inputAngle)];
    
    if sum(membershipArr) == 0
        % If out of range, just return input angle to prevent NaNs
        outputAngle = inputAngle;
    else
        % Defuzzify using centroid method
        outputAngle = sum(thetaBars .* membershipArr')/sum(membershipArr);
    end
end

function m = mu(thetaBar, delta, theta)
    if theta < thetaBar - delta
        m = 0;
    elseif theta < thetaBar
        m = 1/delta*(theta - thetaBar) + 1;
    elseif theta < thetaBar + delta
        m = -1/delta*(theta - thetaBar) + 1;
    else
        m = 0;
    end 
end