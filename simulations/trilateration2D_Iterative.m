function P_est = trilateration2D_Iterative(antennaPositions, distances, initial_guess)
% TRILATERATION2D_MULTIANTENNA_ITERATIVE
%
% Uses a least-squares approach for an arbitrary number of 2D antennas.
% Minimizes the sum of squared differences between the guessed distances
% and the measured distances.
%
% Inputs:
%   antennaPositions (n x 2)
%   distances (n x 1)
%   initial_guess (1 x 2)
%
% Output:
%   P_est (1 x 2) - estimated position

    objective = @(P) sum( (sqrt((antennaPositions(:,1) - P(1)).^2 + ...
                                (antennaPositions(:,2) - P(2)).^2) - distances).^2 );

    opts = optimset('Display','off');
    P_est = fminsearch(objective, initial_guess, opts);
end