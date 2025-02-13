function SimulateMultilateration(tagPositions, P_true, errorRatio, nMC, scenarioChoice, config2Description)
% SIMULATEMULTILATERATION
%
% Refactored version of the "2D Multilateration Configuration 2 w/ User Input"
% script. Now it accepts all necessary inputs as function arguments (no prompts).
%
% Inputs:
%   tagPositions   : (N x 2) array of RFID tag coordinates
%   centerTrue     : [x, y] for the true center position
%   errorRatio     : e.g., 0.1 for ±10% noise
%   nMC            : number of Monte Carlo iterations
%   scenarioLabel  : string identifying the scenario (e.g., 'Scenario1_Config2')
%   configDescription : a short text describing this configuration
%
% This function:
%   - Finds the 5 closest tags to the center
%   - Creates a figure with 4 subplots:
%       (1) Ideal (no noise)
%       (2) One noisy realization
%       (3) Error bounds (min/max)
%       (4) Monte Carlo error vs iteration

    % 0) Basic housekeeping / figure naming
    fprintf('\n=== Running Multilateration (Config 2) ===\n');
    fprintf('%s\n', config2Description);  % Show the short description in console
    fprintf('Scenario: %s\n', scenarioChoice);

    % ---------------------------------------------------------------------
    % 1) FIND THE 5 CLOSEST TAGS
    % ---------------------------------------------------------------------
    nTags = size(tagPositions,1);   % total number of tags
    if nTags < 5
        error('At least 5 tags are required if we are to pick the 5 closest.');
    end

    allDistances = zeros(nTags,1);
    for i = 1:nTags
        allDistances(i) = norm(P_true - tagPositions(i,:));
    end
    [~, sortIdx] = sort(allDistances, 'ascend');
    chosenIdx = sortIdx(1:5);
    chosenTags = tagPositions(chosenIdx, :);
    d_exact = allDistances(chosenIdx);

    nAnchors = 5;

    % Print chosen tags to command window (optional)
    fprintf('\n-- 5 Closest Tags (Config 2) --\n');
    for i = 1:nAnchors
        fprintf('Tag %d: (%.2f, %.2f), Dist=%.3f\n', ...
            chosenIdx(i), chosenTags(i,1), chosenTags(i,2), d_exact(i));
    end

    % ---------------------------------------------------------------------
    % 2) CREATE A SINGLE FIGURE WITH 4 SUBPLOTS
    % ---------------------------------------------------------------------
    figureName = sprintf('Multilateration - %s', scenarioChoice);
    figure('Name', figureName, 'NumberTitle','off', 'Position',[100,100,1400,800]);
    sgtitle(sprintf('2D Multilateration (Config 2) | %s', scenarioChoice));

    theta = linspace(0, 2*pi, 360);

    % (A) Prepare an initial guess (centroid of chosen tags)
    initGuess = mean(chosenTags, 1);

    %% --------------------------------------------------------------------
    % SUBPLOT (2,2,1): Ideal (No Noise)
    % ---------------------------------------------------------------------
    subplot(2,2,1);
    hold on; grid on; axis equal;
    title('Plot #1: Ideal (Noise-Free)');

    centerEstIdeal = trilateration2D_Iterative(chosenTags, d_exact, initGuess);

    % Plot tags: all in gray, chosen 5 in color
    plotAllTags(tagPositions, chosenIdx);

    % Plot the true center
    scatter(P_true(1), P_true(2), 80, 'k', 'filled', 'DisplayName','Center(True)');

    % Plot the estimated center (ideal)
    scatter(centerEstIdeal(1), centerEstIdeal(2), 80, 'm', 'filled', 'DisplayName','Est(Ideal)');

    % Circles for EXACT distances
    colorMap = lines(nAnchors);
    for i = 1:nAnchors
        r = d_exact(i);
        xC = chosenTags(i,1) + r*cos(theta);
        yC = chosenTags(i,2) + r*sin(theta);
        plot(xC, yC, '--', 'Color', colorMap(i,:), 'LineWidth',1, 'HandleVisibility','off');
    end

    legend('Location','best');
    errIdeal = norm(centerEstIdeal - P_true);
    textAnnotation(sprintf('Err=%.4f', errIdeal), chosenTags);

    %% --------------------------------------------------------------------
    % SUBPLOT (2,2,2): One Noisy Realization
    % ---------------------------------------------------------------------
    subplot(2,2,2);
    hold on; grid on; axis equal;
    title('Plot #2: One Noisy Realization');

    d_noisy_once = zeros(nAnchors,1);
    for i = 1:nAnchors
        errBound = errorRatio * d_exact(i);
        noise_i = (rand - 0.5)*2 * errBound;
        d_noisy_once(i) = max(d_exact(i) + noise_i, 1e-6);
    end

    centerEstNoisy = trilateration2D_Iterative(chosenTags, d_noisy_once, initGuess);

    plotAllTags(tagPositions, chosenIdx);
    scatter(P_true(1), P_true(2), 80, 'k','filled','DisplayName','Center(True)');
    scatter(centerEstNoisy(1), centerEstNoisy(2), 80, 'm','filled','DisplayName','Est(Noisy)');

    for i = 1:nAnchors
        r = d_noisy_once(i);
        xC = chosenTags(i,1) + r*cos(theta);
        yC = chosenTags(i,2) + r*sin(theta);
        plot(xC, yC, '--', 'Color', colorMap(i,:), 'LineWidth',1,'HandleVisibility','off');
    end

    legend('Location','best');
    errNoisyOnce = norm(centerEstNoisy - P_true);
    textAnnotation(sprintf('Err=%.4f', errNoisyOnce), chosenTags);

    %% --------------------------------------------------------------------
    % SUBPLOT (2,2,3): Error Bounds (Min/Max Circles)
    % ---------------------------------------------------------------------
    subplot(2,2,3);
    hold on; grid on; axis equal;
    title('Plot #3: Error Bounds');

    rMin = zeros(nAnchors,1);
    rMax = zeros(nAnchors,1);
    for i = 1:nAnchors
        rMin(i) = max(1e-6, d_exact(i)*(1 - errorRatio));
        rMax(i) = d_exact(i)*(1 + errorRatio);
    end

    plotAllTags(tagPositions, chosenIdx);
    scatter(P_true(1), P_true(2), 80, 'k','filled','DisplayName','Center(True)');

    for i = 1:nAnchors
        xMin = chosenTags(i,1) + rMin(i)*cos(theta);
        yMin = chosenTags(i,2) + rMin(i)*sin(theta);
        plot(xMin, yMin, 'k--','LineWidth',1,'HandleVisibility','off');

        xMax = chosenTags(i,1) + rMax(i)*cos(theta);
        yMax = chosenTags(i,2) + rMax(i)*sin(theta);
        plot(xMax, yMax, 'k--','LineWidth',1,'HandleVisibility','off');
    end

    legend('Location','best');
    hold off;

    %% --------------------------------------------------------------------
    % 4) MONTE CARLO - Average Error vs. Iteration
    % ---------------------------------------------------------------------
    allErrors = zeros(nMC,1);

    for iter = 1:nMC
        % Add random noise for each iteration
        d_noisy = zeros(nAnchors,1);
        for i = 1:nAnchors
            errBound = errorRatio * d_exact(i);
            noise_i = (rand - 0.5)*2 * errBound;
            d_noisy(i) = max(d_exact(i) + noise_i, 1e-6);
        end

        centerEst = trilateration2D_Iterative(chosenTags, d_noisy, initGuess);
        allErrors(iter) = norm(centerEst - P_true);
    end

    %% --------------------------------------------------------------------
    % SUBPLOT (2,2,4): Monte Carlo Error vs. Iteration
    % ---------------------------------------------------------------------
    subplot(2,2,4);
    hold on; grid on;
    title(sprintf('Plot #4: Monte Carlo (%d Iterations)', nMC));
    xlabel('Iteration'); ylabel('Error');

    % Single-run error (red line)
    plot(allErrors, 'ro-','DisplayName','Single-run Error');

    % Running average (blue line)
    runAvg = cumsum(allErrors) ./ (1:nMC)';
    plot(runAvg, 'b.-','DisplayName','Running Avg');

    legend('Location','best');
    hold off;

    fprintf('Multilateration (Config 2) Complete for %s.\n', scenarioChoice);
end
