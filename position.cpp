#include <vector>
#include <cmath>

struct coordinate // this is wrong, radar works with polar coordinates
{
    double x, y, z;
};

double calculateDistance(coordinate p1, coordinate p2)
{
    // just use the distance formula to calculate dist between 2 coords
    return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2) + pow(p1.z - p2.z, 2));
}

coordinate triangulatePosition(coordinate reference, coordinate nozzle, const std::vector<coordinate> &receivers)
{
    for (const auto &receiver : receivers)
    {
        double dist_ref = calculateDistance(reference, receiver);
        double dist_nozzle = calculateDistance(nozzle, receiver);

        // triangulation stuff
    }

    coordinate computed_position = {0.0, 0.0, 0.0}; // Placeholder
    return computed_position;
}

int main()
{
    coordinate reference = {0, 0, 0};                                          // assuming ref is at coord 0,0,0
    coordinate nozzle = {5, 5, 5};                                             // initial nozzle position
    std::vector<coordinate> receivers = {{1, 1, 1}, {10, 10, 10}, {5, 10, 5}}; // 3 reciervers with different coordinates

    coordinate nozzle_position = triangulatePosition(reference, nozzle, receivers);

    return 0;
}
