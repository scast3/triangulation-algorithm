import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
import glob
import matplotlib.dates as mdates


def create_df(testname):

    # file io
    filename = os.path.join("..", "test_sheets", f"{testname}_.csv")
    search_pattern = os.path.join("..", "test_sheets", f"{testname}*.csv")
    matching_files = glob.glob(search_pattern)

    if matching_files:
        filename = matching_files[0]
        print(f"Found file: {filename}")
    else:
        print("No matching file found")

    # cleaning the dataframe
    raw_df = pd.read_csv(filename, skiprows=2)
    raw_df.columns = raw_df.columns.str.strip()
    raw_df.columns = raw_df.columns.str.replace(r'^//\s*', '', regex=True)
    return raw_df


def convert_to_dist(some_df, rssi_0, n):
    some_df["Distance"] = 10**((rssi_0 - some_df["RSSI"])/(10*n)) 

def moving_avg(some_df, window_size):
    print("TODO")

def display_graph(some_df, antennas, tags = None):

    for a in antennas:
        ant_df = some_df[some_df["Antenna"] == a]

        if tags != None:
            plt.figure(figsize=(12, 8))
            for tag in tags:
                temp_df = ant_df[ant_df["EPC"] == tag]
                
                plt.plot(temp_df['Timestamp'], temp_df['Distance'], label=f'Tag {tag} on Antenna {a}')

            plt.xlabel('Timestamp')
            plt.ylabel('Dist (m)')
            plt.title(f'Distance vs. Timestamp for Antenna {a}')
            plt.legend()
            plt.grid(True)

            plt.show()
        else:
            print("TODO")
