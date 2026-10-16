# CME3102

## Industrial Sensor Telemetry Simulator

**Language:** MATLAB (base MATLAB only; no toolboxes required). Written for MATLAB R2016b or newer. Requires `repelem`, `bitget`, and `erfcinv`.

An end-to-end digital communication system simulation:

**Sensor → Sampling (100 Hz) → 8-bit PCM → Manchester line coding → BPSK modulation → AWGN channel → Coherent BPSK demodulation → Manchester decoding (hard and soft decisions) → PCM decoding → Signal reconstruction.**

## How to Run

### Option 1: Local MATLAB Installation

1. Clone or download the repository.
2. Open MATLAB and set the current folder to the repository root (the directory containing `main.m`).
3. Run the simulation by entering the following command in the MATLAB Command Window:

   ```matlab
   main
   ```

The simulation should complete in well under a minute under typical conditions. Results are repeatable using the configured random seed (`rng(7)`).

### Option 2: MATLAB Online

1. Open [MATLAB Online](https://matlab.mathworks.com/) and sign in.
2. Upload the project files to MATLAB Drive, ensuring that `main.m` is located in `/MATLAB Drive`.
3. If the `functions` directory is provided as a ZIP archive, extract it into MATLAB Drive. Ensure that the helper `.m` files, including `get_params.m`, are accessible.
4. If extraction creates a nested directory structure such as `/MATLAB Drive/functions/functions/`, add the inner directory to the MATLAB search path:

   ```matlab
   addpath('/MATLAB Drive/functions/functions')
   ```

   If the helper files are directly inside `/MATLAB Drive/functions/`, use:

   ```matlab
   addpath('/MATLAB Drive/functions')
   ```

5. Verify that MATLAB can locate the parameter function:

   ```matlab
   which get_params
   ```

   MATLAB should display the path to `get_params.m`.

6. Set the current folder to the project root and run the simulation:

   ```matlab
   cd('/MATLAB Drive')
   main
   ```

**Note:** If MATLAB Online is restarted, the manually added function path may need to be added again. The simulation creates a `figures` directory in the project root if it does not already exist.

## Outputs

- **Command Window:** Validation results, demo-run metrics, the Eb/N0 sweep table, and Shannon capacity analysis.
- **`figures/`:** Generated plots and `sweep_results.txt`.

The figures illustrate the communication stages, transmitted and received signals, demodulation and decoding results, bit error rate (BER), reconstruction mean squared error (MSE), reconstruction signal-to-noise ratio (SNR), and Shannon capacity.

## Repository Layout

```text
Industrial-Sensor-Telemetry-Simulator/
├── main.m
├── functions/
│   ├── get_params.m
│   ├── pcm_encode.m
│   ├── manchester_encode.m
│   ├── bpsk_modulate.m
│   ├── awgn_channel.m
│   ├── bpsk_demodulate.m
│   ├── manchester_decode.m
│   ├── pcm_decode.m
│   ├── compute_metrics.m
│   ├── theory.m
│   └── ... other helper functions
├── figures/
│   └── ... generated figures and sweep_results.txt
└── report/
    ├── report source
    └── report.pdf
```

Each helper function is stored in its own `.m` file inside `functions/`. The `main.m` script adds this directory to the MATLAB search path before calling the helper functions.

## Key Parameters

The simulation parameters are defined in `functions/get_params.m`.

| Parameter | Value |
|---|---:|
| Information bit rate, \(R_b\) | 800 bit/s |
| Manchester chip rate | 1,600 chip/s |
| Carrier frequency | 3,200 Hz |
| Bandwidth, \(B\) | 3,200 Hz |
| PCM resolution | 8 bits per sample |
| Sampling frequency | 100 Hz |

The BPSK carrier uses two cycles per Manchester chip. The bandwidth is defined as the BPSK null-to-null bandwidth.

**Eb/N0 convention:** \(E_b/N_0\) is defined per information bit, before Manchester encoding. This convention is used throughout the simulation and its theoretical comparisons.

## Reproducibility

The random number generator is initialized using `rng(7)`, making the results repeatable for the same code, parameters, and MATLAB environment. The simulation includes validation checks for bit counts, chip counts, waveform lengths, noiseless recovery, quantization error, and channel noise variance.