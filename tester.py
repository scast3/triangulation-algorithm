import numpy as np

n_transmitters = 2

transmitter_locations = [(0,0), (4,6)]
g_location = (4,4)

true_location = (3,3)
sensor_tof_d = []

# THIS DOES NOT HAPPEN IN PRACTICe
for coord in transmitter_locations:
    trans_x = coord[0]
    trans_y = coord[1]
    x = true_location[0]
    y = true_location[1]
    d = np.sqrt((trans_x - x)**2 + (trans_y - y)**2)
    sensor_tof_d.append(d)

# THIS IS ALL WE KNOW, treat it as a given
print(f"Distance from TOF: {sensor_tof_d}")

def predict(guess):

    estimated_d_vals = []
    for coord in transmitter_locations:
        trans_x = coord[0]
        trans_y = coord[1]
        estimated_x = guess[0]
        estimated_y = guess[1]

        d = np.sqrt((trans_x - estimated_x)**2 + (trans_y - estimated_y)**2)
        estimated_d_vals.append(d)

    return estimated_d_vals

def precict_recurse():
    initial = g_location
    thresh = 0.01

    



print(predict(g_location))