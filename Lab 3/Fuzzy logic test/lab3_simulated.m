close all; clear all;
%Updates:
% qs posed answered and the 
% 90 degree rotation can be seen


% Case names: 
%each trajectory has a set of rotations n times
%   TRAJECTORY 1: TBD
%   TRAJECTORY 2: TBD
%   TRAJECTORY 3: TBD

%% Set up
dt = 0.005;
t = 0:dt:2;
N = length(t);
%rotate when i = a certain iteration number
t_rot = 200;
% 'True' state vector
X = zeros(4, N);
% Velocity noise covariance
stateNoise = 1e-4*eye(4);
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
%X state vector in terms of x,y,u,v
%need velocity profile to go from u,v [1,0]->[0,1] at an
%angular vel equal to lab 1
%X0 = [0 0 1 0]';
X0 = [0 0 16.8456 1.4274]';
% Calculate noise
randn('seed', 0);
w  = mvnrnd([0 0 0 0], stateNoise, N)';
v1 = mvnrnd([0 0], senseNoise, N)';

% Begin loop
X = zeros(4, N);
Y = zeros(2, N);
X(:, 1) = X0;
start_rot = false;
vel_angular = [0 0]';
thetha_limit = pi/2;
thetha = 0;
rad = 1;

for i = 1:N - 1
  
    Xk = X(:, i);
    wk = w(:, i);
    v1k = v1(:, i);
    
    % Calculate sensor response
    % I don't see where else it is calculated
    Yk = h(Xk(1), Xk(2)) + v1k;
    
    if t_rot == i 
        start_rot = true;
        thetha = 0;
        disp('start time');
        disp(t(:,i));
    end
    %start rotation
    
    %stop rotation    
    if thetha > thetha_limit
            start_rot = false;             
            
    end
    
    %change velocity values to as needed
    if start_rot == true
        
        thetha = thetha_change(rad,dt,t(:,i),thetha);
        vel_angular = vel_calc(t(:,i),rad,thetha);     
        Xk(3) = vel_angular(1,1);
        Xk(4) = vel_angular(2,1);       
        
    end 
    
    % Propagate state
    % JIN: Not sure if this will play well with the rotation code while start_rot == true
    % Shawn: the adding of noise or state propogation
    Xk1 = [Xk(1) + dt*Xk(3); ...
           Xk(2) + dt*Xk(4); ...
           Xk(3); ...
           Xk(4)] + wk;
    
    % Calculate sensor response
    % SP: I dont see where else it is being calculated
    Yk1 = h(Xk1(1), Xk1(2)) + v1k;
    
    % Save state
    X(:, i+1) = Xk1;
    Y(:, i+1) = Yk1;
end
% SP: Do you mean the below line can be removed?
Y(:, end) = h(X(1, end), X(2, end)) + v1(:, end);

x = X(1, :);
y = X(2, :);
u = X(3, :);
v = X(4, :);
axSense = Y(1, :);
aySense = Y(2, :);

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


figure(3);
plot(x,y);
title('Position');
xlabel('Position x [cm]');
ylabel('Position y [cm]');
legend('point');

%% Write data files
% Change this to change the file name
caseName = 'baseline';

M = [t; x; y; u; v]';
writematrix(M, ['Simulation/' caseName '-groundtruth.csv']);
M = [t; axSense; aySense]';
writematrix(M, ['Simulation/' caseName '-sensordata.csv']);


function thetha = thetha_change(radius,dt,t,thetha) 
    thetha = thetha + dt*ang_velocity(t); 
    r = rad_mat(radius,thetha);
      
    v =  ang_velocity(t)*r;    
end

%returns angular vel
%SP: Gyro model from lab 1
function w = ang_velocity(t)
    w = -0.001*(t^3) + 0.074*(t^2) -1.508*t + 18.341;
end

%returns radius in i and j
function r_mat = rad_mat(r,thetha)
    r_mat = r*[cos(thetha) sin(thetha)]';
end

%SP:Radius is basically from center of rotation to point of velocity
function velocity = vel_calc(t,r,thetha)
    radius = rad_mat(r,thetha);
    velocity = ang_velocity(t)*radius; 
end
