
module uart_tx #(
    parameter integer CLK_FREQ  = 100_000_000,
    parameter integer BAUD_RATE = 9600
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       start,
    input  wire [7:0] data,
    output reg        tx,
    output reg        busy
);

    localparam integer DIVISOR = CLK_FREQ / BAUD_RATE;

    reg [31:0] baud_count;
    reg [3:0]  bit_index;
    reg [7:0]  data_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx         <= 1'b1;
            busy       <= 1'b0;
            baud_count <= 0;
            bit_index  <= 0;
            data_reg   <= 0;
        end else begin
            if (!busy) begin
                tx         <= 1'b1;
                baud_count <= 0;

                if (start) begin
                    data_reg   <= data;
                    bit_index  <= 0;
                    busy       <= 1'b1;
                    tx         <= 1'b0; // Start bit
                end
            end else begin
                if (baud_count == DIVISOR - 1) begin
                    baud_count <= 0;

                    if (bit_index < 8) begin
                        tx        <= data_reg[0];
                        data_reg  <= {1'b0, data_reg[7:1]};
                        bit_index <= bit_index + 1'b1;
                    end else if (bit_index == 8) begin
                        tx        <= 1'b1; // Stop bit
                        bit_index <= bit_index + 1'b1;
                    end else begin
                        tx   <= 1'b1;
                        busy <= 1'b0;
                    end
                end else begin
                    baud_count <= baud_count + 1'b1;
                end
            end
        end
    end

endmodule
