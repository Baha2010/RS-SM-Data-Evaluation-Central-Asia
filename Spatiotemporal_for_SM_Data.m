% Hovm?ller Diagram Generation for Soil Moisture Data

% INPUT DESCRIPTION:
% 2D matrix of soil moisture data (e.g ASCAT_CA) with dimensions:
%  - Rows: 26,741 spatial grid points  (121 lats °¡ 221 lons)
%  - Columns: Daily time steps (Jan 2016 - Dec 2019)
%  - Data: Soil moisture (m?/m?), NaN for missing data
%  - Spatial range: 60.875°„N to 30.875°„N latitude

% Reshape 2D soil moisture data to 3D spatial grid
[~, num_time_steps] = size(ASCAT_CA);
SM_grid = reshape(ASCAT_CA, [121, 221, num_time_steps]);

% Compute longitudinal average to create latitude-time matrix
Hov_SM = squeeze(nanmean(SM_grid, 2));

% Define original latitude coordinates (60.875°„N to 30.875°„N, 0.25°„ resolution)
original_lat = 60.875:-0.25:30.875; % 121 points descending north to south

% Identify latitude indices for analysis region (34.875°„N to 55.125°„N)
idx_start = find(original_lat <= 55.125, 1, 'first'); % North boundary index
idx_end = find(original_lat >= 34.875, 1, 'last');    % South boundary index

% Extract latitude subset and corresponding data
Hov_SM = Hov_SM(idx_start:idx_end, :);
latitude_subset = original_lat(idx_start:idx_end);

% Reorient data for proper visualization (south at bottom, north at top)
Hov_SM = flipud(Hov_SM);                    % Flip matrix vertically
latitude_subset = fliplr(latitude_subset);  % Reverse latitude order

% Create daily time vector for analysis period
startDate = datetime(2016, 1, 1);
endDate = datetime(2019, 12, 31);
time = startDate:endDate;
time_num = datenum(time); % Convert to numeric format for plotting

% Initialize figure window
figure('Units', 'normalized', 'Position', [0.1 0.1 0.8 0.6], 'Color', 'white');

% Generate Hovm?ller diagram using imagesc
imagesc(time_num, latitude_subset, Hov_SM);
axis xy; % Set coordinate origin to bottom-left (south-west)
colormap(jet); % Apply jet color scheme

% Configure colorbar placement and properties
cb = colorbar('eastoutside'); % Position colorbar to the right
caxis([0 0.6]); % Set data range for color mapping

% Customize time axis ticks and labels - YEAR LABELS AT THE END
years = 2016:2019;
xtick_dates = datetime(years, 12, 31); % Year-end reference points
ax = gca;
ax.XTick = datenum(xtick_dates); % Set tick positions
ax.XTickLabel = num2str(years'); % Label with year values
ax.XLim = datenum([datetime(2016,1,1), datetime(2019,12,31)]); % Set time range
ax.FontSize = 22; % Increase font size for readability
set(gca, 'TickDir', 'out'); % Orient ticks outward

% Configure latitude axis
ylim([35 55]); % Set latitude bounds
set(gca, 'YTick', 35:5:55, 'YTickLabel', arrayfun(@(x) sprintf('%.0f°„N', x), 35:5:55, 'UniformOutput', false));

% Add grid lines for reference
grid on;

% Export figure as high-resolution TIFF
print('hovmoller_diagram', '-dtiff', '-r1000');

% Close figure to conserve memory
close(gcf);