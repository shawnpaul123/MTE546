close all; clear all;

%% Read in data
filename = 'Data/slide +x.csv';
data = readmatrix(filename);

% % Crop out beginning
% idx = (data(:, 1) > 2.5) & (data(:, 1) < 6.5);
% data = data(idx, :);

% Convert to cm/s^2
data(:, 2:end) = 100*data(:, 2:end);

t = data(:, 1);
ax = data(:, 2);
ay = data(:, 3);
%not needed below as z direction doesn't count
%az = data(:, 4);

N = length(t);

%% Setup
% Define models
A = @(T) [1 0 T 0; ...
          0 1 0 T; ...
          0 0 1 0; ...
          0 0 0 1];

Q = 0.025*eye(4);
R = [0.21337 0; 0 0.022288];

% Initial conditions
X0 = [0 0 0 0]';
Pk = eye(4);

% Set up variables
X = zeros(4, N);
X(:, 1) = X0;

%% EKF
for i = 1:N-1
    T = t(i+1) - t(i);
    Xk = X(:, i);
    Ak = A(T);
    
    % Predict
    Xhatk1 = Ak*Xk;
    Yhatk1 = h(Xk);
    
    Pk = Ak*Pk*Ak' + Q;
    Hk = H(Xk);
    
    % Correct w/ sensor data
    Yk = [ax(i); ay(i)];
    
    K = (Pk*Hk')*inv(Hk*Pk*Hk' + R);
    Xhatk1 = Xhatk1 + K*(Yk - Yhatk1);
    Pk = (eye(4) - K*Hk)*Pk;
    
    % Save corrected state prediction
    X(:, i+1) = Xhatk1;
end

x = X(1, :);
y = X(2, :);
u = X(3, :);
v = X(4, :);

%% Numerical integration
uint = cumtrapz(t, ax);
vint = cumtrapz(t, ay);
xint = cumtrapz(t, uint);
yint = cumtrapz(t, vint);

%% Plot results
% EKF
figure(1);
plot(t, x, t, y);
ylabel('Position [cm]');
yyaxis right;
plot(t, u, t, v, 'g-');
ylabel('Velocity [cm/s]');
xlabel('Time [s]');
legend('x', 'y', 'u', 'v');
title('EKF state vector progression');

grid on;
grid minor;

% Numerical integration
figure(2);
plot(t, xint, t, yint);
ylabel('Position [cm]');
yyaxis right;
plot(t, uint, t, vint, 'g-');
ylabel('Velocity [cm/s]');
xlabel('Time [s]');
legend('x', 'y', 'u', 'v');
title('Prediction by sensor data integration');

grid on;
grid minor;

% Data
figure(3);
plot(t, ax, t, ay);
ylabel('Acceleration [cm/s^2]');
xlabel('Time [s]');
legend('ax', 'ay')
title('Accelerometer data');

grid on;
grid minor;

%% Define functions
function Y = h(X)
    x = X(1);
    y = X(2);
    Y = [(8.3741*x + 0.2395)./(x + 0.0123); ...
         (8.3558*y + 1.3344)./(y + 0.1294)];
end

function J = H(X)
    x = X(1);
    y = X(2);
    J = [8.3741./(x + 0.0123) - (8.3741*x + 0.2395)./(x + 0.0123).^2, 0, 0, 0;
         0, 8.3558./(y + 0.1294) - (8.3558*y + 1.3344)./(y + 0.1294).^2, 0, 0];
end
