function SimulateTrilateration(antennaPositions, P_true, errorRatio, nMC, scenarioChoice, config1Description)
% SIMULATETRILATERATION
%
% Refactored version of the "Trilateration2D_Configuration1_UserInput" script.
% Now it accepts all necessary inputs as function arguments (no prompts).
%
% Inputs:
%   antennaPositions : (n x 2) array of antenna coordinates
%   P_true           : [x, y] for the true RFID chip (target) position
%   errorRatio       : e.g., 0.1 for ±10% distance noise
%   nMC              : number of Monte Carlo iterations
%   scenarioLabel    : string identifying the scenario (e.g. 'Scenario1_Config1')
%   configDescription: short text describing this configuration (for clarity)
%
% This function:
%   - Computes exact distances from each antenna to P_true
%   - Generates a single figure with 4 subplots (2x2):
%       (1) Ideal (no noise),
%       (2) One noisy realization,
%       (3) Error bounds + intersection region,
%       (4) Monte Carlo error vs. iteration.

    % 0) Basic info
    fprintf('\n=== Running Trilateration (Config 1) ===\n');
    fprintf('%s\n', config1Description);  % Show short description in console
    fprintf('Scenario: %s\n', scenarioChoice);

    % ---------------------------------------------------------------------
    % 1) Check how many antennas
    % ---------------------------------------------------------------------
    nAntennas = size(antennaPositions,1);
    if nAntennas < 3
        error('At least 3 antennas are required for 2D trilateration.');
    end

    % Print antenna info (optional)
    fprintf('\n-- Using %d Antennas (Config 1) --\n', nAntennas);
    for i = 1:nAntennas
        fprintf('Antenna A%d at (%.2f, %.2f)\n', i, antennaPositions(i,1), antennaPositions(i,2));
    end

    % ---------------------------------------------------------------------
    % 2) Compute exact distances
    % ---------------------------------------------------------------------
    d_exact = zeros(nAntennas,1);
    for i = 1:nAntennas
        d_exact(i) = norm(P_true - antennaPositions(i,:));
    end

    % ---------------------------------------------------------------------
    % 3) Create a figure with 4 subplots (2x2)
    % ---------------------------------------------------------------------
    figureName = sprintf('Trilateration - %s', scenarioChoice);
    figure('Name', figureName, 'NumberTitle','off',...
           'Position',[100,100,1400,800]);
    sgtitle(sprintf('2D Trilateration (Config 1) | %s', scenarioChoice));

    % We'll arrange them in a 2x2 layout:
    %  Subplot (2,2,1): Ideal distances
    %  Subplot (2,2,2): One noisy realization
    %  Subplot (2,2,3): Error bounds & intersection
    %  Subplot (2,2,4): Monte Carlo average error vs. iteration

    colorMap = lines(nAntennas);
    theta = linspace(0, 2*pi, 360);

    %% --------------------------------------------------------------------
    %  PLOT #1 (2,2,1): Ideal (Noise-Free) Distances
    % ---------------------------------------------------------------------
    subplot(2,2,1);
    hold on; grid on; axis equal;
    title('Plot #1: Ideal (No Noise)');

    % Solve with exact distances (iterative approach)
    P_est_ideal = trilateration2D_Iterative(antennaPositions, d_exact, ...
                                            mean(antennaPositions,1));

    % Plot antennas
    for i = 1:nAntennas
        scatter(antennaPositions(i,1), antennaPositions(i,2), 100, colorMap(i,:), 'filled');
        text(antennaPositions(i,1), antennaPositions(i,2), sprintf(' A%d', i), 'Color','k');
    end

    % Plot the true position
    scatter(P_true(1), P_true(2), 100, 'k','filled','DisplayName','True');

    % Plot the estimated position (ideal)
    scatter(P_est_ideal(1), P_est_ideal(2), 100, 'm','filled','DisplayName','Est(Ideal)');

    % Draw circles = exact distances
    for i = 1:nAntennas
        rExact = d_exact(i);
        xCirc = antennaPositions(i,1) + rExact*cos(theta);
        yCirc = antennaPositions(i,2) + rExact*sin(theta);
        plot(xCirc, yCirc, '--', 'Color', colorMap(i,:), 'LineWidth', 1,'HandleVisibility','off');
    end

    err_ideal = norm(P_est_ideal - P_true);
    text(P_est_ideal(1), P_est_ideal(2)+0.3, ...
         sprintf('Err=%.4f', err_ideal), 'Color','m','FontWeight','bold');

    legendStr1 = arrayfun(@(k) sprintf('A%d',k),1:nAntennas,'UniformOutput',false);
    legendStr1 = [legendStr1,{'True','Est(Ideal)'}];
    legend(legendStr1, 'Location','best');

    %% --------------------------------------------------------------------
    %  PLOT #2 (2,2,2): One Noisy Realization
    % ---------------------------------------------------------------------
    subplot(2,2,2);
    hold on; grid on; axis equal;
    title('Plot #2: One Noisy Realization');

    % Generate one set of noisy distances
    d_noisy_once = zeros(nAntennas,1);
    for i = 1:nAntennas
        distErrorBound = errorRatio * d_exact(i);
        noise_i = (rand - 0.5)*2 * distErrorBound;
        d_noisy_once(i) = max(d_exact(i) + noise_i, 1e-6);
    end

    % Solve with these noisy distances
    P_est_noisy_once = trilateration2D_Iterative(antennaPositions, d_noisy_once, ...
                                                 mean(antennaPositions,1));

    % Plot antennas
    for i = 1:nAntennas
        scatter(antennaPositions(i,1), antennaPositions(i,2), 100, colorMap(i,:), 'filled');
        text(antennaPositions(i,1), antennaPositions(i,2), sprintf(' A%d', i), 'Color','k');
    end

    % Plot true position
    scatter(P_true(1), P_true(2), 100, 'k','filled','DisplayName','True');

    % Plot estimated position
    scatter(P_est_noisy_once(1), P_est_noisy_once(2), 100, 'm','filled','DisplayName','Est(Noisy)');

    % Draw circles = noisy distances
    for i = 1:nAntennas
        rNoisy = d_noisy_once(i);
        xCirc = antennaPositions(i,1) + rNoisy*cos(theta);
        yCirc = antennaPositions(i,2) + rNoisy*sin(theta);
        plot(xCirc, yCirc, '--', 'Color', colorMap(i,:), 'LineWidth', 1,'HandleVisibility','off');
    end

    err_noisy_once = norm(P_est_noisy_once - P_true);
    text(P_est_noisy_once(1), P_est_noisy_once(2)+0.3, ...
         sprintf('Err=%.4f', err_noisy_once), 'Color','m','FontWeight','bold');

    legendStr2 = arrayfun(@(k) sprintf('A%d',k),1:nAntennas,'UniformOutput',false);
    legendStr2 = [legendStr2,{'True','Est(Noisy)'}];
    legend(legendStr2, 'Location','best');

    %% --------------------------------------------------------------------
    %  PLOT #3 (2,2,3): Error Bounds (Min/Max Circles) + Intersection
    % ---------------------------------------------------------------------
    subplot(2,2,3);
    hold on; grid on; axis equal;
    title('Plot #3: Error Bounds + Intersection');

    rMin = zeros(nAntennas,1);
    rMax = zeros(nAntennas,1);
    for i = 1:nAntennas
        rMin(i) = max(d_exact(i)*(1 - errorRatio), 1e-6);
        rMax(i) = d_exact(i)*(1 + errorRatio);
    end

    % Plot antennas
    for i = 1:nAntennas
        scatter(antennaPositions(i,1), antennaPositions(i,2), 100, colorMap(i,:), 'filled');
        text(antennaPositions(i,1), antennaPositions(i,2), sprintf(' A%d', i), 'Color','k');
    end

    % Plot the true position
    scatter(P_true(1), P_true(2), 100, 'k','filled','DisplayName','True');

    % Draw min/max circles
    for i = 1:nAntennas
        xCenter = antennaPositions(i,1);
        yCenter = antennaPositions(i,2);

        xMin = xCenter + rMin(i)*cos(theta);
        yMin = yCenter + rMin(i)*sin(theta);
        plot(xMin, yMin, 'k--', 'LineWidth', 1,'HandleVisibility','off');

        xMax = xCenter + rMax(i)*cos(theta);
        yMax = xCenter + rMax(i)*sin(theta);  % [CORRECTION: yCenter + rMax(i)*sin(theta)]
        yMax = yCenter + rMax(i)*sin(theta);  % fix any copy/paste slip

        plot(xMax, yMax, 'k--', 'LineWidth', 1,'HandleVisibility','off');
    end

    % Intersection region (brute force)
    allX = [antennaPositions(:,1); P_true(1)];
    allY = [antennaPositions(:,2); P_true(2)];
    margin = 1;
    xMinBox = min(allX) - margin;  
    xMaxBox = max(allX) + margin;
    yMinBox = min(allY) - margin;  
    yMaxBox = max(allY) + margin;

    N = 200;
    xRange = linspace(xMinBox, xMaxBox, N);
    yRange = linspace(yMinBox, yMaxBox, N);
    [X,Y] = meshgrid(xRange, yRange);
    intersectionMask = true(size(X));

    for i = 1:nAntennas
        distGrid = sqrt( (X - antennaPositions(i,1)).^2 + ...
                          (Y - antennaPositions(i,2)).^2 );
        inRange_i = (distGrid >= rMin(i)) & (distGrid <= rMax(i));
        intersectionMask = intersectionMask & inRange_i;
    end

    Z = double(intersectionMask);
    [~,h] = contourf(X, Y, Z, [0.5, 0.5], 'FaceColor', 'y',...
                     'FaceAlpha', 0.3, 'EdgeColor', 'none');

    legend({'A1','A2','A3','True','Min/Max Circles'}, 'Location','best');
    hold off;

    %% --------------------------------------------------------------------
    %  PLOT #4 (2,2,4): Monte Carlo - Average Error vs. Iteration
    % ---------------------------------------------------------------------
    subplot(2,2,4);
    hold on; grid on;
    title(sprintf('Plot #4: Monte Carlo (%d Iterations)', nMC));
    xlabel('Iteration'); 
    ylabel('Error');

    allErrors = zeros(nMC,1);
    for iter = 1:nMC
        % Generate new noisy distances
        d_noisy_iter = zeros(nAntennas,1);
        for i = 1:nAntennas
            distErrorBound = errorRatio * d_exact(i);
            noise_i = (rand - 0.5)*2 * distErrorBound;
            d_noisy_iter(i) = max(d_exact(i) + noise_i, 1e-6);
        end

        % Solve
        P_est_iter = trilateration2D_Iterative(antennaPositions, d_noisy_iter, ...
                                               mean(antennaPositions,1));
        allErrors(iter) = norm(P_est_iter - P_true);
    end

    % Plot single-run error (red line)
    plot(allErrors, 'ro-', 'DisplayName','Single-run Error');

    % Running average (blue line)
    runningAvg = cumsum(allErrors) ./ (1:nMC)';
    plot(runningAvg, 'b.-', 'DisplayName','Running Avg');

    legend('Location','best');
    hold off;

    fprintf('Trilateration (Config 1) Complete for %s.\n', scenarioChoice);
end
