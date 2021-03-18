
close all; clear all;

% thetha returns an array
% instead of a value, am
% curious if this a matlab quirk
% thetha =
% 
%    -1.0103
%     8.3924

v = [0 0]';
thetha = 0;
v,thetha = ang_rot(1,0.1,pi/2,0);

function [v,thetha] = ang_rot(t,dt,thetha_limit,thetha)
    radius = 0.5;%assume half of phone
   
    thetha = thetha + dt*ang_velocity(t); 
    disp('thetha');
    disp(thetha);
    r = rad_mat(radius,thetha);
    disp('ang-velocity');
    disp(ang_velocity(t));    
    v =  ang_velocity(t)*r;
    disp('v--');
    disp(v);
   
end

%returns angular vel
function w = ang_velocity(t)
    w = -0.001*t^3 + 0.074*t^2 -1.508*t + 18.341;
end

%returns radius in i and j
function r_mat = rad_mat(r,thetha)
    r_mat = r*[cos(thetha) sin(thetha)]';
end


