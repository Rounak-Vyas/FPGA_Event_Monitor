# V2 — FPGA to ESP32 over UART

## Overview
This version extends V1 by connecting the FPGA event monitor to an ESP32 through UART communication.

## Hardware
- SIMS Raptor Artix-7 FPGA development board
- ESP32 development board
- PC for FPGA programming and serial monitoring

## Features
- Four-channel event monitoring on the FPGA
- Event counting and LED indications
- UART telemetry transmitted from FPGA to ESP32
- ESP32 receives and parses the telemetry data

## Communication
The FPGA transmits event-monitoring data over UART to the ESP32, which receives and parses the incoming message.

## Source Files
### FPGA
- `debouncer.v` — Input debouncing
- `event_counter.v` — Event counting logic
- `led.v` — LED-related logic
- `top.v` — Top-level FPGA module
- `uart_tx.v` — UART transmission
- XDC file — FPGA pin constraints

### ESP32
- ESP32 `.ino` sketch — UART reception and data parsing

## Status
Completed hardware integration milestone. The ESP32 receives and parses event data from the FPGA.

## Next Version
V3 introduces Blynk IoT dashboard integration for remote monitoring.
