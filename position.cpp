#include <vector>
#include <cmath>
#include <setup.h>
#include <iostream>

struct cart
{
    double x, y, z;
};

struct polar
{
    double rho, theta, phi;
};

double euclidian(cart p1, cart p2)
{
    return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2) + pow(p1.z - p2.z, 2));
}

cart triangulatePosition(cart reference, cart nozzle, const std::vector<cart> &receivers)
{
    for (const auto &receiver : receivers)
    {
        double dist_ref = euclidian(reference, receiver);
        double dist_nozzle = euclidian(nozzle, receiver);

        // triangulation stuff
    }

    cart computed_position = {0.0, 0.0, 0.0}; // Placeholder
    return computed_position;
}

int main()
{
    cart reference = {0, 0, 0}; // known reference point

    int n_recievers = 3;
    // Example polar coordinates with values for rho (distance), theta (azimuthal angle in radians), and phi (polar angle in radians)
    std::vector<polar> radar_reciever_data = {
        {10, 0.785, 1.047}, // rho = 10, theta = 45°, phi = 60°
        {15, 1.570, 1.570}, // rho = 15, theta = 90°, phi = 90°
        {20, 2.356, 0.785}  // rho = 20, theta = 135°, phi = 45°
    };

    std::vector<cart> absolute_reciever_positions(n_recievers);

    for (int i = 0; i < n_recievers; i++)
    {
        absolute_reciever_positions[i] = receiver_abs_location(reference, radar_reciever_data[i]);
    }

    for (const auto &pos : absolute_reciever_positions)
    {
        std::cout << "Receiver Position: (" << pos.x << ", " << pos.y << ", " << pos.z << ")\n";
    }

    return 0;
}
