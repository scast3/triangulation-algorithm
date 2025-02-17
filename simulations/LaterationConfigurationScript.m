function LaterationConfigurationScript()
% LATERATIONCONFIGURATIONSCRIPT
%
% A single script to run both "Configuration 1" (Trilateration) 
% and "Configuration 2" (Multilateration) for four different scenarios,
% each with multiple target location options, plus an error ratio 
% and number of Monte Carlo runs for noise-based simulations.
%
% SCENARIO OUTLINE:
%   1) Scenario 1:
%       - Configuration 1 antenna positions: A1 [0 1], A2 [6 1], A3 [3 6]
%       - Configuration 2 RFID positions: 
%           [0 0], [0 3], [0 6], [3 0], [3 6], [6 0], [6 3], [6 6]
%   2) Scenario 2:
%       - Config 1: A1 [0 0], A2 [6 0], A3 [6 6]
%       - Config 2: 
%           [0 0], [0 3], [0 6], [3 0], [3 6], [6 0], [6 3], [6 6]
%   3) Scenario 3:
%       - Config 1: A1 [0 0], A2 [0 6], A3 [6 0], A4 [6 6]
%       - Config 2:
%           [0 0], [0 2], [0 4], [0 6], [2 0], [2 6], [4 0], [4 6],
%           [6 0], [6 2], [6 4], [6 6]
%   4) Scenario 4: 40x40 site
%       - Config 1: A1 [0 0], A2 [40 0], A3 [20 40]
%       - Config 2: large set around perimeter from [0..40] steps of 5
%
% TARGET LOCATION OPTIONS:
%   (1) [2 2], (2) [3 3], (3) [5 1], (4) Random within bounding box
%
% The user is also prompted for:
%   - An error ratio (e.g. 0.1 for ±10% distance noise)
%   - Number of Monte Carlo runs (e.g. 50)
%
% The script then runs:
%   simulateTrilateration(antennaPositions, target, errorRatio, nMC, scenarioLabel, configDescription)
%   simulateMultilateration(rfidPositions, target, errorRatio, nMC, scenarioLabel, configDescription)
%
%   Author: Simon M.

    clear; clc; close all;
    fprintf('=== LATERATION CONFIGURATION MASTER SCRIPT ===\n\n');

    % ---------------------------------------------------------------------
    % 1) User Prompt: Choose Scenario (1–4)
    % ---------------------------------------------------------------------
    fprintf('Available Scenarios:\n');
    fprintf('  1) Scenario 1\n');
    fprintf('  2) Scenario 2\n');
    fprintf('  3) Scenario 3\n');
    fprintf('  4) Scenario 4\n');
    scenarioChoice = input('Select a scenario (1–4): ');

    if ~(ismember(scenarioChoice, [1,2,3,4]))
        error('Invalid scenario choice.');
    end

    % ---------------------------------------------------------------------
    % 2) User Prompt: Choose Target (or Random)
    % ---------------------------------------------------------------------
    fprintf('\nAvailable Target Options:\n');
    fprintf('  1) [2 2]\n');
    fprintf('  2) [3 3]\n');
    fprintf('  3) [5 1]\n');
    fprintf('  4) Random within bounding box\n');

    targetChoice = input('Select a target option (1–4): ');
    if ~(ismember(targetChoice,[1,2,3,4]))
        error('Invalid target choice.');
    end

    % ---------------------------------------------------------------------
    % 3) Prompt for Error Ratio and Monte Carlo Iterations
    % ---------------------------------------------------------------------
    errorRatio = input('\nEnter error ratio (e.g., 0.1 for ±10%): ');
    nMC = input('Enter number of Monte Carlo runs (e.g., 50): ');

    % ---------------------------------------------------------------------
    % 4) Define Positions Based on Scenario
    % ---------------------------------------------------------------------
    switch scenarioChoice
        case 1
            % Scenario 1
            antennaPositions = [ 0 1;
                                        6 1;
                                        3 6 ];
            tagPositions = [   0 0;
                                       0 3;
                                       0 6;
                                       3 0;
                                       3 6;
                                       6 0;
                                       6 3;
                                       6 6 ];
            xBound = [0, 6];  % for random
            yBound = [0, 6];

        case 2
            % Scenario 2
            antennaPositions = [ 0 0;
                                        6 0;
                                        6 6 ];
            tagPositions = [   0 0;
                                       0 3;
                                       0 6;
                                       3 0;
                                       3 6;
                                       6 0;
                                       6 3;
                                       6 6 ];
            xBound = [0, 6];
            yBound = [0, 6];

        case 3
            % Scenario 3
            antennaPositions = [ 0 0;
                                        0 6;
                                        6 0;
                                        6 6 ];
            tagPositions = [   0 0;
                                       0 2;
                                       0 4;
                                       0 6;
                                       2 0;
                                       2 6;
                                       4 0;
                                       4 6;
                                       6 0;
                                       6 2;
                                       6 4;
                                       6 6 ];
            xBound = [0, 6];
            yBound = [0, 6];

        case 4
            % Scenario 4
            antennaPositions = [  0 0;
                                        40 0;
                                        20 40 ];
            % 40x40 perimeter RFID positions
            tagPositions = [
                0   0; 0   5; 0  10; 0  15; 0  20; 0  25; 0  30; 0  35; 0  40;
                5   0; 5  40;
                10  0; 10 40;
                15  0; 15 40;
                20  0; 20 40;
                25  0; 25 40;
                30  0; 30 40;
                35  0; 35 40;
                40  0; 40  5; 40 10; 40 15; 40 20; 40 25; 40 30; 40 35; 40 40
            ];
            xBound = [0, 40];
            yBound = [0, 40];
    end

    % ---------------------------------------------------------------------
    % 5) Determine Target Position
    % ---------------------------------------------------------------------
    switch targetChoice
        case 1
            P_true = [2 2];
        case 2
            P_true = [3 3];
        case 3
            P_true = [5 1];
        case 4
            % random within bounding box
            rx = rand*(xBound(2) - xBound(1)) + xBound(1);
            ry = rand*(yBound(2) - yBound(1)) + yBound(1);
            P_true = [rx, ry];
    end

    fprintf('\n=== Scenario %d Selected ===\n', scenarioChoice);
    fprintf('Configuration 1 (Trilateration) Antenna Positions:\n');
    disp(antennaPositions);
    fprintf('Configuration 2 (Multilateration) RFID Positions:\n');
    disp(tagPositions);
    fprintf('Target Position: [%.3f, %.3f]\n', P_true(1), P_true(2));
    fprintf('Error Ratio: %.3f\n', errorRatio);
    fprintf('Monte Carlo Runs: %d\n', nMC);

    % ---------------------------------------------------------------------
    % 6) Run Both Simulations
    % ---------------------------------------------------------------------
    % Provide short descriptions for clarity:
    config1Description = sprintf( ...
        ['Configuration 1 (Trilateration):\n' ...
         '  - Using classical trilateration with known antenna positions.\n' ...
         '  - Error ratio %.3f, %d Monte Carlo runs.\n'], ...
         errorRatio, nMC);

    config2Description = sprintf( ...
        ['Configuration 2 (Multilateration):\n' ...
         '  - Using multiple RFID points around perimeter.\n' ...
         '  - Error ratio %.3f, %d Monte Carlo runs.\n'], ...
         errorRatio, nMC);

    % Example calls to your existing scripts or functions:
    % Adjust these as needed to pass the right parameters.

    fprintf('\n--- Running Simulation for Trilateration (Config 1)...\n');
    SimulateTrilateration(antennaPositions, P_true, errorRatio, nMC, scenarioChoice, config1Description);

    fprintf('\n--- Running Simulation for Multilateration (Config 2)...\n');
    SimulateMultilateration(tagPositions, P_true, errorRatio, nMC, scenarioChoice, config2Description);


    fprintf('\n--- Simulation for Scenario %d completed. Compare results above! ---\n', scenarioChoice);
end
