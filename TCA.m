function [results] = TCA(SM1, SM2, SM3)
%TCA: Triple Collocation analysis for three soil moisture datasets
%
% Description: 
%   This function implements the Triple Collocation method to estimate random
%   errors, signal-to-noise ratios,fMSE,  and other quality metrics for three
%   independent soil moisture datasets.
%
% Inputs: Three soil moisture independent datasets (SM1, SM2, SM3)(rows = locations, columns = time)

% Outputs:
%   results - Structure containing:
%     ErrorVar   : Error variance for each dataset 
%     SNRdB      : Signal-to-Noise Ratio in decibels  
%     fMSE       : Fractional Mean Square Error 
%     ValidObs   : Number of valid observations per location 
%     CorrMatrix : Correlation coefficients and p-values 

    %% Data Preparation & Sanitization
    % Combine three 2D datasets into single 3D matrix for efficient processing
    % Dimensions: [locations ¡Á time ¡Á datasets]
    data = cat(3, SM1, SM2, SM3);
    [nLoc, nTime, nDS] = size(data);

    %% Preallocate Results Structure
    % Initialize all output arrays with NaN values to handle missing results
    results = struct(...
        'ErrorVar', nan(nLoc, 3), ...      % Error variances for 3 datasets
        'SNRdB', nan(nLoc, 3), ...         % SNR in decibels
        'fMSE', nan(nLoc, 3), ...          % Fractional MSE
        'ValidObs', nan(nLoc, 1), ...      % Valid observation counts
        'CorrMatrix', nan(nLoc, 6));       % Correlations: [R12, R13, R23, P12, P13, P23]

    %% Main Processing Loop - Analyze Each Location Independently
    for i = 1:nLoc
        % Extract time series for current location across all three datasets
        Q = squeeze(data(i, :, :));  % Dimensions: [time ¡Á datasets]
        
        % Identify time steps with valid data in all three datasets
        validIdx = all(~isnan(Q), 2);
        Q_valid = Q(validIdx, :);
        
        % Skip locations with insufficient data (minimum 100 common observations)
        if size(Q_valid, 1) < 100
            continue; 
        end
        
        % Store number of valid observations for current location
        results.ValidObs(i) = size(Q_valid, 1);
        
        %% Covariance Matrix Calculation
        % Compute covariance matrix between the three datasets
        % C(1,1), C(2,2), C(3,3) are variances of each dataset
        % C(1,2), C(1,3), C(2,3) are covariances between dataset pairs
        C = cov(Q_valid);
        
        %% Triple Collocation Core Calculations
        % Extract variances for each dataset
        varX = C(1, 1);  % Variance of first dataset (SM1)
        varY = C(2, 2);  % Variance of second dataset (SM2)
        varZ = C(3, 3);  % Variance of third dataset (SM3)
        
        % Calculate error variances using Triple Collocation equations
        ErrorVar = zeros(1, 3);
        ErrorVar(1) = varX - (C(1, 2) * C(1, 3)) / C(2, 3);  % Error variance for SM1
        ErrorVar(2) = varY - (C(1, 2) * C(2, 3)) / C(1, 3);  % Error variance for SM2
        ErrorVar(3) = varZ - (C(1, 3) * C(2, 3)) / C(1, 2);  % Error variance for SM3
                
        %% Signal-to-Noise Ratio Calculation
        SNR = zeros(1, 3);
        % Calculate linear SNR using covariance relationships
        SNR(1) = (C(1, 2) * C(1, 3)) / (C(2, 3) * ErrorVar(1));  % SNR for SM1
        SNR(2) = (C(1, 2) * C(2, 3)) / (C(1, 3) * ErrorVar(2));  % SNR for SM2
        SNR(3) = (C(1, 3) * C(2, 3)) / (C(1, 2) * ErrorVar(3));  % SNR for SM3
                
        % Convert linear SNR to decibels (dB) for better interpretability
        SNRdB = 10 * log10(SNR);
        
        %% Fractional Mean Square Error Calculation
        fMSE = 1 ./ (1 + SNR);
        
        %% Store Calculated Metrics for Current Location
        results.ErrorVar(i, :) = ErrorVar;
        results.SNRdB(i, :) = SNRdB;
        results.fMSE(i, :) = fMSE;
        
        %% Pairwise Correlation Analysis
        % Calculate correlation coefficients and p-values between dataset pairs
        try
            [R1, P1] = corr(Q_valid(:, 1), Q_valid(:, 2));  % SM1 vs SM2
            [R2, P2] = corr(Q_valid(:, 1), Q_valid(:, 3));  % SM1 vs SM3
            [R3, P3] = corr(Q_valid(:, 2), Q_valid(:, 3));  % SM2 vs SM3
            results.CorrMatrix(i, :) = [R1, R2, R3, P1, P2, P3];
        catch
            % If correlation calculation fails, assign NaN values
            results.CorrMatrix(i, :) = nan(1, 6);
        end
    end
end