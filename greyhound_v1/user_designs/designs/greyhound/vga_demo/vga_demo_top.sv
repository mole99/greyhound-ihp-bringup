// SPDX-FileCopyrightText: © 2024 Leo Moser <leo.moser@pm.me>
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module vga_demo_top (
    input  logic        clk_i,
    input  logic        rst_ni,
    
    // VGA signals
    output logic [5:0] rrggbb_o,
    output logic       hsync_o,
    output logic       vsync_o,
    output logic       next_vertical_o,
    output logic       next_frame_o
);
    /*
        VGA 640x480 @ 60 Hz
        clock = 25.175 MHz
    */

    localparam WIDTH    = 640;
    localparam HEIGHT   = 480;
    
    localparam HFRONT   = 16;
    localparam HSYNC    = 96;
    localparam HBACK    = 48;

    localparam VFRONT   = 10;
    localparam VSYNC    = 2;
    localparam VBACK    = 33;
    
    localparam HTOTAL = WIDTH + HFRONT + HSYNC + HBACK;
    localparam VTOTAL = HEIGHT + VFRONT + VSYNC + VBACK;

    /* Horizontal and Vertical Timing */
    
    logic signed [$clog2(HTOTAL) : 0] counter_h;
    logic signed [$clog2(VTOTAL) : 0] counter_v;
    
    logic hblank;
    logic vblank;
    logic hsync;
    logic vsync;
    logic next_vertical;
    logic next_frame;
     
    // Horizontal timing
    timing #(
        .RESOLUTION     (WIDTH),
        .FRONT_PORCH    (HFRONT),
        .SYNC_PULSE     (HSYNC),
        .BACK_PORCH     (HBACK),
        .TOTAL          (HTOTAL),
        .POLARITY       (1'b0)
    ) timing_hor (
        .clk        (clk_i),
        .enable     (1'b1),
        .reset_n    (rst_ni),
        .inc_1_or_4 (1'b0),
        .sync       (hsync),
        .blank      (hblank),
        .next       (next_vertical),
        .counter    (counter_h)
    );

    // Vertical timing
    timing #(
        .RESOLUTION     (HEIGHT),
        .FRONT_PORCH    (VFRONT),
        .SYNC_PULSE     (VSYNC),
        .BACK_PORCH     (VBACK),
        .TOTAL          (VTOTAL),
        .POLARITY       (1'b0)
    ) timing_ver (
        .clk        (clk_i),
        .enable     (next_vertical),
        .reset_n    (rst_ni),
        .inc_1_or_4 (1'b0),
        .sync       (vsync),
        .blank      (vblank),
        .next       (next_frame),
        .counter    (counter_v)
    );
    
    logic [11:0] cur_time;
    
    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            cur_time <= '0;
        end else begin
            if (next_frame) begin
                cur_time <= cur_time + 1;
            end
        end
    end
    
    logic [7:0] sine_id;
    always_ff @(posedge clk_i) begin
        sine_id <= counter_v + counter_h + cur_time[9:2];
    end
    
    // Sine ROM
    logic [7:0] sine_data;
    sine_table #(
        .ROM_DEPTH  (64),  // number of entries in sine ROM for 0° to 90°
        .ROM_WIDTH  (8),   // width of sine ROM data in bits
        .ROM_FILE   ("sine_table_64x8.mem")   // sine table file to populate ROM
        ) sine_table_i (
        .id   (sine_id),  // table ID to lookup
        .data (sine_data)  // answer (fixed-point)
    );
    
    logic [7:0] sine_data_d;
    logic [5:0] rgb_0, rgb_1, rgb_2, rgb_3;
    always_ff @(posedge clk_i) begin
          sine_data_d <= sine_data;
          rgb_0 = sine_data_d[7:2];
          rgb_1 = counter_v ^ counter_h + sine_data_d;
          rgb_2 = counter_v + counter_h + sine_data_d;
          rgb_3 = counter_v * counter_h + sine_data_d;
    end
    
    // Compose the final colore
    logic [5:0] rgb_o;
    always_comb begin
        case (cur_time[10:9])
          2'b00: rgb_o = rgb_0;
          2'b01: rgb_o = rgb_1;
          2'b10: rgb_o = rgb_2;
          2'b11: rgb_o = rgb_3;
        endcase
    end

    // Register color output
    logic [5:0] rgb_d;
    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            rgb_d <= '0;
        end else begin
            rgb_d <= rgb_o;
            
            // Blanking intervall
            if (hblank || vblank) begin
                rgb_d <= '0;
            end
        end
    end
    
    assign rrggbb_o = rgb_d;
    
    // Delay output signals one cycle
    // to account for rgb_d
    always_ff @(posedge clk_i) begin
        hsync_o         <= hsync;
        vsync_o         <= vsync;
        next_vertical_o <= next_vertical;
        next_frame_o    <= next_frame;
    end

endmodule
