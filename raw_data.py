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


def regression(filename):
    
    data = pd.read_csv(filename)
    data = data.dropna()

    a1 = data[['Actual Distance', 'A1 Filtered RSSI']].copy()
    a2 = data[['Actual Distance', 'A2 Filtered RSSI']].copy()
    a3 = data[['Actual Distance', 'A3 Filtered RSSI']].copy()

    coeffs_a1 = np.polyfit(a1['A1 Filtered RSSI'], a1['Actual Distance'], 2)
    coeffs_a2 = np.polyfit(a2['A2 Filtered RSSI'], a2['Actual Distance'], 2)
    coeffs_a3 = np.polyfit(a3['A3 Filtered RSSI'], a3['Actual Distance'], 2)

    return coeffs_a1, coeffs_a2, coeffs_a3


def convert_to_dist(filename, tags, coeffs_a1, coeffs_a2, coeffs_a3):
    data = create_df(filename)
    result = pd.DataFrame()
    for index, row in data.iterrows():
        tag = row['EPC']
        if tag in tags:
            if row['Antenna'] == 1:
                coeffs = coeffs_a1
            elif row['Antenna'] == 2:
                coeffs = coeffs_a2
            elif row['Antenna'] == 3:
                coeffs = coeffs_a3
            else:
                continue

            rssi = row['RSSI']
            distance = np.polyval(coeffs, rssi)
            row['Distance'] = distance
            result = pd.concat([result, pd.DataFrame([row])], ignore_index=True)
            


    #result["Timestamp"] = pd.to_datetime(data["Timestamp"], format="%Y-%m-%d %H:%M:%S.%f")
    return result




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
