close all; clear all;

%% Set up
dt = 0.005;
t = 0:dt:10;
N = length(t);

theta = zeros(1, N);

% Set up rotation
idx = t > 3 & t < 5;
Nturn = sum(idx);
theta(idx) = linspace(0, pi/2, Nturn);
theta(t >= 5) = pi/2;
omega = (theta(t == 4+dt) - theta(t == 4))/dt;

% Velocity noise covariance
stateNoise = 1e-4*eye(4);
% stateNoise = 10*1e-4*eye(4);

% Sensor noise covariance
senseNoise = [0.21337 0; ...
              0       0.022288];

% Simulated sensor model
h = @(x, y) [(8.3741*x + 0.2395)./(x + 0.0123); ...
             (8.3558*y + 1.3344)./(y + 0.1294)];

%% Start simulation
% Set up variables
X = zeros(4, N);
Y = zeros(2, N);

% Initialize
X0 = [0 0 3 0]';
X(:, 1) = X0;

% Calculate noise
randn('seed', 0);
w  = mvnrnd([0 0 0 0], stateNoise, N)';
v1 = mvnrnd([0 0], senseNoise, N)';

% Begin loop
X = zeros(4, N);
Y = zeros(2, N);
X(:, 1) = X0;

for i = 1:N - 1
    Xk = X(:, i);
    wk = w(:, i);
    v1k = v1(:, i);
    thetak = theta(i);
    
    % Calculate sensor response
    Yk = h(Xk(1), Xk(2)) + v1k;
    
    % Propagate state
    Vk = norm(Xk(3:4));      % Total velocity
    Xk(3) = Vk*cos(thetak);
    Xk(4) = Vk*sin(thetak);
    
    Xk1 = [Xk(1) + dt*Xk(3);
           Xk(2) + dt*Xk(4);
           Xk(3);
           Xk(4)];
    X(:, i+1) = Xk1;
end

for i = 1:N
    X(:, i) = X(:, i) + w(:, i);
end

%% Preprocessing...
x = X(1, :);
y = X(2, :);
u = X(3, :);
v = X(4, :);

%% Plot
figure(1);
plot(t, u, t, v);
yyaxis right;
plot(t, theta);