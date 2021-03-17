close all; clear all;

%% Test
% Define fuzzy function parameters
thetaBars = [-pi/2, 0, pi/2, pi, 3*pi/2, 2*pi];
delta = pi/3;

% Define function array for membership functions
fxnArr = @(theta) [mu(thetaBars(1), delta, theta); ...
    mu(thetaBars(2), delta, theta); ...
    mu(thetaBars(3), delta, theta); ...
    mu(thetaBars(4), delta, theta); ...
    mu(thetaBars(5), delta, theta); ...
    mu(thetaBars(6), delta, theta)];
defuzz = @(theta) defuzzify(fxnArr(theta), thetaBars, theta);

% Plot membership functions
theta = -pi:0.01:3*pi;
N = length(theta);
mus = zeros(6, N);
thetaDF = zeros(1, N);

for i = 1:N
    thetai = theta(i);
    m = fxnArr(thetai);
    mus(:, i) = m;
    
    thetaDF(i) = defuzz(thetai);
end

%% Plot results
plot(theta, mus);
ylabel('Membership');
yyaxis right;
plot(theta, thetaDF, theta, theta);
xlabel('Input angle [rad]');
ylabel('Output angle [rad]');
title('Membership functions and fuzzy function response');
legend('-\pi/2', '0', '\pi/2', '\pi', '3\pi/2', '2\pi', ...
    'Defuzzified output angle', 'Input angle');
grid minor;

%% Define fuzzy algorithms
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

function centroid = defuzzify(muArr, thetaBars, theta)
    if sum(muArr) == 0
        centroid = theta;
    else
        centroid = sum(thetaBars .* muArr')/sum(muArr);
    end
end