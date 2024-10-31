#include <vector>
#include <cmath>
#include <setup.h>

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
    return 0;
}
