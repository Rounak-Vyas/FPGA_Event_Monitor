module event_counter #(
    parameter integer CLK_FREQ_HZ = 100_000_000
) (
    input  wire       clk100,
    input  wire       reset,
    input  wire [3:0] event_in,

    // Existing cumulative counters (preserved)
    output reg  [7:0] count0,
    output reg  [7:0] count1,
    output reg  [7:0] count2,
    output reg  [7:0] count3,

    // Completed one-second event counts (held stable until next window)
    output reg  [7:0] window_count0,
    output reg  [7:0] window_count1,
    output reg  [7:0] window_count2,
    output reg  [7:0] window_count3,
    output reg        window_valid,

    // Peak event count in any completed one-second window since reset
    output reg  [7:0] peak0,
    output reg  [7:0] peak1,
    output reg  [7:0] peak2,
    output reg  [7:0] peak3
);

    localparam integer WINDOW_CYCLES = CLK_FREQ_HZ;
    localparam integer TIMER_WIDTH =
        (WINDOW_CYCLES <= 2) ? 1 : $clog2(WINDOW_CYCLES);

    reg [TIMER_WIDTH-1:0] window_timer;
    reg [3:0] previous;
    reg [3:0] sync_stage1;
    reg [3:0] sync_stage2;

    wire event_pulse0 = sync_stage2[0] && !previous[0];
    wire event_pulse1 = sync_stage2[1] && !previous[1];
    wire event_pulse2 = sync_stage2[2] && !previous[2];
    wire event_pulse3 = sync_stage2[3] && !previous[3];

    reg [7:0] active_count0;
    reg [7:0] active_count1;
    reg [7:0] active_count2;
    reg [7:0] active_count3;

    // Include an event detected on the exact window-boundary clock.
    wire [7:0] completed_count0 = active_count0 + event_pulse0;
    wire [7:0] completed_count1 = active_count1 + event_pulse1;
    wire [7:0] completed_count2 = active_count2 + event_pulse2;
    wire [7:0] completed_count3 = active_count3 + event_pulse3;

    always @(posedge clk100 or posedge reset) begin
        if (reset) begin
            previous       <= 4'b0000;
            sync_stage1    <= 4'b0000;
            sync_stage2    <= 4'b0000;
            count0         <= 8'd0;
            count1         <= 8'd0;
            count2         <= 8'd0;
            count3         <= 8'd0;
            window_timer   <= {TIMER_WIDTH{1'b0}};
            active_count0  <= 8'd0;
            active_count1  <= 8'd0;
            active_count2  <= 8'd0;
            active_count3  <= 8'd0;
            window_count0  <= 8'd0;
            window_count1  <= 8'd0;
            window_count2  <= 8'd0;
            window_count3  <= 8'd0;
            window_valid   <= 1'b0;
            peak0          <= 8'd0;
            peak1          <= 8'd0;
            peak2          <= 8'd0;
            peak3          <= 8'd0;
        end else begin
            sync_stage1 <= event_in;
            sync_stage2 <= sync_stage1;
            previous    <= sync_stage2;

            // Preserve the original cumulative counters.
            if (event_pulse0) count0 <= count0 + 1'b1;
            if (event_pulse1) count1 <= count1 + 1'b1;
            if (event_pulse2) count2 <= count2 + 1'b1;
            if (event_pulse3) count3 <= count3 + 1'b1;

            window_valid <= 1'b0;

            if (window_timer >= WINDOW_CYCLES - 1) begin
                window_timer <= {TIMER_WIDTH{1'b0}};

                // Publish the just-completed one-second window.
                window_count0 <= completed_count0;
                window_count1 <= completed_count1;
                window_count2 <= completed_count2;
                window_count3 <= completed_count3;
                window_valid  <= 1'b1;

                // Compare against the same completed-window counts.
                if (completed_count0 > peak0) peak0 <= completed_count0;
                if (completed_count1 > peak1) peak1 <= completed_count1;
                if (completed_count2 > peak2) peak2 <= completed_count2;
                if (completed_count3 > peak3) peak3 <= completed_count3;

                active_count0 <= 8'd0;
                active_count1 <= 8'd0;
                active_count2 <= 8'd0;
                active_count3 <= 8'd0;
            end else begin
                window_timer <= window_timer + 1'b1;
                if (event_pulse0) active_count0 <= active_count0 + 1'b1;
                if (event_pulse1) active_count1 <= active_count1 + 1'b1;
                if (event_pulse2) active_count2 <= active_count2 + 1'b1;
                if (event_pulse3) active_count3 <= active_count3 + 1'b1;
            end
        end
    end
endmodule
