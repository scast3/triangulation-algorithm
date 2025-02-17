import math
from sllurp import SLLurp

# Constants
THRESH = 0.001  # millimeters
G_SAMPLES = 10000  # number of samples
RSSI_0 = -30.0  # RSSI at reference distance (d_0)
PATH_LOSS = 2  # path loss exponent
TAG_POSITIONS = [
    {"x": 3.0, "y": 4.0},
    {"x": 9.0, "y": 1.0},
    {"x": 9.0, "y": 7.0}
]

def euclidean(c1, c2):
    return math.sqrt((c1['x'] - c2['x'])**2 + (c1['y'] - c2['y'])**2)

def calculate_distance(rssi):
    return 10 ** ((RSSI_0 - rssi) / (10 * PATH_LOSS))

def get_rssi(reader_ip):
    reader = SLLurp(reader_ip)
    inventory = reader.inventory()
    
    rssi_values = []
    for tag in inventory:
        rssi_values.append(tag.rssi) 
    
    return rssi_values 

def main():
    reader_ip = '192.168.1.100'
    index = 0  
    
    path = []
    pred = [] 
    
    for i in range(G_SAMPLES):
        rssi_values = get_rssi(reader_ip)
        if rssi_values:
            for rssi in rssi_values:
                distance = calculate_distance(rssi)
                path_location = TAG_POSITIONS[index % len(TAG_POSITIONS)]
                path.append(path_location)
                pred.append({'x': path_location['x'] + distance, 'y': path_location['y']})
        index += 1
        

    print("Path:", path)
    print("Predictions:", pred)

if __name__ == '__main__':
    main()
