module top (
    input  wire        clk100,
    input  wire [3:0]  event_in,
    output wire [16:1] LED,
    output wire        usb_uart_txd,
    output wire        esp_uart_txd
);

    wire [3:0] clean_event;

    wire [7:0] count0, count1, count2, count3;

    wire [7:0] window_count0, window_count1;
    wire [7:0] window_count2, window_count3;
    wire       window_valid;

    wire [7:0] peak0, peak1, peak2, peak3;

    // New 10-second interval outputs
    wire [15:0] ten_sec_count0;
    wire [15:0] ten_sec_count1;
    wire [15:0] ten_sec_count2;
    wire [15:0] ten_sec_count3;
    wire        ten_sec_valid;

    reg [2:0] top_channel;

    wire alert1 = (window_count0 > 8'd3);
    wire alert2 = (window_count1 > 8'd3);
    wire alert3 = (window_count2 > 8'd3);
    wire alert4 = (window_count3 > 8'd3);

    // Highest current one-second count.
    // Ties go to the lowest channel number.
    always @* begin
        if ((window_count0 == 0) && (window_count1 == 0) &&
            (window_count2 == 0) && (window_count3 == 0))
            top_channel = 3'd0;
        else if ((window_count0 >= window_count1) &&
                 (window_count0 >= window_count2) &&
                 (window_count0 >= window_count3))
            top_channel = 3'd1;
        else if ((window_count1 >= window_count2) &&
                 (window_count1 >= window_count3))
            top_channel = 3'd2;
        else if (window_count2 >= window_count3)
            top_channel = 3'd3;
        else
            top_channel = 3'd4;
    end

    // Input debouncing
    genvar i;

    generate
        for (i = 0; i < 4; i = i + 1) begin : debounce_inputs

            debouncer db (
                .clk       (clk100),
                .reset     (1'b0),
                .noisy_in  (event_in[i]),
                .clean_out (clean_event[i])
            );

        end
    endgenerate

    // Event counter
    event_counter counter_inst (
        .clk100        (clk100),
        .reset         (1'b0),
        .event_in      (clean_event),

        .count0        (count0),
        .count1        (count1),
        .count2        (count2),
        .count3        (count3),

        .window_count0 (window_count0),
        .window_count1 (window_count1),
        .window_count2 (window_count2),
        .window_count3 (window_count3),
        .window_valid  (window_valid),

        .peak0         (peak0),
        .peak1         (peak1),
        .peak2         (peak2),
        .peak3         (peak3),

        .ten_sec_count0 (ten_sec_count0),
        .ten_sec_count1 (ten_sec_count1),
        .ten_sec_count2 (ten_sec_count2),
        .ten_sec_count3 (ten_sec_count3),
        .ten_sec_valid  (ten_sec_valid)
    );

    // Existing LED display
    assign LED[4:1]   = count0[3:0];
    assign LED[8:5]   = count1[3:0];
    assign LED[12:9]  = count2[3:0];
    assign LED[16:13] = count3[3:0];

    // UART message refresh interval
    localparam integer REFRESH_COUNT = 100_000_000;

    reg [31:0] refresh_count = 0;
    reg [7:0]  char_index = 0;
    reg [7:0]  tx_data = 0;

    reg start_tx = 0;
    reg sending_message = 0;
    reg waiting_for_uart = 0;

    wire tx_busy;
    wire esp_tx_busy;

    // Latch completed 10-second values.
    // These remain stable while the UART message is transmitted.
    reg [15:0] tx_ten0 = 0;
    reg [15:0] tx_ten1 = 0;
    reg [15:0] tx_ten2 = 0;
    reg [15:0] tx_ten3 = 0;

    // Remember that a new 10-second result has arrived.
    reg ten_sec_fresh = 0;
    reg message_ten_sec_valid = 0;

    // Capture completed 10-second results.
    always @(posedge clk100) begin

        if (ten_sec_valid) begin
            tx_ten0 <= ten_sec_count0;
            tx_ten1 <= ten_sec_count1;
            tx_ten2 <= ten_sec_count2;
            tx_ten3 <= ten_sec_count3;

            ten_sec_fresh <= 1'b1;
        end

        // Consume the freshness flag when starting a message.
        if (!sending_message &&
            refresh_count >= REFRESH_COUNT - 1) begin

            message_ten_sec_valid <= ten_sec_fresh;

            if (ten_sec_fresh)
                ten_sec_fresh <= 1'b0;
        end
    end

    // Convert an 8-bit number into a decimal digit.
    function [7:0] decimal_digit;
        input [7:0] value;
        input [1:0] digit;

        begin
            case (digit)
                0: decimal_digit = 8'd48 + (value / 100);
                1: decimal_digit = 8'd48 + ((value % 100) / 10);
                2: decimal_digit = 8'd48 + (value % 10);
                default: decimal_digit = 8'd48;
            endcase
        end
    endfunction

    // Convert a 16-bit number into a 5-digit decimal value.
    function [7:0] decimal_digit_16;
        input [15:0] value;
        input [2:0] digit;

        begin
            case (digit)
                0: decimal_digit_16 = 8'd48 + (value / 10000);
                1: decimal_digit_16 = 8'd48 + ((value % 10000) / 1000);
                2: decimal_digit_16 = 8'd48 + ((value % 1000) / 100);
                3: decimal_digit_16 = 8'd48 + ((value % 100) / 10);
                4: decimal_digit_16 = 8'd48 + (value % 10);
                default: decimal_digit_16 = 8'd48;
            endcase
        end
    endfunction

    // UART message transmission
    always @(posedge clk100) begin

        start_tx <= 1'b0;

        if (!sending_message) begin

            if (refresh_count >= REFRESH_COUNT - 1) begin
                refresh_count    <= 0;
                char_index       <= 0;
                sending_message  <= 1'b1;
                waiting_for_uart <= 1'b0;
            end
            else begin
                refresh_count <= refresh_count + 1'b1;
            end

        end
        else if (!waiting_for_uart) begin

            case (char_index)

                // CH1:ddd PK1:ddd
                0:  tx_data <= "C";
                1:  tx_data <= "H";
                2:  tx_data <= "1";
                3:  tx_data <= ":";
                4:  tx_data <= decimal_digit(window_count0, 0);
                5:  tx_data <= decimal_digit(window_count0, 1);
                6:  tx_data <= decimal_digit(window_count0, 2);
                7:  tx_data <= " ";
                8:  tx_data <= "P";
                9:  tx_data <= "K";
                10: tx_data <= "1";
                11: tx_data <= ":";
                12: tx_data <= decimal_digit(peak0, 0);
                13: tx_data <= decimal_digit(peak0, 1);
                14: tx_data <= decimal_digit(peak0, 2);
                15: tx_data <= " ";

                // CH2:ddd PK2:ddd
                16: tx_data <= "C";
                17: tx_data <= "H";
                18: tx_data <= "2";
                19: tx_data <= ":";
                20: tx_data <= decimal_digit(window_count1, 0);
                21: tx_data <= decimal_digit(window_count1, 1);
                22: tx_data <= decimal_digit(window_count1, 2);
                23: tx_data <= " ";
                24: tx_data <= "P";
                25: tx_data <= "K";
                26: tx_data <= "2";
                27: tx_data <= ":";
                28: tx_data <= decimal_digit(peak1, 0);
                29: tx_data <= decimal_digit(peak1, 1);
                30: tx_data <= decimal_digit(peak1, 2);
                31: tx_data <= " ";

                // CH3:ddd PK3:ddd
                32: tx_data <= "C";
                33: tx_data <= "H";
                34: tx_data <= "3";
                35: tx_data <= ":";
                36: tx_data <= decimal_digit(window_count2, 0);
                37: tx_data <= decimal_digit(window_count2, 1);
                38: tx_data <= decimal_digit(window_count2, 2);
                39: tx_data <= " ";
                40: tx_data <= "P";
                41: tx_data <= "K";
                42: tx_data <= "3";
                43: tx_data <= ":";
                44: tx_data <= decimal_digit(peak2, 0);
                45: tx_data <= decimal_digit(peak2, 1);
                46: tx_data <= decimal_digit(peak2, 2);
                47: tx_data <= " ";

                // CH4:ddd PK4:ddd
                48: tx_data <= "C";
                49: tx_data <= "H";
                50: tx_data <= "4";
                51: tx_data <= ":";
                52: tx_data <= decimal_digit(window_count3, 0);
                53: tx_data <= decimal_digit(window_count3, 1);
                54: tx_data <= decimal_digit(window_count3, 2);
                55: tx_data <= " ";
                56: tx_data <= "P";
                57: tx_data <= "K";
                58: tx_data <= "4";
                59: tx_data <= ":";
                60: tx_data <= decimal_digit(peak3, 0);
                61: tx_data <= decimal_digit(peak3, 1);
                62: tx_data <= decimal_digit(peak3, 2);

                // TOP
                63: tx_data <= " ";
                64: tx_data <= "T";
                65: tx_data <= "O";
                66: tx_data <= "P";
                67: tx_data <= ":";
                68: tx_data <= 8'd48 + top_channel;

                // ALERT
                69: tx_data <= " ";
                70: tx_data <= "A";
                71: tx_data <= "L";
                72: tx_data <= "E";
                73: tx_data <= "R";
                74: tx_data <= "T";
                75: tx_data <= ":";
                76: tx_data <= alert1 ? "1" : "0";
                77: tx_data <= alert2 ? "1" : "0";
                78: tx_data <= alert3 ? "1" : "0";
                79: tx_data <= alert4 ? "1" : "0";

                // Cumulative channel totals (8-bit, wrap at 255)
                // TOT1:ddd
                80: tx_data <= " ";
                81: tx_data <= "T";
                82: tx_data <= "O";
                83: tx_data <= "T";
                84: tx_data <= "1";
                85: tx_data <= ":";
                86: tx_data <= decimal_digit(count0, 0);
                87: tx_data <= decimal_digit(count0, 1);
                88: tx_data <= decimal_digit(count0, 2);

                // TOT2:ddd
                89: tx_data <= " ";
                90: tx_data <= "T";
                91: tx_data <= "O";
                92: tx_data <= "T";
                93: tx_data <= "2";
                94: tx_data <= ":";
                95: tx_data <= decimal_digit(count1, 0);
                96: tx_data <= decimal_digit(count1, 1);
                97: tx_data <= decimal_digit(count1, 2);

                // TOT3:ddd
                98:  tx_data <= " ";
                99:  tx_data <= "T";
                100: tx_data <= "O";
                101: tx_data <= "T";
                102: tx_data <= "3";
                103: tx_data <= ":";
                104: tx_data <= decimal_digit(count2, 0);
                105: tx_data <= decimal_digit(count2, 1);
                106: tx_data <= decimal_digit(count2, 2);

                // TOT4:ddd
                107: tx_data <= " ";
                108: tx_data <= "T";
                109: tx_data <= "O";
                110: tx_data <= "T";
                111: tx_data <= "4";
                112: tx_data <= ":";
                113: tx_data <= decimal_digit(count3, 0);
                114: tx_data <= decimal_digit(count3, 1);
                115: tx_data <= decimal_digit(count3, 2);

                // T10V freshness flag
                116: tx_data <= " ";
                117: tx_data <= "T";
                118: tx_data <= "1";
                119: tx_data <= "0";
                120: tx_data <= "V";
                121: tx_data <= ":";
                122: tx_data <= message_ten_sec_valid ? "1" : "0";

                // 10-second channel totals
                123: tx_data <= " ";
                124: tx_data <= "T";
                125: tx_data <= "1";
                126: tx_data <= "0";
                127: tx_data <= ":";

                // Channel 1 total
                128: tx_data <= decimal_digit_16(tx_ten0, 0);
                129: tx_data <= decimal_digit_16(tx_ten0, 1);
                130: tx_data <= decimal_digit_16(tx_ten0, 2);
                131: tx_data <= decimal_digit_16(tx_ten0, 3);
                132: tx_data <= decimal_digit_16(tx_ten0, 4);

                133: tx_data <= ",";

                // Channel 2 total
                134: tx_data <= decimal_digit_16(tx_ten1, 0);
                135: tx_data <= decimal_digit_16(tx_ten1, 1);
                136: tx_data <= decimal_digit_16(tx_ten1, 2);
                137: tx_data <= decimal_digit_16(tx_ten1, 3);
                138: tx_data <= decimal_digit_16(tx_ten1, 4);

                139: tx_data <= ",";

                // Channel 3 total
                140: tx_data <= decimal_digit_16(tx_ten2, 0);
                141: tx_data <= decimal_digit_16(tx_ten2, 1);
                142: tx_data <= decimal_digit_16(tx_ten2, 2);
                143: tx_data <= decimal_digit_16(tx_ten2, 3);
                144: tx_data <= decimal_digit_16(tx_ten2, 4);

                145: tx_data <= ",";

                // Channel 4 total
                146: tx_data <= decimal_digit_16(tx_ten3, 0);
                147: tx_data <= decimal_digit_16(tx_ten3, 1);
                148: tx_data <= decimal_digit_16(tx_ten3, 2);
                149: tx_data <= decimal_digit_16(tx_ten3, 3);
                150: tx_data <= decimal_digit_16(tx_ten3, 4);

                // End of message
                151: tx_data <= 8'h0D;
                152: tx_data <= 8'h0A;

                default: tx_data <= " ";

            endcase

            waiting_for_uart <= 1'b1;

        end
        else if (!tx_busy) begin

            start_tx <= 1'b1;
            waiting_for_uart <= 1'b0;

            if (char_index == 152) begin
                char_index      <= 0;
                sending_message <= 1'b0;
            end
            else begin
                char_index <= char_index + 1'b1;
            end

        end
    end

    // USB UART
    uart_tx uart_inst (
        .clk   (clk100),
        .reset (1'b0),
        .start (start_tx),
        .data  (tx_data),
        .tx    (usb_uart_txd),
        .busy  (tx_busy)
    );

    // ESP32 UART
    uart_tx esp_uart_inst (
        .clk   (clk100),
        .reset (1'b0),
        .start (start_tx),
        .data  (tx_data),
        .tx    (esp_uart_txd),
        .busy  (esp_tx_busy)
    );

endmodule