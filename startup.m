% Get current directory
projectDir = pwd;

% Set data path
datPath = fullfile(projectDir, 'pharlap', 'dat');
setenv('DIR_MODELS_REF_DAT', datPath);

% Add paths
pharlap_root = fullfile(projectDir, 'pharlap');
addpath(genpath(pharlap_root));

% Prioritize mex folder
mexPath = fullfile(pharlap_root, 'mex');
if exist(mexPath, 'dir')
    rmpath(mexPath);
    addpath(mexPath, '-begin');
end

fprintf('PHaRLAP initialized for %s\n', computer);