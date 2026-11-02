module top (
    input  wire        clk100,
    input  wire [3:0]  event_in,
    output wire [16:1] LED,
    output wire        usb_uart_txd,
    output wire        esp_uart_txd
);

    wire [3:0] clean_event;
    wire [7:0] count0, count1, count2, count3;

    wire [7:0] window_count0, window_count1, window_count2, window_count3;
    wire       window_valid;
    wire [7:0] peak0, peak1, peak2, peak3;
    reg  [2:0] top_channel;
    wire alert1 = (window_count0 > 8'd3);
    wire alert2 = (window_count1 > 8'd3);
    wire alert3 = (window_count2 > 8'd3);
    wire alert4 = (window_count3 > 8'd3);

    // Highest current one-second count; ties go to the lowest channel number.
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
        .peak3         (peak3)
    );

    // LEDs continue to show the low four bits of cumulative counts.
    assign LED[4:1]   = count0[3:0];
    assign LED[8:5]   = count1[3:0];
    assign LED[12:9]  = count2[3:0];
    assign LED[16:13] = count3[3:0];

    // Send current one-second rates and peak one-second rates once per second.
    localparam integer REFRESH_COUNT = 100_000_000;

    reg [31:0] refresh_count = 0;
    reg [6:0]  char_index = 0;
    reg [7:0]  tx_data = 0;

    reg start_tx = 0;
    reg sending_message = 0;
    reg waiting_for_uart = 0;

    wire tx_busy;
    wire esp_tx_busy;

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

    always @(posedge clk100) begin
        start_tx <= 1'b0;

        if (!sending_message) begin
            if (refresh_count >= REFRESH_COUNT - 1) begin
                refresh_count    <= 0;
                char_index       <= 0;
                sending_message  <= 1'b1;
                waiting_for_uart <= 1'b0;
            end else begin
                refresh_count <= refresh_count + 1'b1;
            end
        end else if (!waiting_for_uart) begin
            case (char_index)
                // CH1:ddd PK1:ddd
                0: tx_data <= "C";
                1: tx_data <= "H";
                2: tx_data <= "1";
                3: tx_data <= ":";
                4: tx_data <= decimal_digit(window_count0, 0);
                5: tx_data <= decimal_digit(window_count0, 1);
                6: tx_data <= decimal_digit(window_count0, 2);
                7: tx_data <= " ";
                8: tx_data <= "P";
                9: tx_data <= "K";
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

                63: tx_data <= " ";
                64: tx_data <= "T";
                65: tx_data <= "O";
                66: tx_data <= "P";
                67: tx_data <= ":";
                68: tx_data <= 8'd48 + top_channel;
                69: tx_data <= " ";
                70: tx_data <= "A";
                71: tx_data <= "L";
                72: tx_data <= "E";
                73: tx_data <= "R";
                74: tx_data <= "T";
                75: tx_data <= ":";
                // Alert mask order is CH1, CH2, CH3, CH4 from left to right.
                76: tx_data <= alert1 ? "1" : "0";
                77: tx_data <= alert2 ? "1" : "0";
                78: tx_data <= alert3 ? "1" : "0";
                79: tx_data <= alert4 ? "1" : "0";
                80: tx_data <= 8'h0D;
                81: tx_data <= 8'h0A;
                default: tx_data <= " ";
            endcase

            waiting_for_uart <= 1'b1;
        end else if (!tx_busy) begin
            start_tx <= 1'b1;
            waiting_for_uart <= 1'b0;

            if (char_index == 81) begin
                char_index      <= 0;
                sending_message <= 1'b0;
            end else begin
                char_index <= char_index + 1'b1;
            end
        end
    end

    uart_tx uart_inst (
        .clk   (clk100),
        .reset (1'b0),
        .start (start_tx),
        .data  (tx_data),
        .tx    (usb_uart_txd),
        .busy  (tx_busy)
    );

    uart_tx esp_uart_inst (
        .clk   (clk100),
        .reset (1'b0),
        .start (start_tx),
        .data  (tx_data),
        .tx    (esp_uart_txd),
        .busy  (esp_tx_busy)
    );

endmodule
