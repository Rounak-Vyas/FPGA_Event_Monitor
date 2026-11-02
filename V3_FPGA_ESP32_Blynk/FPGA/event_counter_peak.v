module event_counter #(
    parameter integer CLK_FREQ_HZ = 100_000_000
) (
    input  wire       clk100,
    input  wire       reset,
    input  wire [3:0] event_in,

    // 8-bit cumulative counters: naturally wrap from 255 to 0
    output reg  [7:0] count0,
    output reg  [7:0] count1,
    output reg  [7:0] count2,
    output reg  [7:0] count3,

    // Completed one-second counts
    output reg  [7:0] window_count0,
    output reg  [7:0] window_count1,
    output reg  [7:0] window_count2,
    output reg  [7:0] window_count3,
    output reg        window_valid,

    // Peak one-second counts
    output reg  [7:0] peak0,
    output reg  [7:0] peak1,
    output reg  [7:0] peak2,
    output reg  [7:0] peak3,

    // Completed 10-second counts
    output reg [15:0] ten_sec_count0,
    output reg [15:0] ten_sec_count1,
    output reg [15:0] ten_sec_count2,
    output reg [15:0] ten_sec_count3,
    output reg        ten_sec_valid
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

    // One-second active counters
    reg [7:0] active_count0;
    reg [7:0] active_count1;
    reg [7:0] active_count2;
    reg [7:0] active_count3;

    // 10-second active accumulators
    reg [15:0] ten_active0;
    reg [15:0] ten_active1;
    reg [15:0] ten_active2;
    reg [15:0] ten_active3;

    // Include events detected on the exact one-second boundary.
    wire [7:0] completed_count0 = active_count0 + event_pulse0;
    wire [7:0] completed_count1 = active_count1 + event_pulse1;
    wire [7:0] completed_count2 = active_count2 + event_pulse2;
    wire [7:0] completed_count3 = active_count3 + event_pulse3;

    // Include the boundary event in the 10-second accumulation too.
    wire [15:0] completed_ten0 = ten_active0 + event_pulse0;
    wire [15:0] completed_ten1 = ten_active1 + event_pulse1;
    wire [15:0] completed_ten2 = ten_active2 + event_pulse2;
    wire [15:0] completed_ten3 = ten_active3 + event_pulse3;

    // Counts completed one-second windows: 0 through 9.
    reg [3:0] seconds_in_interval;

    always @(posedge clk100 or posedge reset) begin
        if (reset) begin
            previous       <= 4'b0000;
            sync_stage1    <= 4'b0000;
            sync_stage2    <= 4'b0000;

            count0 <= 0;
            count1 <= 0;
            count2 <= 0;
            count3 <= 0;

            window_timer <= 0;

            active_count0 <= 0;
            active_count1 <= 0;
            active_count2 <= 0;
            active_count3 <= 0;

            window_count0 <= 0;
            window_count1 <= 0;
            window_count2 <= 0;
            window_count3 <= 0;

            window_valid <= 0;

            peak0 <= 0;
            peak1 <= 0;
            peak2 <= 0;
            peak3 <= 0;

            ten_active0 <= 0;
            ten_active1 <= 0;
            ten_active2 <= 0;
            ten_active3 <= 0;

            ten_sec_count0 <= 0;
            ten_sec_count1 <= 0;
            ten_sec_count2 <= 0;
            ten_sec_count3 <= 0;

            ten_sec_valid <= 0;

            seconds_in_interval <= 0;
        end
        else begin
            sync_stage1 <= event_in;
            sync_stage2 <= sync_stage1;
            previous    <= sync_stage2;

            // Existing 8-bit cumulative counters.
            if (event_pulse0) count0 <= count0 + 1'b1;
            if (event_pulse1) count1 <= count1 + 1'b1;
            if (event_pulse2) count2 <= count2 + 1'b1;
            if (event_pulse3) count3 <= count3 + 1'b1;

            window_valid  <= 1'b0;
            ten_sec_valid <= 1'b0;

            if (window_timer >= WINDOW_CYCLES - 1) begin

                window_timer <= 0;

                // Publish completed one-second counts.
                window_count0 <= completed_count0;
                window_count1 <= completed_count1;
                window_count2 <= completed_count2;
                window_count3 <= completed_count3;

                window_valid <= 1'b1;

                // Update one-second peaks.
                if (completed_count0 > peak0)
                    peak0 <= completed_count0;

                if (completed_count1 > peak1)
                    peak1 <= completed_count1;

                if (completed_count2 > peak2)
                    peak2 <= completed_count2;

                if (completed_count3 > peak3)
                    peak3 <= completed_count3;

                // Reset one-second active counters.
                active_count0 <= 0;
                active_count1 <= 0;
                active_count2 <= 0;
                active_count3 <= 0;

                // 10-second aggregation.
                if (seconds_in_interval == 4'd9) begin

                    // Publish completed 10-second totals.
                    ten_sec_count0 <= completed_ten0;
                    ten_sec_count1 <= completed_ten1;
                    ten_sec_count2 <= completed_ten2;
                    ten_sec_count3 <= completed_ten3;

                    ten_sec_valid <= 1'b1;

                    // Start the next 10-second interval.
                    ten_active0 <= 0;
                    ten_active1 <= 0;
                    ten_active2 <= 0;
                    ten_active3 <= 0;

                    seconds_in_interval <= 0;
                end
                else begin
                    ten_active0 <= completed_ten0;
                    ten_active1 <= completed_ten1;
                    ten_active2 <= completed_ten2;
                    ten_active3 <= completed_ten3;

                    seconds_in_interval <= seconds_in_interval + 1'b1;
                end
            end
            else begin
                window_timer <= window_timer + 1'b1;

                if (event_pulse0)
                    active_count0 <= active_count0 + 1'b1;

                if (event_pulse1)
                    active_count1 <= active_count1 + 1'b1;

                if (event_pulse2)
                    active_count2 <= active_count2 + 1'b1;

                if (event_pulse3)
                    active_count3 <= active_count3 + 1'b1;

                // Accumulate every event into the 10-second counters.
                if (event_pulse0)
                    ten_active0 <= ten_active0 + 1'b1;

                if (event_pulse1)
                    ten_active1 <= ten_active1 + 1'b1;

                if (event_pulse2)
                    ten_active2 <= ten_active2 + 1'b1;

                if (event_pulse3)
                    ten_active3 <= ten_active3 + 1'b1;
            end
        end
    end

endmodule