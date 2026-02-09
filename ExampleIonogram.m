%% example ionogram call

% Define input parameters for the ionogram generation
origin_lat = 0; % Example latitude
origin_lon = 0; % Example longitude
R12 = 100; % Median sunspot number
UT = [2000,09,27,12,00]; % Universal Time
azim = 30; % Azimuth angle
max_range = 1000; % Maximum range in kilometers
num_range = 10; % Number of range points
range_inc = 100; % Range increment in kilometers
start_height = 100; % Starting height in kilometers
height_inc = 10; % Height increment in kilometers
num_heights = 10; % Number of height points
kp = 5; % Kp index
doppler_flag = true; % Doppler effect flag
profile_type = 'iri'; % Profile type
[iono_pf_grid,iono_pf_grid_5,collision_freq,irreg,iono_te_grid] = ...
    gen_iono_grid_2d(origin_lat, origin_lon, R12, UT, azim, ...
		     max_range, num_range, range_inc, start_height, ...
		     height_inc, num_heights, kp, doppler_flag, ...
		     profile_type);

range_axis = (0:num_range-1) * range_inc;  % km
height_axis = (0:num_heights-1) * height_inc + start_height;  % km

