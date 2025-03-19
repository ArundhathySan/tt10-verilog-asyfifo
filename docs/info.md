<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

The Tiny Tapeout Asynchronous FIFO is a 4-bit wide, 8-depth FIFO buffer designed for asynchronous data transfer between different clock domains. It features independent read and write clocks, enabling smooth communication between fast and slow systems. Data is written when Write Enable (WE) is high on WCLK's rising edge and read when Read Enable (RE) is high on RCLK's rising edge. The design includes Full and Empty status flags to prevent overflow and underflow. Reset (rst_n) clears the FIFO, ensuring proper initialization. Optimized for Tiny Tapeout’s 8-input, 8-output format, this FIFO is ideal for compact, low-power applications.

## How to test

The Tiny Tapeout Asynchronous FIFO is a 4-bit wide, 8-depth FIFO buffer designed for seamless data transfer between different clock domains. To use it, first reset the FIFO by setting ui_in[4] = 0 and toggling the clocks (ui_in[2] and ui_in[3]), then set ui_in[4] = 1 to begin operation. Data is written by enabling ui_in[0], providing a 4-bit input on uio_in[3:0], and toggling the write clock (ui_in[2]), as long as the FIFO is not full (uo_out[5] = 0). Reading data requires setting ui_in[1] = 1 and toggling the read clock (ui_in[3]), outputting the oldest stored data on uo_out[3:0] if the FIFO is not empty (uo_out[4] = 0). To test the FIFO in EDA Playground, run a testbench with Icarus Verilog (iverilog) and view the waveform in GTKWave to verify correct data flow and flag behavior. For hardware testing on Tiny Tapeout, load the design onto the test harness, provide clock signals, input data, and observe the outputs and status flags to ensure proper operation.

## External hardware

The Tiny Tapeout Asynchronous FIFO does not require any external hardware for basic functionality. However, for hardware testing, we may use:

Oscilloscope or Logic Analyzer – To monitor clock signals, data input/output, and FIFO status flags.
External Clock Generator – If precise clock control is needed for testing different read/write speeds.
LED Indicators – To visualize FIFO Full (uo_out[5]) and Empty (uo_out[4]) status flags.
Microcontroller (e.g., Arduino, Raspberry Pi, or FPGA board) – To generate clock signals and control FIFO operations for real-world applications.
