# V3 — FPGA Event Monitor with ESP32 and Blynk

## Overview
V3 extends the FPGA–ESP32 UART integration by introducing Blynk IoT Cloud for remote monitoring of event activity.

The FPGA handles event detection, counting and telemetry generation. The ESP32 receives and parses the telemetry before sending the data to Blynk Cloud.

## Hardware
- SIMS Raptor Artix-7 FPGA development board
- ESP32-C6 development board
- PC for FPGA programming and debugging

## Features

### FPGA
- Four-channel event monitoring
- Event counting and peak one-second count tracking
- Identification of the most active channel
- Per-channel alert generation
- UART telemetry transmission

### ESP32
- UART reception and telemetry parsing
- Wi-Fi connectivity
- Blynk Cloud integration
- Periodic dashboard updates

### Blynk Dashboard
- Current event counts for all four channels
- Peak event counts for all four channels
- Most active channel
- Channel alert status

## Communication Architecture

FPGA → UART → ESP32 → Wi-Fi → Blynk Cloud → Mobile Dashboard

## Source Files

### FPGA
- `debouncer.v` — Input debouncing
- `event_counter_peak.v` — Event counting and peak tracking
- `top_peak_topchannel.v` — Top-level integration and channel selection
- `uart_tx.v` — UART transmission
- `EISLER_MASTER.xdc` — FPGA pin constraints

### ESP32
- Integrated ESP32 `.ino` sketch — UART parsing, Wi-Fi and Blynk communication

## Status
Working integrated prototype with live Blynk dashboard updates.

## Future Improvements
- Time-window event charts
- Blynk notifications for channel alerts
- Further monitoring and visualization features
