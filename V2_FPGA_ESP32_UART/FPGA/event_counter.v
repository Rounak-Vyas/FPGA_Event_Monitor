
module event_counter (
    input  wire       clk100,
    input  wire       reset,
    input  wire [3:0] event_in,

    output reg  [7:0] count0,
    output reg  [7:0] count1,
    output reg  [7:0] count2,
    output reg  [7:0] count3
);

    reg [3:0] previous;
    reg [3:0] sync_stage1;
    reg [3:0] sync_stage2;

    always @(posedge clk100 or posedge reset) begin
        if (reset) begin
            previous    <= 4'b0000;
            sync_stage1 <= 4'b0000;
            sync_stage2 <= 4'b0000;

            count0 <= 8'd0;
            count1 <= 8'd0;
            count2 <= 8'd0;
            count3 <= 8'd0;
        end
        else begin
            sync_stage1 <= event_in;
            sync_stage2 <= sync_stage1;

            previous <= sync_stage2;

            if (sync_stage2[0] && !previous[0])
                count0 <= count0 + 1'b1;

            if (sync_stage2[1] && !previous[1])
                count1 <= count1 + 1'b1;

            if (sync_stage2[2] && !previous[2])
                count2 <= count2 + 1'b1;

            if (sync_stage2[3] && !previous[3])
                count3 <= count3 + 1'b1;
        end
    end

endmodule
