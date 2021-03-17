clear all; close all;

%% Test
thetaIn = -pi:0.01:3*pi;
N = length(thetaIn);
thetaOut = zeros(size(thetaIn));

for i = 1:N
    % Shawn this is the part you need to implement, along with tweaking
    %   the delta parameter on line 30.
    % Only input scalars to the function because making it work
    %   with vectors too is a pain.
    thetaOut(i) = fuzzyThatShit(thetaIn(i));
end

%% Plot results
plot(thetaIn, thetaOut, thetaIn, thetaIn, '--');
xlabel('Input angle [rad]');
ylabel('Output angle [rad]');
title('Fuzzy function response');
legend('Output angle', 'Input angle');
grid minor;

%% Define function
thetaBars = [-pi/2, 0, pi/2, pi, 3*pi/2, 2*pi];
delta = pi/3;
function outputAngle = fuzzyThatShit(inputAngle)
    % Define fuzzy function parameters
    thetaBars = [-pi/2, 0, pi/2, pi, 3*pi/2, 2*pi];
    delta = pi/3;
    
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