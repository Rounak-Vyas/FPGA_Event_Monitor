# FPGA Event Monitor

An FPGA-based, multi-channel event monitoring system developed using a SIMS Raptor Artix-7 FPGA and an ESP32-C6. The project evolves through multiple milestones, from PC-based UART monitoring to wireless IoT monitoring using Blynk.

## Project Progress

### V1 — FPGA to PC over UART
- Four-channel event monitoring and counting
- Event indications using onboard LEDs
- UART telemetry displayed on a PC using a serial terminal such as PuTTY

### V2 — FPGA to ESP32 over UART
- Integrates the FPGA with an ESP32 over UART
- Receives and parses event-monitoring data on the ESP32

### V3 — FPGA, ESP32 and Blynk IoT Dashboard
- Sends event-monitoring data to Blynk Cloud
- Displays channel counts, peak counts, and the most active channel
- Includes channel alert status

## Repository Structure

- `V1_FPGA_UART_PC/` — First completed milestone
- `V2_FPGA_ESP32_UART/` — FPGA–ESP32 UART integration
- `V3_FPGA_ESP32_Blynk/` — IoT dashboard integration
- `Common/` — Shared documentation and reference files

Each version contains the source files relevant to that milestone.

## Hardware
- SIMS Raptor Artix-7 FPGA development board
- ESP32-C6 development board (introduced in later versions)
- PC with a USB connection for programming and serial monitoring

## Development Tools
- AMD/Xilinx Vivado
- Arduino IDE
- Blynk IoT platform (V3)

## Building and Running
Detailed setup, FPGA programming, UART configuration, and ESP32 instructions will be documented here as the project progresses.

## Project Status
V1 is the initial milestone. V2 and V3 will be added as their repository snapshots are prepared.

## License
License details will be added later.
