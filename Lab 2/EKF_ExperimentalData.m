close all; clear all;

%% Read in data
filename = 'Data/slide -y.csv';
data = readmatrix(filename);

% Crop out beginning
range = [2.7 5.6]
idx = (data(:, 1) > range(1)) & (data(:, 1) < range(2));
data = data(idx, :);

% Convert to cm/s^2
data(:, 2:end) = 100*data(:, 2:end);

t = data(:, 1);
ax = data(:, 2);
ay = data(:, 3);

N = length(t);

%% Setup
plotK = false;
plotP = true;

% Define models
A = @(T) [1 0 T 0; ...
          0 1 0 T; ...
          0 0 1 0; ...
          0 0 0 1];

Q = 1e-4*eye(4);
R = [0.21337 0; 0 0.022288];

% Initial conditions
X0 = [0 0 0 -1]';
Pk = eye(4);

% Set up variables
X = zeros(4, N);
X(:, 1) = X0;
Khist = zeros([N 8]);
Phist = zeros([N 16]);

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
    Khist(i, :) = reshape(K, 1, []);
    Phist(i, :) = reshape(Pk, 1, []);
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
sgtitle('EKF comparison with trapezoidal integration');

subplot(2, 2, 1);
plot(t, x, t, xint, '--');
title('x');
xlabel('Time [s]');
ylabel('x-position [cm]');
legend('EKF prediction', 'Pure integration');
grid on;
grid minor;

subplot(2, 2, 2);
plot(t, y, t, yint, '--');
title('y');
xlabel('Time [s]');
ylabel('y-position [cm]');
legend('EKF prediction', 'Pure integration');
grid on;
grid minor;

subplot(2, 2, 3);
plot(t, u, t, uint, '--');
title('u');
xlabel('Time [s]');
ylabel('x-velocity [cm]');
legend('EKF prediction', 'Pure integration');
grid on;
grid minor;

subplot(2, 2, 4);
plot(t, v, t, vint, '--');
title('v');
xlabel('Time [s]');
ylabel('y-velocity [cm]');
legend('EKF prediction', 'Pure integration');
grid on;
grid minor;

% Raw experimental data
figure(2);
plot(t, ax, t, ay);
title('Accelerometer data');
xlabel('Time [s]');
ylabel('Acceleration [cm/s^2]');
legend('a_x', 'a_y')
grid on;
grid minor;

% Kalman gains
if plotK
    figure(2);
    plot(t, Khist);
    title('Kalman gains');
    xlabel('Time [s]');
    ylabel('Gain');
    legend('11', '21', '31', '41', '12', '22', '32', '42');
    grid on;
    grid minor;
end

% State uncertainty
if plotP
    % UT means upper-triangular: Only plot the history of the upper-
    % triangular elements of P
    labels = [11 12 13 14; 21 22 23 24; 31 32 33 34; 41 42 43 44];
    maskUT = logical([1  1  1  1 ; 0  1  1  1 ; 0  0  1  1 ; 0  0  0  1 ]);
    PhistUT = Phist(:, maskUT);
    labelsUT = labels(maskUT);
    
    figure(3);
    plot(t, Phist);
    title('State uncertainty (P matrix)');
    xlabel('Time [s]');
    ylabel('Covariance');
    legend(num2str(labelsUT));
    grid on;
    grid minor;
end

%% Diagnostics
ex = rms(x' - xint);
ey = rms(y' - yint);
eu = rms(u' - uint);
ev = rms(v' - vint);
em = mean([ex ey eu ev]);
disp(['Err: ' num2str(ex) ' ' num2str(ey) ' ' ...
    num2str(eu) ' ' num2str(ev) ...
    ' M = ' num2str(em)]);

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
