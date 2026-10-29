
module top (
    input  wire        clk100,
    input  wire [3:0]  event_in,
    output wire [16:1] LED,
    output wire        usb_uart_txd,
    output wire        esp_uart_txd
);

    // 1. Event inputs and counters
    wire [3:0] clean_event;
    wire [7:0] count0, count1, count2, count3;

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
        .clk100  (clk100),
        .reset   (1'b0),
        .event_in(clean_event),
        .count0  (count0),
        .count1  (count1),
        .count2  (count2),
        .count3  (count3)
    );

    assign LED[4:1]   = count0[3:0];
    assign LED[8:5]   = count1[3:0];
    assign LED[12:9]  = count2[3:0];
    assign LED[16:13] = count3[3:0];


    // 2. UART message timing
    localparam integer REFRESH_COUNT = 50_000_000;

    reg [31:0] refresh_count = 0;
    reg [5:0]  char_index = 0;
    reg [7:0]  tx_data = 0;

    reg start_tx = 0;
    reg sending_message = 0;
    reg waiting_for_uart = 0;

    wire tx_busy;
    wire esp_tx_busy;


    // 3. Convert counter values to decimal ASCII digits
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


    // 4. Prepare each character before requesting transmission
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
                0:  tx_data <= "C";
                1:  tx_data <= "H";
                2:  tx_data <= "1";
                3:  tx_data <= ":";
                4:  tx_data <= decimal_digit(count0, 0);
                5:  tx_data <= decimal_digit(count0, 1);
                6:  tx_data <= decimal_digit(count0, 2);
                7:  tx_data <= " ";

                8:  tx_data <= "C";
                9:  tx_data <= "H";
                10: tx_data <= "2";
                11: tx_data <= ":";
                12: tx_data <= decimal_digit(count1, 0);
                13: tx_data <= decimal_digit(count1, 1);
                14: tx_data <= decimal_digit(count1, 2);
                15: tx_data <= " ";

                16: tx_data <= "C";
                17: tx_data <= "H";
                18: tx_data <= "3";
                19: tx_data <= ":";
                20: tx_data <= decimal_digit(count2, 0);
                21: tx_data <= decimal_digit(count2, 1);
                22: tx_data <= decimal_digit(count2, 2);
                23: tx_data <= " ";

                24: tx_data <= "C";
                25: tx_data <= "H";
                26: tx_data <= "4";
                27: tx_data <= ":";
                28: tx_data <= decimal_digit(count3, 0);
                29: tx_data <= decimal_digit(count3, 1);
                30: tx_data <= decimal_digit(count3, 2);

                31: tx_data <= 8'h0D;
                32: tx_data <= 8'h0A;

                default: tx_data <= " ";
            endcase

            waiting_for_uart <= 1'b1;

        end else if (!tx_busy) begin
            start_tx <= 1'b1;
            waiting_for_uart <= 1'b0;

            if (char_index == 32) begin
                char_index      <= 0;
                sending_message <= 1'b0;
            end else begin
                char_index <= char_index + 1'b1;
            end
        end
    end


    // 5. UART transmitter for the PC / PuTTY (B8)
    uart_tx uart_inst (
        .clk   (clk100),
        .reset (1'b0),
        .start (start_tx),
        .data  (tx_data),
        .tx    (usb_uart_txd),
        .busy  (tx_busy)
    );


    // 6. Separate UART transmitter for the ESP32 (C12)
    uart_tx esp_uart_inst (
        .clk   (clk100),
        .reset (1'b0),
        .start (start_tx),
        .data  (tx_data),
        .tx    (esp_uart_txd),
        .busy  (esp_tx_busy)
    );

endmodule
