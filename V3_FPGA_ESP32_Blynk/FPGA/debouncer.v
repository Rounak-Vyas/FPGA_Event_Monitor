    
module debouncer #(
    parameter integer CLK_FREQ_HZ = 100_000_000,
    parameter integer DEBOUNCE_MS = 10
)(
    input  wire clk,
    input  wire reset,
    input  wire noisy_in,
    output reg  clean_out
);

    localparam integer MAX_COUNT =
        (CLK_FREQ_HZ / 1000) * DEBOUNCE_MS;

    reg sync1;
    reg sync2;
    reg [31:0] counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sync1     <= 1'b0;
            sync2     <= 1'b0;
            clean_out <= 1'b0;
            counter   <= 32'd0;
        end
        else begin
            sync1 <= noisy_in;
            sync2 <= sync1;

            if (sync2 == clean_out) begin
                counter <= 32'd0;
            end
            else if (counter >= MAX_COUNT - 1) begin
                clean_out <= sync2;
                counter   <= 32'd0;
            end
            else begin
                counter <= counter + 1'b1;
            end
        end
    end

endmodule
