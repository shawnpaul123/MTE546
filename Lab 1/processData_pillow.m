clear all; close all; clc;

plotHist = false;
plotNoise = true;

dropDist = [30];
dropDir  = ['x' 'y' 'z'];

Ndist = length(dropDist);
Ndir = length(dropDir);

% Preallocate measured and predicted matrices
accel = zeros(Ndist, Ndir);

% Crop tolerances
lower = 9;
upper = 15;
for i = 1:Ndist
    for j = 1:Ndir
        h = dropDist(i);
        
%         fname = strcat(string(h), 'cm-', dropDir(j), '-pillow.csv');
%         M = readmatrix( ...
%             strcat('Data/Accelerometer_data/pillow_drop/', fname));
        fname = strcat(string(h), 'cm-', dropDir(j), '.csv');
        M = readmatrix( ...
            strcat('Data/Accelerometer_data/3axis_drop/', fname));
        t = M(:, 1);
        aT = M(:, end);
        N = length(t);
        
        % Begin cropping
        select = false(1, N);
        for k = 1:N
            if aT(k) > lower
                if aT(k) > upper
                    break;
                end
                select(k) = true;
            end
        end
        
        % Get mean acceleration in the corresponding axis
        timeSel = t(select);
        accelData = M(:, j+1);
        accelData = accelData(select);
        
        accelMean = mean(accelData);
        err = (accelMean + 9.81)/9.81;
        disp([dropDir(j), '-axis']);
        disp(['Mean accel: ', num2str(accelMean)]);
        disp(['Error: ', num2str(err*100), ' %']);
        
        % Save data
        accel(i, j) = accelMean;
    end
end

save('accel_pillow.mat', 'accel');