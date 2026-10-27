set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
# Clock signal

set_property -dict { PACKAGE_PIN D5    IOSTANDARD LVCMOS33 } [get_ports { clk100 }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk100}];
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets INST_CLOCKING/inst/clk_in1_clk_wiz_0] 

##Buttons
set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports { push1 }]; 
set_property -dict { PACKAGE_PIN V15 IOSTANDARD LVCMOS33 } [get_ports { push2 }];
set_property -dict { PACKAGE_PIN U14 IOSTANDARD LVCMOS33 } [get_ports { push3 }];
set_property -dict { PACKAGE_PIN V14 IOSTANDARD LVCMOS33 } [get_ports { push4 }];


## LEDs
set_property -dict { PACKAGE_PIN U11   IOSTANDARD LVCMOS33 } [get_ports {LED[1]}]; 
set_property -dict { PACKAGE_PIN V11   IOSTANDARD LVCMOS33 } [get_ports {LED[2]}]; 
set_property -dict { PACKAGE_PIN V10   IOSTANDARD LVCMOS33 } [get_ports {LED[3]}]; 
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports {LED[4]}]; 
set_property -dict { PACKAGE_PIN T9	   IOSTANDARD LVCMOS33 } [get_ports {LED[5]}]; 
set_property -dict { PACKAGE_PIN G6	   IOSTANDARD LVCMOS33 } [get_ports {LED[6]}]; 
set_property -dict { PACKAGE_PIN H5	   IOSTANDARD LVCMOS33 } [get_ports {LED[7]}]; 
set_property -dict { PACKAGE_PIN J5	   IOSTANDARD LVCMOS33 } [get_ports {LED[8]}]; 
set_property -dict { PACKAGE_PIN H6	   IOSTANDARD LVCMOS33 } [get_ports {LED[9]}]; 
set_property -dict { PACKAGE_PIN J3	   IOSTANDARD LVCMOS33 } [get_ports {LED[10]}]; 
set_property -dict { PACKAGE_PIN J4	   IOSTANDARD LVCMOS33 } [get_ports {LED[11]}]; 
set_property -dict { PACKAGE_PIN K1	   IOSTANDARD LVCMOS33 } [get_ports {LED[12]}]; 
set_property -dict { PACKAGE_PIN K2	   IOSTANDARD LVCMOS33 } [get_ports {LED[13]}]; 
set_property -dict { PACKAGE_PIN J2	   IOSTANDARD LVCMOS33 } [get_ports {LED[14]}]; 
set_property -dict { PACKAGE_PIN H1	   IOSTANDARD LVCMOS33 } [get_ports {LED[15]}]; 
set_property -dict { PACKAGE_PIN C1	   IOSTANDARD LVCMOS33 } [get_ports {LED[16]}]; 


## SLIDE SW
set_property -dict { PACKAGE_PIN F4 IOSTANDARD LVCMOS33 } [get_ports {event_in[0]}]
set_property -dict { PACKAGE_PIN H4 IOSTANDARD LVCMOS33 } [get_ports {event_in[1]}]
set_property -dict { PACKAGE_PIN G3 IOSTANDARD LVCMOS33 } [get_ports {event_in[2]}]
set_property -dict { PACKAGE_PIN G4 IOSTANDARD LVCMOS33 } [get_ports {event_in[3]}]


           
## OV7670            

set_property -dict { PACKAGE_PIN D13 IOSTANDARD LVCMOS33 } [get_ports {ov7670_data[0]}];
set_property -dict { PACKAGE_PIN C15 IOSTANDARD LVCMOS33 } [get_ports {ov7670_data[1]}];
set_property -dict { PACKAGE_PIN D10 IOSTANDARD LVCMOS33 } [get_ports {ov7670_data[2]}];
set_property -dict { PACKAGE_PIN D12 IOSTANDARD LVCMOS33 } [get_ports {ov7670_data[3]}];
set_property -dict { PACKAGE_PIN G18 IOSTANDARD LVCMOS33 } [get_ports {ov7670_data[4]}];
set_property -dict { PACKAGE_PIN A11 IOSTANDARD LVCMOS33 } [get_ports {ov7670_data[5]}];
set_property -dict { PACKAGE_PIN F18 IOSTANDARD LVCMOS33 } [get_ports {ov7670_data[6]}];
set_property -dict { PACKAGE_PIN G17 IOSTANDARD LVCMOS33 } [get_ports {ov7670_data[7]}];
set_property -dict { PACKAGE_PIN D18 IOSTANDARD LVCMOS33 } [get_ports ov7670_href];
set_property -dict { PACKAGE_PIN E18 IOSTANDARD LVCMOS33 } [get_ports ov7670_pclk];
set_property -dict { PACKAGE_PIN D17 IOSTANDARD LVCMOS33 } [get_ports ov7670_sioc];
set_property -dict { PACKAGE_PIN C17 IOSTANDARD LVCMOS33 } [get_ports ov7670_siod];
set_property -dict { PACKAGE_PIN E17 IOSTANDARD LVCMOS33 } [get_ports ov7670_vsync];
set_property -dict { PACKAGE_PIN B11 IOSTANDARD LVCMOS33 } [get_ports ov7670_xclk];
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {ov7670_pclk_IBUF}];	

##USB UART
set_property -dict { PACKAGE_PIN A8 IOSTANDARD LVCMOS33 } [get_ports { usb_uart_rxd }]; 
set_property -dict { PACKAGE_PIN B8 IOSTANDARD LVCMOS33 } [get_ports { usb_uart_txd }];


###HDMI out  

set_property -dict { PACKAGE_PIN B17 IOSTANDARD TMDS_33 } [get_ports data_n[0]];
set_property -dict { PACKAGE_PIN B16 IOSTANDARD TMDS_33 } [get_ports data_p[0]];
set_property -dict { PACKAGE_PIN A16 IOSTANDARD TMDS_33 } [get_ports data_n[1]];
set_property -dict { PACKAGE_PIN A15 IOSTANDARD TMDS_33 } [get_ports data_p[1]];
set_property -dict { PACKAGE_PIN A9  IOSTANDARD TMDS_33 } [get_ports data_n[2]];
set_property -dict { PACKAGE_PIN A10 IOSTANDARD TMDS_33 } [get_ports data_p[2]];
set_property -dict { PACKAGE_PIN C10 IOSTANDARD TMDS_33 } [get_ports clk_n];
set_property -dict { PACKAGE_PIN C11 IOSTANDARD TMDS_33 } [get_ports clk_p];


#LCD
set_property -dict { PACKAGE_PIN C7 IOSTANDARD LVCMOS33 } [get_ports {lcd_data[4]}];
set_property -dict { PACKAGE_PIN D8 IOSTANDARD LVCMOS33 } [get_ports {lcd_data[5]}];
set_property -dict { PACKAGE_PIN D9 IOSTANDARD LVCMOS33 } [get_ports {lcd_data[6]}];
set_property -dict { PACKAGE_PIN C9 IOSTANDARD LVCMOS33 } [get_ports {lcd_data[7]}]; 
set_property -dict { PACKAGE_PIN D7 IOSTANDARD LVCMOS33 } [get_ports {lcd_en}];
set_property -dict { PACKAGE_PIN B9 IOSTANDARD LVCMOS33 } [get_ports {lcd_rs}];


#VGA
set_property -dict { PACKAGE_PIN G14 IOSTANDARD LVCMOS33 } [get_ports {VGA_HS}]; 
set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS33 } [get_ports {VGA_VS}]; 
set_property -dict { PACKAGE_PIN J18 IOSTANDARD LVCMOS33 } [get_ports {VGA_R[0]}]; 
set_property -dict { PACKAGE_PIN J15 IOSTANDARD LVCMOS33 } [get_ports {VGA_R[1]}]; 
set_property -dict { PACKAGE_PIN H14 IOSTANDARD LVCMOS33 } [get_ports {VGA_R[2]}]; 
set_property -dict { PACKAGE_PIN J17 IOSTANDARD LVCMOS33 } [get_ports {VGA_R[3]}]; 
set_property -dict { PACKAGE_PIN J13 IOSTANDARD LVCMOS33 } [get_ports {VGA_G[0]}]; 
set_property -dict { PACKAGE_PIN H15 IOSTANDARD LVCMOS33 } [get_ports {VGA_G[1]}]; 
set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS33 } [get_ports {VGA_G[2]}]; 
set_property -dict { PACKAGE_PIN H16 IOSTANDARD LVCMOS33 } [get_ports {VGA_G[3]}]; 
set_property -dict { PACKAGE_PIN N14 IOSTANDARD LVCMOS33 } [get_ports {VGA_B[0]}]; 
set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS33 } [get_ports {VGA_B[1]}]; 
set_property -dict { PACKAGE_PIN K15 IOSTANDARD LVCMOS33 } [get_ports {VGA_B[2]}]; 
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports {VGA_B[3]}];


##Buzzer
set_property -dict { PACKAGE_PIN E7 IOSTANDARD LVCMOS33 } [get_ports { buzzer}];



#AUDIO

"AUDIO_L"	V17	#U4
"AUDIO_R"	U16	#U4

#ETHERNET
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports {mdio_rtl_0_mdc}];
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports {mdio_rtl_0_mdio_io}]
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33} [get_ports {mii_rtl_0_col}];
set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS33} [get_ports {mii_rtl_0_crs}];
set_property -dict {PACKAGE_PIN M16 IOSTANDARD LVCMOS33} [get_ports {mii_rtl_0_rst_n}];
set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports {mii_rtl_0_rx_clk}];
set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports {mii_rtl_0_rx_dv}]
set_property -dict {PACKAGE_PIN R15 IOSTANDARD LVCMOS33} [get_ports {mii_rtl_0_rx_er}];
set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS33} [get_ports {mii_rtl_0_rxd[0]}];
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS33} [get_ports {mii_rtl_0_rxd[1]}];
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports {mii_rtl_0_rxd[2]}];
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports {mii_rtl_0_rxd[3]}];
set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports {mii_rtl_0_tx_clk}];
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports {mii_rtl_0_tx_en}];
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports {mii_rtl_0_txd[0]}];
set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports {mii_rtl_0_txd[1]}];
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports {mii_rtl_0_txd[2]}];
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports {mii_rtl_0_txd[3]}];
set_property -dict { PACKAGE_PIN P15    IOSTANDARD LVCMOS33 } [get_ports { eth_clk }];

#FLASH
set_property -dict { PACKAGE_PIN L13 IOSTANDARD LVCMOS33 } [get_ports { FLASH_CS }];
set_property -dict { PACKAGE_PIN E9  IOSTANDARD LVCMOS33 } [get_ports { FLASH_CLK }];
set_property -dict { PACKAGE_PIN K17 IOSTANDARD LVCMOS33 } [get_ports { FLASH_DATA0 }];
set_property -dict { PACKAGE_PIN K18 IOSTANDARD LVCMOS33 } [get_ports { FLASH_DATA1 }];
set_property -dict { PACKAGE_PIN L14 IOSTANDARD LVCMOS33 } [get_ports { FLASH_DATA2 }];
set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 } [get_ports { FLASH_DATA3 }];


#DAC
set_property -dict { PACKAGE_PIN L13 IOSTANDARD LVCMOS33 } [get_ports { FLASH_CS }];
set_property -dict { PACKAGE_PIN E9  IOSTANDARD LVCMOS33 } [get_ports { FLASH_CLK }];
set_property -dict { PACKAGE_PIN C16 IOSTANDARD LVCMOS33 } [get_ports { DAC_CS }];


#SEVEN SIG
set_property -dict { PACKAGE_PIN T11    IOSTANDARD LVCMOS33 } [get_ports { sig_a }];
set_property -dict { PACKAGE_PIN R12    IOSTANDARD LVCMOS33 } [get_ports { sig_b }];
set_property -dict { PACKAGE_PIN R13    IOSTANDARD LVCMOS33 } [get_ports { sig_c }];
set_property -dict { PACKAGE_PIN M13    IOSTANDARD LVCMOS33 } [get_ports { sig_d }];
set_property -dict { PACKAGE_PIN T14    IOSTANDARD LVCMOS33 } [get_ports { sig_e }];
set_property -dict { PACKAGE_PIN R11    IOSTANDARD LVCMOS33 } [get_ports { sig_f }];
set_property -dict { PACKAGE_PIN T13    IOSTANDARD LVCMOS33 } [get_ports { sig_g }];
set_property -dict { PACKAGE_PIN P14    IOSTANDARD LVCMOS33 } [get_ports { sig_pd }];

set_property -dict { PACKAGE_PIN V12    IOSTANDARD LVCMOS33 } [get_ports { sel_disp1 }];
set_property -dict { PACKAGE_PIN U12    IOSTANDARD LVCMOS33 } [get_ports { sel_disp2 }];
set_property -dict { PACKAGE_PIN U13    IOSTANDARD LVCMOS33 } [get_ports { sel_disp3 }];
set_property -dict { PACKAGE_PIN R10    IOSTANDARD LVCMOS33 } [get_ports { sel_disp4 }];

#SD CARD
set_property -dict { PACKAGE_PIN G13 IOSTANDARD LVCMOS33 } [get_ports { SD_CD }];
set_property -dict { PACKAGE_PIN F15 IOSTANDARD LVCMOS33 } [get_ports { SD_CLK }];
set_property -dict { PACKAGE_PIN E16 IOSTANDARD LVCMOS33 } [get_ports { SD_CMD }];
set_property -dict { PACKAGE_PIN F16 IOSTANDARD LVCMOS33 } [get_ports {SD_DATA[0]}]; 
set_property -dict { PACKAGE_PIN G16 IOSTANDARD LVCMOS33 } [get_ports {SD_DATA[1]}]; 
set_property -dict { PACKAGE_PIN D15 IOSTANDARD LVCMOS33 } [get_ports {SD_DATA[2]}]; 
set_property -dict { PACKAGE_PIN E15 IOSTANDARD LVCMOS33 } [get_ports {SD_DATA[3]}]; 

