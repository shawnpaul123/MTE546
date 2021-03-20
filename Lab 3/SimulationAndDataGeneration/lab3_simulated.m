close all; clear all;

%% Instructions for use
% Data automatically generated and saved at respective folders
% for a 90 degree rotation
%% Set up
dt = 0.005;
t = 0:dt:10;

thetha_hist = t;
N = length(t);

% 'True' state vector
X = zeros(4, N);
rot_time = 3;

% Velocity noise covariance
stateNoise = 1e-4*eye(4);
% stateNoise = 10*1e-4*eye(4);

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
X0 = [0 0 3 0]';
% X0 = [0 0 0 1]';
% X0 = [0 0 0 0]';

% Calculate noise
randn('seed', 0);
w  = mvnrnd([0 0 0 0], stateNoise, N)';
v1 = mvnrnd([0 0], senseNoise, N)';

% Begin loop
X = zeros(4, N);
Y = zeros(2, N);
X(:, 1) = X0;
thetha = 0;
thetha_limit = pi/2;

delta_vel = abs(X0(4)-X0(3));

for i = 1:N - 1
    Xk = X(:, i);
    wk = w(:, i);
    v1k = v1(:, i);  
    
    % Calculate sensor response
    Yk = h(Xk(1), Xk(2)) + v1k;
    thetha_hist(:,i) = thetha;
    if i*dt > rot_time && thetha < thetha_limit
        delta_thetha = ang_vel(dt);
        thetha = thetha + delta_thetha;
        Xk(3) = delta_vel*cos(thetha) + delta_vel; 
        Xk(4) = delta_vel*sin(thetha) + delta_vel;         
    else    
    % Propagate state
        Xk1 = [Xk(1) + dt*Xk(3); ...
               Xk(2) + dt*Xk(4); ...
               Xk(3); ...
               Xk(4)] + wk;
       
    end
    
    
    % Calculate sensor response
    Yk1 = h(Xk1(1), Xk1(2)) + v1k;
    
    % Save state
    X(:, i+1) = Xk1;
    Y(:, i+1) = Yk1;
end
Y(:, end) = h(X(1, end), X(2, end)) + v1(:, end);

x = X(1, 1:end-1);
y = X(2, 1:end-1);
u = X(3, 1:end-1);
v = X(4, 1:end-1);
axSense = Y(1, 1:end-1);
aySense = Y(2, 1:end-1);
t = t(1,1:end-1);
thetha_hist = thetha_hist(1,1:end-1);

%% Plot simulated data
figure(1);
plot(t, axSense, t, aySense);
title('Sensor output');
legend('ax', 'ay');
xlabel('Time [s]');
ylabel('Acceleration [cm/s^2]');
saveas(figure(1),'Plots/Sensor_output.fig');

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
saveas(figure(2),'Plots/Ground_truth.fig');

figure(3);
plot(x, y);
xlabel('Position x [cm]');
ylabel('Position y [cm]');
title('Position');
saveas(figure(3),'Plots/Position.fig');

figure(4);
plot(t,thetha_hist);
xlabel('time(s)');
ylabel('thetha value(radians)');
title('Thetha History');
saveas(figure(4),'Plots/Thetha_History.fig');




%% Write data files
% Change this to change the file name
caseName = 'baseline';
M = [t; x; y; u; v]';
writematrix(M, ['Simulation/' caseName '-groundtruth.csv']);
M = [t; axSense; aySense]';
writematrix(M, ['Simulation/' caseName '-sensordata.csv']);
M = [t; thetha_hist]';
writematrix(M, ['Simulation/' caseName '-thetha_hist.csv']);



function av = ang_vel(dt)
    av = 0.65*dt;
end