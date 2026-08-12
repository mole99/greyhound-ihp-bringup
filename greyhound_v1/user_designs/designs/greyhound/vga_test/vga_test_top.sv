// SPDX-FileCopyrightText: © 2024 Leo Moser <leo.moser@pm.me>
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module vga_test_top (
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
        SVGA Signal 800 x 600 @ 60 Hz
        with horizontal timing divided by 4
        clock = 10.0 MHz
    */

    localparam WIDTH    = 800;
    localparam HEIGHT   = 600;
    
    localparam HFRONT   = 40/4;
    localparam HSYNC    = 128/4;
    localparam HBACK    = 88/4;
    localparam HPOLARITY = 1'b1;

    localparam VFRONT   = 1;
    localparam VSYNC    = 4;
    localparam VBACK    = 23;
    localparam VPOLARITY = 1'b1;

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
        .POLARITY       (HPOLARITY)
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
        .POLARITY       (VPOLARITY)
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

    // Register color output
    logic [5:0] rgb_d;
    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            rgb_d <= '0;
        end else begin
            rgb_d <= (counter_v/4) ^ counter_h ? '1 : '0;
            
            // Blanking intervall
            if (hblank || vblank) begin
                rgb_d <= '0;
            end
        end
    end
    
    
    /*assign rrggbb_o = rgb_d;
    
    // Delay output signals one cycle
    // to account for rgb_d
    always_ff @(posedge clk_i) begin
        hsync_o         <= hsync;
        vsync_o         <= vsync;
        next_vertical_o <= next_vertical;
        next_frame_o    <= next_frame;
    end*/
    
    
    // display sync signals and coordinates
    localparam CORDW = 12;  // screen coordinate width in bits
    logic [CORDW-1:0] sx, sy;
    //logic hsync, vsync, de;
    logic de;
    simple_480p display_inst (
        .clk_pix (clk_i),
        .rst_pix(!rst_ni),  // wait for clock lock
        .sx,
        .sy,
        .hsync,
        .vsync,
        .de
    );

    // Delay output signals one cycle
    // to account for rgb_d
    always_ff @(posedge clk_i) begin
        hsync_o         <= hsync;
        vsync_o         <= vsync;
        rrggbb_o <= (de) ? (sx[0] ^ sy[2] ? 6'b110011 : 6'b001100) : '0;
    end

endmodule
