
function plotAllTags(tagPositions, chosenIdx)
% Plots all tags in light gray, then plots the "chosen" 5 in distinct colors.

    scatter(tagPositions(:,1), tagPositions(:,2), 80, [0.6 0.6 0.6], 'filled', ...
        'DisplayName','All Tags');
    hold on;
    colorMap = lines(length(chosenIdx));
    for i = 1:length(chosenIdx)
        idx = chosenIdx(i);
        scatter(tagPositions(idx,1), tagPositions(idx,2), 80, colorMap(i,:), 'filled', ...
            'DisplayName', sprintf('Tag#%d (chosen)', idx));
    end
end