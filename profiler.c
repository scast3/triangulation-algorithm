#include <stdio.h>
#include <stdlib.h>

#define RESOLUTION 32000 // change based on how many datapoints we have

/// @brief 
/// @param f 
/// @return 
float* parse_file(&string f)
{
    FILE *file;
    char filename[] = f;
    char buffer[200000];
    float z_values[RESOLUTION];
    int i = 0;

    file = fopen(filename, "r");
    if (file == NULL)
    {
        perror("Error opening file");
        return 1;
    }

    // Read the entire line from the file
    if (fgets(buffer, sizeof(buffer), file) == NULL)
    {
        perror("Error reading file");
        fclose(file);
        return 1;
    }

    fclose(file); // Close the file

    // Parse the line using strtok and convert values to floats
    char *token = strtok(buffer, ",");
    while (token != NULL && i < RESOLUTION)
    {
        z_values[i++] = strtof(token, NULL); // Convert string to float and store
        token = strtok(NULL, ",");
    }

    return z_values;
}

int main()
{
    return 0;
}