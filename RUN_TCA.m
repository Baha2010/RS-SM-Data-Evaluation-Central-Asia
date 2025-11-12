% Script: run_TCA.m
% Purpose: Perform Triple Collocation analysis on three soil moisture datasets
% 
% Inputs: Three soil moisture independent datasets (rows = locations, columns = time)

% Outputs: Triple Collocation metrics exported to Excel file as follows:
%   * Error variances, SNR in dB, fMSE 
%   * Correlation coefficients and p-values between dataset pairs
%   * Valid observation counts for each location

% Execute Triple Collocation analysis using TCA function
results = TCA(SMAP_AVERAGE, ASCAT_CA, ERA5_CA);

% Convert results structure to individual tables with descriptive headers
% NOTE: Update variable names below to match your input dataset order

% Error variance table - represents random error in each dataset
ErrorVarTable = array2table(results.ErrorVar, ...
    'VariableNames', {'ErrorVar_SMAP', 'ErrorVar_ASCAT', 'ErrorVar_ERA5'});

% Signal-to-Noise Ratio in decibels - higher values indicate better quality
SNRdBTable = array2table(results.SNRdB, ...
    'VariableNames', {'SNRdB_SMAP', 'SNRdB_ASCAT', 'SNRdB_ERA5'});

% Fractional Mean Square Error - proportion of error variance to total variance
fMSETable = array2table(results.fMSE, ...
    'VariableNames', {'fMSE_SMAP', 'fMSE_ASCAT', 'fMSE_ERA5'});

% Correlation matrix between dataset pairs with p-values
% R12, R13, R23: Pearson correlation coefficients between dataset pairs 1-2, 1-3, 2-3
% P12, P13, P23: Corresponding p-values for correlation significance tests
CorrMatrixTable = array2table(results.CorrMatrix, ...
    'VariableNames', {'Corr_R12', 'Corr_R13', 'Corr_R23', ...
                      'Corr_P12', 'Corr_P13', 'Corr_P23'});

% Number of valid observations (common time steps without missing data)
ValidObsTable = array2table(results.ValidObs, ...
    'VariableNames', {'ValidObs'});

% Combine all individual tables into one comprehensive results table
T = [ErrorVarTable, SNRdBTable, fMSETable, CorrMatrixTable, ValidObsTable];

% Data formatting for Excel export: Convert NaN values to 'NaN' strings
% This ensures NaN values are visible in Excel rather than appearing as empty cells
C = table2cell(T);
C(cellfun(@isnan, C)) = {'NaN'};
T = cell2table(C, 'VariableNames', T.Properties.VariableNames);

% Export complete results to Excel file
writetable(T, 'TripleCollocation_Results.xlsx', 'WriteVariableNames', true);

% Display completion message with summary statistics
disp(['Triple Collocation analysis completed. Exported ', num2str(height(T)), ' rows to Excel.']);