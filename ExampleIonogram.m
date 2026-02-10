%% example ionogram call


% Chesapeake 36.76960421389881, -76.28931792931039
% Corpus Christi 27.7993048824626, -97.39248755035703
% Auburn 32.606984845117644, -85.4850902630896

AU_lat = 32.606984845117644;
AU_lon = -85.4850902630896;

Chesapeake_lat = 36.76960421389881;
Chesapeake_lon = -76.28931792931039;

Corpus_lat = 27.7993048824626;
Corpus_lon = -97.39248755035703;

% Define input parameters for the ionogram generation
origin_lat = Chesapeake_lat; % Example latitude
origin_lon = Chesapeake_lon; % Example longitude
R12 = 121; % Median sunspot number as defined by the monks
UT = [2000,09,27,12,00]; % My birthday
azim = azimuth(origin_lat,origin_lon,AU_lat,AU_lon); % Azimuth angle
max_range = 1600; % Maximum range in kilometers > than Au to both locations
num_range = 1500; % Number of range points
range_inc = 1; % Range increment in kilometers
start_height = 80; % Starting height in kilometers
height_inc = 10; % Height increment in kilometers
num_heights = 30; % Number of height points
kp = 5; % Kp index
doppler_flag = true; % Doppler effect flag
profile_type = 'iri'; % Profile type
[iono_pf_grid,iono_pf_grid_5,collision_freq,irreg,iono_te_grid] = ...
    gen_iono_grid_2d(origin_lat, origin_lon, R12, UT, azim, ...
		     max_range, num_range, range_inc, start_height, ...
		     height_inc, num_heights, kp, doppler_flag, ...
		     profile_type);

pfsq_conv = 80.6163849431291e-12; % conversion factor to electron density

% make into electrons/cm^3
iono_en_grid = iono_pf_grid.^2/(pfsq_conv*1e6);
iono_en_grid_5 = iono_pf_grid_5.^2/(pfsq_conv*1e6);

%%


elevs = [90, 90, 90, 90, 90];
nhops = 1;
bearing = azim;
tol = [];
tol(1) = 1e-7;
tol(2) = 0.025;
tol(3) = 25;
irregs_flag = 1; % irreg off

freqs = 1:.1:10;

[ray_data, ray_path_data, ray_state_vec] = ...
      raytrace_2d(origin_lat, origin_lon, elevs, bearing, freq, nhops, ...
             tol, irregs_flag, iono_en_grid, iono_en_grid_5, ...
            collision_freq, start_height, height_inc, range_inc, irreg);


for i = 1:length(freq)
    fprintf('Freq %4.1f MHz: label=%2d, virt_h=%6.1f km, range=%6.1f km\n', ...
            freq(i), ray_data(i).ray_label, ...
            ray_data(i).virtual_height, ray_data(i).ground_range);
end

%%
figure;
plot(freq,[ray_data.virtual_height],"o")
