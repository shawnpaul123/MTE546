close all; clear all;

%% Instructions for use
% Change what needs to be changed, then remember to change the
% caseName variable so that you write the correct file name.
% I changed the test case by commenting/uncommenting the relevant lines.

% Case names: (script is currently set to 'baseline')
%   baseline: u = 1 cm/s, standard sensor and system noise
%   10xSensNoise: baseline, but with 10x the sensor noise
%   10xSystNoise: basline, but with 10x the system noise
%   yMotion: baseline, but with u = 0 cm/s and v = 1 cm/s
%   stationary: baseline, but with u = 0 cm/s

%% Set up
dt = 0.1;
t = 0:dt:10;
N = length(t);

% 'True' state vector
X = zeros(4, N);

% Velocity noise covariance
stateNoise = 0.1*eye(2);
% stateNoise = 10*0.1*eye(2);

% Sensor noise covariance
senseNoise = [0.21337 0; ...
              0       0.022288];
% senseNoise = 10*[0.21337 0; ...
%                 0       0.022288];

% Simulated sensor model
h = @(x, y) [(8.3741*x + 0.2395)./(x + 0.0123); ...
             (8.3558*y + 1.3344)./(y + 0.1294)];

%% Simulate motion
% Set velocity profile
u = 1*ones(1, N);
v = 0*ones(1, N);
% u = 0*ones(1, N);
% v = 1*ones(1, N);
% u = 0*ones(1, N);
% v = 0*ones(1, N);

% Calculate noise
randn('seed', 0);       % I don't think this line is necessary?
w  = mvnrnd([0 0], stateNoise, N)';
v1 = mvnrnd([0 0], senseNoise, N)';

% Add noise to states
u = u + w(1, :);
v = v + w(2, :);

% Calculate displacement
x = cumtrapz(t, u);
y = cumtrapz(t, v);
% Shawn, stop giggling

% Feed position to sensor to calculate accelerations
Y = h(x, y);
axSense = Y(1, :);
aySense = Y(2, :);

% Add noise to sensor readings
axSense = axSense + v1(1, :);
aySense = aySense + v1(2, :);

%% Plot simulated data
figure(1);
plot(t, axSense, t, aySense);
title('Sensor output');
legend('ax', 'ay');
xlabel('Time [s]');
ylabel('Acceleration [cm/s^2]');

figure(2);
plot(t, x, t, y);
yyaxis right;
plot(t, u, t, v);
ylabel('Velocity [cm/s]');
yyaxis left;
title('Ground truth');
xlabel('Time [s]');
ylabel('Position [cm]');
legend('x', 'y', 'u', 'v');

%% Write data files
% Change this to change the file name
caseName = 'baseline';

M = [t; x; y; u; v]';
writematrix(M, ['Simulation/' caseName '-groundtruth.csv']);
M = [t; axSense; aySense]';
writematrix(M, ['Simulation/' caseName '-sensordata.csv']);