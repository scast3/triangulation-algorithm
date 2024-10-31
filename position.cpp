#include <vector>
#include <cmath>

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
    cart reference = {0, 0, 0};                                          // assuming ref is at coord 0,0,0
    cart nozzle = {5, 5, 5};                                             // initial nozzle position
    std::vector<cart> receivers = {{1, 1, 1}, {10, 10, 10}, {5, 10, 5}}; // 3 reciervers with different cartesian_coords

    cart nozzle_position = triangulatePosition(reference, nozzle, receivers);

    return 0;
}
