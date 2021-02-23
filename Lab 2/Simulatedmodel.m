clc;
clear all;
% Code written by Christian Mele, TA for MTE 546 as aid to generate line
dt = 0.1;
t=0:dt:10;

x1= zeros(4,length(t)); %initializing an array of X values

x1(:,1) = [0,0,1,0]; %initializing the positions
y1= zeros(2, length(t)); %This will be the sensor reading portion


A =  [1 0 dt 0; 
      0 1 0 dt; 
      0 0 1 0; 
      0 0 0 1];

shakenoise = [0.2 0 0 0;
              0 0.2 0 0;
              0 0 0.2 0;
              0 0 0 0.2];

R = [0.21337 0; 0 0.022288];

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
    Csim1 = 100*[(8.3741*x1(1,k) + 0.2395)./(x1(1,k) + 0.0123); ...
                 (8.3558*x1(2,k) + 1.3344)./(x1(2,k) + 0.1294)];
             
             
        
    y1(:,k+1)=Csim1+v1(k); 

    
end


csv_export = [t;y1]';
writematrix(csv_export,'data/simulated_data.csv')



