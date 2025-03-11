import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
import glob
import matplotlib.dates as mdates


def create_df(testname):

    # file io
    # filename = os.path.join("..", "test_sheets", f"{testname}_.csv") - path for personal computer
    # filename = os.path.join("..", "test_sheets", f"{testname}_.csv")
    # search_pattern = os.path.join("..", "test_sheets", f"{testname}*.csv")
    filename = os.path.join("sheets", f"{testname}_.csv")
    search_pattern = os.path.join("sheets", f"{testname}*.csv")
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

def smooth(some_df, window_size, variable, print_stats = False, show_graph = False, distance = None):
    some_df[f"Norm_{variable}"] = some_df[variable].rolling(window=window_size).mean()
    
    min_val = some_df[variable].min()
    max_val = some_df[variable].max()

    min_time = some_df[variable].min()
    max_time = some_df[variable].max()

    avg_val = some_df[variable].mean()
    

    std_dev = some_df[variable].std()
    median_val = some_df[variable].median()
    variance_val = some_df[variable].var()
    percentiles = some_df[variable].quantile([0.25, 0.5, 0.75])
    skewness = some_df[variable].skew()
    kurtosis = some_df[variable].kurtosis()
    peak_to_peak = max_val - min_val

    if print_stats:
        print(f"Range of RSSI: {min_val} to {max_val}")
        print(f"Data Time Range: {max_time - min_time}")
        print(f"Average RSSI: {avg_val}")
        print(f"Standard Deviation: {std_dev}")
        print(f"Median RSSI: {median_val}")
        print(f"Variance: {variance_val}")
        print(f"25th Percentile: {percentiles[0.25]}")
        print(f"50th Percentile (Median): {percentiles[0.5]}")
        print(f"75th Percentile: {percentiles[0.75]}")
        print(f"Skewness: {skewness}")
        print(f"Kurtosis: {kurtosis}")
        print(f"Peak-to-Peak Amplitude: {peak_to_peak}")
    
    if show_graph:
        plt.figure(figsize=(12, 8))
        plt.plot(some_df['Timestamp'], some_df[f"Norm_{variable}"], label=f'Smoothed RSSI')
        plt.axhline(y=avg_val, color='r', linestyle='--', label=f'Average RSSI: {avg_val:.2f}')
        plt.axhline(y=median_val, color='y', linestyle='--', label=f'Median RSSI: {median_val:.2f}')
        plt.axhline(y=percentiles[0.75], color='g', linestyle='--', label=f'f"75th Percentile: {percentiles[0.75]}"')
        plt.axhline(y=percentiles[0.25], color='g', linestyle='--', label=f'f"25th Percentile: {percentiles[0.25]}"')
        plt.xlabel('Timestamp')
        plt.ylabel('RSSI')
        if distance:
            plt.title(f'Smoothed Data for {distance} meters and window size {window_size}')
        else:
            plt.title(f'Smoothed Data with window size {window_size}')
        plt.legend()
        plt.grid(True)
        plt.show()


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
