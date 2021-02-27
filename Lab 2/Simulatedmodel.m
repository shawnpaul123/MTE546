clc;
clear all;
% Code written by Christian Mele, TA for MTE 546 as aid to generate line
%edited by SP for better specification for the lab
scenario = input('which scenario do you want to test for?');
%scenario is 0,1,2,3,4, or 5
% 0 - no changes
% 1- different initial state
% 2 - different sensor noise
% 3 - different system noise
% 4 - different motion model
% 5 - stationary motion model

%refer lab notes for scenario meanings


dt = 0.1;
t=0:dt:10;

x1= zeros(4,length(t)); %initializing an array of X values

x1(:,1) = [0,0,1,0]; %initializing the positions
y1= zeros(2, length(t)); %This will be the sensor reading portion
  
if scenario == 2
    R = [0.5 0; 0 0.5];%initializing sensor values   
else
    R = [0.21337 0; 0 0.022288];%initializing sensor values     
end

if scenario == 3
    shakenoise = 0.5*eye(4);  
else
    shakenoise = 0.025*eye(4);     
end

%scenario 4 not modifying A matrix
if scenario == 5    
    
    A =  [1 0 0 0; 
          0 1 0 0; 
          0 0 1 0; 
          0 0 0 1];

elseif scenario == 4 
    
    A =  [1 0 5 0; 
          0 1 0 5; 
          0 0 1 0; 
          0 0 0 1];

      
else
    A =  [1 0 dt 0; 
          0 1 0 dt; 
          0 0 1 0; 
          0 0 0 1];
end


randn('seed',0); 
% R = mvnrnd(mu,Sigma,n) returns a matrix R of n random vectors 
% chosen from the same multivariate normal distribution, with 
% mean vector mu and covariance matrix Sigma.
w = mvnrnd([0;0;0;0],shakenoise,length(t))'; 
v1 = mvnrnd([0 0],R,length(t))'; 


for k=1:10/dt
    %% Note: If you want to change how this relationship works, or assume there is noise
    % in the two directions that differ, or change how the relationship
    % works, extrapolate from given below to alter and improve for your own
    % use
    x1(:,k+1)=A*x1(:,k)+w(:,k);
    
    % This is your simulated sensor
    Csim1 = [(8.3741*x1(1,k) + 0.2395)./(x1(1,k) + 0.0123); ...
             (8.3558*x1(2,k) + 1.3344)./(x1(2,k) + 0.1294)];
                
    y1(:,k+1)=Csim1+v1(k); 

    
end
% setup write locations

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
    

% Write simulated acceleration data
csv_export = [t;y1]';
writematrix(csv_export,filename); 

% Write ground truth data
csv_export = [t;x1]';
writematrix(csv_export,truefile);
