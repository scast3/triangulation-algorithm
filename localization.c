// gives the location of 

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// #include <profier.h> include profiler for the z coordinate
// globals
#define THRESH 0.001 // (milimeters) convergence threshold
#define G_SAMPLES 10000 // number of samples from the Gcode path

coord path[G_SAMPLES];
coord pred[G_SAMPLES]; // predicted values from the algorithm

int delta_t = 0; // keeping track of each discrete time interval

// rfid tag positions
coord tag1 = {3.0, 4.0};
coord tag2 = {9.0, 1.0};
coord tag2 = {9.0, 7.0};

// RSSI globals
double rssi_0 = -30.0; // RSSI at reference distance
int path_loss = 2;




// cartesian coordinate struct
typedef struct {
    double x;
    double y;
} coord;

double euclidian(coord c1, coord c2){
    return sqrt(pow(c1.x-c2.x,2)+pow(c1.y-c2.y,2));
}



// use rssi value to calculate the distance 
double calculateDistance(double rssi) {
    return pow(10, (rssi_0 - rssi) / (10 * path_loss));
}

double getRSSI(){
    return 0.0;
}

int main(){

    for (;;){
        
    

        delta_t++; // increment time interval every iteration
    }
    printf("hello world");
    return 0;
}