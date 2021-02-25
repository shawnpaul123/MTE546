close all; clear all;
%reused EKF code 
%to accompany for simulated data
%choose scenario
scenario = input('which scenario do you want to test for?');
%scenario is 0,1,2,3,4, or 5
% 0 - no changes
% 1- different initial state
% 2 - different sensor noise
% 3 - different system noise
% 4 - different motion model
% 5 - stationary motion model


%% Read in data
if scenario == 0 || scenario  == 1
    filename = 'data/simulated_data.csv'; 
    truefile = 'data/groundtruth_data.csv';
else
    str = num2str(scenario);
    fn = append(str,'_simulated_data.csv');
    filename = append('data/',fn);
    tn = append(str,'_groundtruth.csv');
    truefile = append('data/',tn);
    
end
    

%need to have data in format of time,ax,ay
data = readmatrix(filename);


t = data(:, 1);
ax = data(:, 2);
ay = data(:, 3);

% Read in ground truth data

data = readmatrix(truefile);

xtrue = data(:, 2);
ytrue = data(:, 3);
utrue = data(:, 4);
vtrue = data(:, 5);

N = length(t);

%% Setup
plotK = false;





% Define models
A = @(T) [1 0 T 0; ...
          0 1 0 T; ...
          0 0 1 0; ...
          0 0 0 1];




Q = 0.025*eye(4);
R = [0.21337 0; 0 0.022288];%initializing sensor values
     


% Initial conditions
if scenario == 1
    X0 = [10 10 10 10]'; %initializing the positions
    
    
else
     X0 = [0 0 1 0]'; %initializing the positions
     
end
    
Pk = eye(4);

% Set up variables
X = zeros(4, N);
X(:, 1) = X0;
Khist = zeros([N 8]);

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
sgtitle('EKF comparison with ground truth');

subplot(2,2,1);
plot(t, x, t, xtrue, '--');
title('x');
xlabel('Time [s]');
ylabel('x-position [cm]');
legend('EKF prediction', 'Ground truth');
grid on;
grid minor;

subplot(2,2,2);
plot(t, y, t, ytrue, '--');
title('y');
xlabel('Time [s]');
ylabel('y-position [cm]');
legend('EKF prediction', 'Ground truth');
grid on;
grid minor;

subplot(2,2,3);
plot(t, u, t, utrue, '--');
title('u');
xlabel('Time [s]');
ylabel('x-velocity [cm]');
legend('EKF prediction', 'Ground truth');
grid on;
grid minor;

subplot(2,2,4);
plot(t, v, t, vtrue, '--');
title('v');
xlabel('Time [s]');
ylabel('y-velocity [cm]');
legend('EKF prediction', 'Ground truth');
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

%% Diagnostics
ex = rms(x' - xtrue);
ey = rms(y' - ytrue);
eu = rms(u' - utrue);
ev = rms(v' - vtrue);
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
