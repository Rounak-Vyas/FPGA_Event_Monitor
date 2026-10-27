
module top (
    input  wire        clk100,
    input  wire [3:0]  event_in,
    output wire [16:1] LED,
    output wire        usb_uart_txd
);

    wire [3:0] clean_event;
    wire [7:0] count0, count1, count2, count3;

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : debounce_inputs
            debouncer db (
                .clk(clk100),
                .reset(1'b0),
                .noisy_in(event_in[i]),
                .clean_out(clean_event[i])
            );
        end
    endgenerate

    event_counter counter_inst (
        .clk100(clk100),
        .reset(1'b0),
        .event_in(clean_event),
        .count0(count0),
        .count1(count1),
        .count2(count2),
        .count3(count3)
    );

    assign LED[4:1]   = count0[3:0];
    assign LED[8:5]   = count1[3:0];
    assign LED[12:9]  = count2[3:0];
    assign LED[16:13] = count3[3:0];

    reg [1:0] byte_index = 0;
    reg [31:0] wait_count = 0;
    reg start_tx = 0;
    reg [7:0] tx_data = 0;
    wire tx_busy;

    always @(posedge clk100) begin
        start_tx <= 0;

        if (!tx_busy) begin
            if (wait_count >= 10_000_000) begin
                wait_count <= 0;
                start_tx <= 1;

                case (byte_index)
                    0: tx_data <= count0;
                    1: tx_data <= count1;
                    2: tx_data <= count2;
                    3: tx_data <= count3;
                endcase

                byte_index <= byte_index + 1'b1;
            end else begin
                wait_count <= wait_count + 1'b1;
            end
        end
    end

    uart_tx uart_inst (
        .clk(clk100),
        .reset(1'b0),
        .start(start_tx),
        .data(tx_data),
        .tx(usb_uart_txd),
        .busy(tx_busy)
    );

endmodule
