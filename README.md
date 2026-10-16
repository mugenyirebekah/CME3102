# CME3102
Communication Theory group work: Lab 8 (Sam Welikhe &amp; Rebekah Mugenyi)


### Specifications
This work was programmed using MatLab - the free online version


### Running the Simulation in MATLAB Online

1. Open [MATLAB Online](https://matlab.mathworks.com/) and ensure that `main.m` and the project files are available in your MATLAB Drive. If you uploaded `functions.zip`, extract it into a folder named `functions`. Ensure that the MATLAB helper files, including `get_params.m`, are located in `/MATLAB Drive/functions/functions/` if the ZIP created a nested folder structure.

2. Open the MATLAB Command Window and add the directory containing the helper functions to MATLAB's search path by running:

   ```matlab
   addpath('/MATLAB Drive/functions/functions')
   ```

3. Verify that MATLAB can locate the required parameter function by running:

   ```matlab
   which get_params
   ```

   MATLAB should display the path to `get_params.m`. If it reports that the function cannot be found, check that the ZIP archive was extracted correctly and that the file exists in the specified directory.

4. Navigate to the project root directory and run the simulation by executing:

   ```matlab
   cd('/MATLAB Drive')
   main
   ```

   The simulation will execute the end-to-end communication chain, perform validation checks, generate performance plots, and save the figures and sweep results in the `figures` directory. If MATLAB Online is restarted, repeat the `addpath` command before running `main`, because the manually added search path may not persist between sessions.
