#include <vector>
#include <cmath>
#include <iostream>

struct cart
{
    double x, y, z;
};

struct polar
{
    double rho, theta, phi;
};

cart receiver_abs_location(cart reference, polar receiver_rel_location)
{
    cart receiver_absolute;

    double x_rel = receiver_rel_location.rho * sin(receiver_rel_location.phi) * cos(receiver_rel_location.theta);
    double y_rel = receiver_rel_location.rho * sin(receiver_rel_location.phi) * sin(receiver_rel_location.theta);
    double z_rel = receiver_rel_location.rho * cos(receiver_rel_location.phi);

    receiver_absolute.x = reference.x + x_rel;
    receiver_absolute.y = reference.y + y_rel;
    receiver_absolute.z = reference.z + z_rel;

    return receiver_absolute;
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