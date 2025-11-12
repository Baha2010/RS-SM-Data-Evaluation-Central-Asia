function allStats = calculate_metrics(Reference, Satellite)
%calculate_metrics: Compute validation metrics between reference and satellite data
% This function calculates statistical metrics (R, BIAS, P-value, 
% ubRMSE, RMSE) for each row of input matrices (SPATIAL LOCATION), COLUMS REPRESENT TIME SERIES

% Inputs:
%   Reference: Reference dataset matrix (e.g., ERA5, GLDAS)
%   Satellite: Satellite dataset matrix (e.g., ASCAT, SMAP)
%
% Outputs:
%   allStats - Structure array containing metrics for each row:
%     R 
%     Bias   
%     ubRMSE 
%     RMSE   
%     PValue 
%     N      
% Input validation: Ensure matrices have same dimensions
    if ~isequal(size(Reference), size(Satellite))
        error('Input matrices must have the same dimensions for valid comparison.');
    end
    
    % Get number of rows to process
    nRows = size(Reference, 1);
    
    % Preallocate structure array for storing results
    allStats = repmat(struct('R', NaN, 'Bias', NaN, 'ubRMSE', NaN, ...
                            'RMSE', NaN, 'PValue', NaN, 'N', 0), nRows, 1);
    
    % Main processing loop: Calculate metrics for each row
    for i = 1:nRows
        % Extract current row data from both matrices
        obs_row = Reference(i, :);
        sat_row = Satellite(i, :);
        
        % Convert to column vectors for consistent processing
        obs = obs_row(:);
        sat = sat_row(:);
        
        % Remove pairs with missing data (NaN values)
        valid = ~isnan(obs) & ~isnan(sat);
        obs = obs(valid);
        sat = sat(valid);
        
        % Check for sufficient data points after filtering
        if numel(obs) < 2
            % Insufficient data: assign NaN values
            allStats(i).R = NaN;
            allStats(i).Bias = NaN;
            allStats(i).ubRMSE = NaN;
            allStats(i).RMSE = NaN;
            allStats(i).PValue = NaN;
            allStats(i).N = 0;
            continue; % Skip to next row
        end
        
        % Core metric calculations (preserved from original code)
        
        % Sample size after quality control
        N = numel(obs);
        
        % Bias: Mean difference between satellite and reference
        bias = mean(sat - obs);
        
        % Root Mean Square Error: Overall error magnitude
        rmse = sqrt(mean((sat - obs).^2));
        
        % Unbiased RMSE: Error after removing mean bias
        ubrmse = sqrt(mean(((sat - mean(sat)) - (obs - mean(obs))).^2));
        
        % Correlation analysis
        [R, p] = corr(obs, sat, 'Type', 'Pearson');
        
        % Handle potential NaN p-values
        if isempty(p) || isnan(p)
            p = NaN;
        end
        
        % Store calculated metrics for current row
        allStats(i).R = R;
        allStats(i).Bias = bias;
        allStats(i).ubRMSE = ubrmse;
        allStats(i).RMSE = rmse;
        allStats(i).PValue = p;
        allStats(i).N = N;
    end
end