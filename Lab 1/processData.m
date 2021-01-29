clear all; close all; clc;

plotHist = false;
plotNoise = true;

dropDist = [5 10 15 20 25 30];
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
        
        if plotHist || plotNoise
            % Generate histogram of acceleration in that axis
            figs(j) = figure(j);
            hold on;
            
            if plotHist
                histfit(accelData);
                pd = fitdist(accelData, 'Normal');
                [h, p, stats] = chi2gof(accelData);
                disp(pd);
                title(['Acceleration histogram for ', dropDir(j), ...
                    '-axis, height of ', num2str(dropDist(i)), ' cm']);
                subtitle(['\mu = ', num2str(pd.mu), ...
                    ' m/s^2, \sigma = ', num2str(pd.sigma), ...
                    ' m/s^2, \sigma^2 = ', num2str(pd.sigma^2), ...
                    ' m^2/s^4, \chi^2 = ', num2str(stats.chi2stat)]);
                xlabel('Acceleration [m/s^2]');
                ylabel('Number of samples');
            elseif plotNoise
                noise = (accelData - accelMean)/accelMean;
                plot(timeSel - timeSel(1), noise);
                plot(timeSel(1:2:end) - timeSel(1), noise(1:2:end));
                plot(timeSel(1:10:end) - timeSel(1), noise(1:10:end));
                title(['Acceleration noise for ', dropDir(j), ...
                    '-axis, height of ', num2str(dropDist(i)), ' cm']);
                xlabel('Time [s]');
                ylabel('Normalized noise');
                legend('Original', '1/2 sampling rate', '1/10 sampling rate');
                grid on;
                grid minor;
                
                % Invert y-axis
                set(gca, 'YDir', 'reverse');
                
                % Output means
                disp([dropDir(j), '-axis, ', num2str(dropDist(i)), ' cm']);
                disp(['Mean accel: ', num2str(mean(accelData))]);
                disp(['RMS noise: ', num2str(rms(noise))]);
                disp(['Mean accel (0.5x rate): ', num2str(mean(accelData(1:2:end)))]);
                disp(['RMS noise (0.5x rate): ', num2str(rms(noise(1:2:end)))]);
                disp(['Mean accel (0.1x rate): ', num2str(mean(accelData(1:10:end)))]);
                disp(['RMS noise (0.1x rate): ', num2str(rms(noise(1:10:end)))]);
                disp(' ');
            end
        end
        
        % Save data
        accel(i, j) = accelMean;
    end
    if plotHist || plotNoise
        pause;
        close(figs(1));
        close(figs(2));
        close(figs(3));
    end
end

save('accel.mat', 'accel');