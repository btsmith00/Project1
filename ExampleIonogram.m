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
origin_lat = Chesapeake_lat; % Undisclosed latitude
origin_lon = Chesapeake_lon; % Undisclosed longitude
R12 = 121; % Median sunspot number as defined by the monks
UT = [2000,09,27,12,00]; % My birthday
azim = azimuth(origin_lat,origin_lon,AU_lat,AU_lon); % PYTHAGORAS
target_dist_deg = distance(origin_lat, origin_lon, AU_lat, AU_lon);
target_dist_km = deg2km(target_dist_deg);

num_range = round(target_dist_km)+100; % But actually gonna just walk 1500 km
max_range = num_range-1; % I Would walk 500 miles! (1600 km)
range_inc = 1; % I have a long gait (1 km)
start_height = 60; % talking about the IgNoROspHErE
height_inc = 1; % got hops (1 km)
num_heights = 400; % We are hopping 30 times
kp = 5; % Katy Perry Index
doppler_flag = true; % Meteorologist Ben Smith is the worse Ben Smith
profile_type = 'iri'; % IRL IRI
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

freq = [.001,.01,.1,1,5];
elevs = [90, 90, 90, 90, 90];
nhops = 1;
bearing = azim;
tol = [];
tol(1) = 1e-7;
tol(2) = 0.025;
tol(3) = 25;
irregs_flag = 1; % irreg off


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

%%
nhops = 1;
bearing = azim;
tol = [];
tol(1) = 1e-7;
tol(2) = 0.025;
tol(3) = 25;
irregs_flag = 1; % (irreg =1 is on)



freqs = 1:.1:12;

goodRayData = repmat(struct('label', [], 'virtualHeight', [],...
    'groundRange', [],'val',[],'lat',[],'lon',[],'path_length',[],...
    'elevation',[],'group_range',[],'apogee',[]),1, length(freqs));
% lets find all the rays where it lands at auburn
% rays a good guy
% hits the bottle a little too hard sometimes
for ii = 1:length(freqs)
    elevs = .5:.01:60; % make a bunch of elves
    % elevs = elevs.';
    freq = ones(size(elevs))*freqs(ii); % make a bunch of freqs

    [ray_data, ray_path_data, ray_state_vec] = ...
      raytrace_2d(origin_lat, origin_lon, elevs, bearing, freq, nhops, ...
             tol, irregs_flag, iono_en_grid, iono_en_grid_5, ...
            collision_freq, start_height, height_inc, range_inc, irreg);

    ray_data = ray_data([ray_data.ray_label]==1);
    if isempty(ray_data)
        goodRayData(ii).label = NaN;
        goodRayData(ii).virtualHeight = NaN;
        goodRayData(ii).groundRange = NaN;
        goodRayData(ii).val = NaN;
        goodRayData(ii).lat = NaN;
        goodRayData(ii).lon = NaN;
        goodRayData(ii).path_length = NaN;
        goodRayData(ii).elevation = NaN;
        
        fprintf('Freq %4.1f MHz: \n', ...
            freq(1));
        continue;
    end

    [val_goodray,idx_goodray] = min(abs(deg2km(distance([ray_data.lat], [ray_data.lon], AU_lat, AU_lon))));
    
    % Store the results for the good rays
    goodRayData(ii).label = ray_data(idx_goodray).ray_label;
    goodRayData(ii).virtualHeight = ray_data(idx_goodray).virtual_height;
    goodRayData(ii).groundRange = ray_data(idx_goodray).ground_range;
    goodRayData(ii).val = val_goodray;
    goodRayData(ii).lat = ray_data(idx_goodray).lat;
    goodRayData(ii).lon = ray_data(idx_goodray).lon;
    goodRayData(ii).path_length = ray_data(idx_goodray).geometric_path_length;
    goodRayData(ii).elevation = elevs(idx_goodray);
    goodRayData(ii).group_range= ray_data(idx_goodray).group_range;
    goodRayData(ii).apogee = ray_data(idx_goodray).apogee;


end

%%
% make the virtual reflection height
reflection_heights = ... % PYTHAGORAS
sqrt(([goodRayData.path_length]./2).^2-(target_dist_km./2).^2);
figure;
scatter(freqs,reflection_heights);
hold on;
scatter(freqs,[goodRayData.virtualHeight])
grid on
legend('My Height','Pharlap Height')
title('Oblique Ionogram')
xlabel('Freq (MHz)')
ylabel('Virtual Reflection Height (km)')
