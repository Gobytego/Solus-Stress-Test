SolusOS Stress Test Utility Summary
==================================

This utility is a comprehensive Bash-based automation script designed for the Solus operating system in 2026. It facilitates rigorous hardware validation by orchestrating a series of stress tests targeting the Central Processing Unit (CPU) and System Memory (RAM). By integrating low-level stress tools with a graphical multiplexer, it provides real-time visual feedback on hardware performance and stability.

Core Functionality
------------------

The script automates four primary phases of hardware analysis:

* **Sequential Core Sweep:** Tests each logical CPU core individually to identify localized instability or thermal inconsistencies.
* **Total System Load:** Engages all available CPU cores at 100% capacity to test maximum thermal output and power supply stability.
* **Thread Alternation:** Alternates load between even and odd-numbered logical cores to analyze the efficiency of hyper-threading and physical core distribution.
* **Memory Saturation:** Optional phase that forces physical RAM allocation using 80% of available capacity to detect memory address errors or paging issues.

How to Use the Utility
----------------------

Follow these steps to deploy and run the utility on a Solus system:

1.  **Initialization:** Save the script as a `.sh` file (e.g., `stress_test.sh`).
2.  **Permissions:** Grant execution rights via the terminal using `chmod +x stress_test.sh`.
3.  **Execution:** Launch the script by typing `./stress_test.sh` in your default terminal.
4.  **Configuration:** Respond to the interactive prompts to define the test duration (seconds), the number of total cycles, and whether to include memory stress tests.

Technical Integration
---------------------

The utility leverages several 2026-standard Linux components to ensure accuracy and visibility:

* **Tmux:** Automatically splits the terminal window into a dual-pane interface.
* **Btop:** Provides a high-resolution graphical view in the top pane, automatically configured to display only CPU and Memory bars.
* **Stress-ng:** The underlying engine that generates the computational load, utilizing taskset for precise core pinning.
* **Eopkg Integration:** Automatically detects and installs any missing dependencies from the Solus repositories before the test begins.

Upon completion of the defined cycles, the utility performs a clean exit, terminating all background monitoring processes and returning the terminal to its original state.
