% Script: run_metrics.m
% Purpose: Calculate validation metrics between reference and satellite datasets
% This script loads your data, calculates statistical metrics, and exports
% results to Excel and text files.
% Inputs:
%   REFERENCE DATASET: Matrix like (ERA5 or GLDAS)
%   SATELLITE DATASET: Matrix like (ASCAT or SMAP)
%
% Outputs:
%   - Statistical indices (R, BIAS, P-value, ubRMSE, RMSE) exported to Excel and text files
%
% Note: Use calculate_metrics function 

% Calculate metrics using calculate_metrics function
  results = calculate_metrics(ERA5_CA, ASCAT_CA);
    
% Convert results structure to table for export
  resultsTable = struct2table(results);
    
% Export to Excel format
  writetable(resultsTable, 'metrics_results.xlsx');
    
% Export to tab-delimited text format
  writetable(resultsTable, 'metrics_results.txt', 'Delimiter', 'tab');
