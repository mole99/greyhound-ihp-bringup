// SPDX-FileCopyrightText: © 2026 Leo Moser <leo.moser@pm.me>, © 2022 Will Green & Ben Blundell
// SPDX-License-Identifier: MIT

`default_nettype none

module greyhound_sine_core (
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
    
    logic [10:0] cur_time;
    
    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            cur_time <= '0;
        end else begin
            if (next_frame) begin
                cur_time <= cur_time + 1;
            end
        end
    end

    // Sine table
    logic [7:0] sine_id;
    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            sine_id <= '0;
        end else begin
            sine_id <= counter_h[10:3] + cur_time[7:0];
        end
    end
    
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
    always_ff @(posedge clk_i) begin
        sine_data_d <= sine_data;
    end

    // Font parameters
    localparam GLYPH_WIDTH  =   8;
    localparam GLYPH_SPACE  =   2;  // horizontal spacing
    localparam GLYPH_HEIGHT =  16;
    localparam GLYPH_COUNT  =  64;
    localparam GLYPH_OFFSET =  32;  // starts at U+0020
    localparam FONT_LSB = 0;
    localparam FONT_FILE = "font-8x16.mem";

    // EXPERIMENTAL!
    localparam MULTIPLY_WIDTH=1;
    localparam MULTIPLY_HEIGHT=2;

    // Message ROM
    logic [7:0] message [16];
    initial begin
      message[0] = " ";
      message[1] = " ";
      message[2] = "G";
      message[3] = "R";
      message[4] = "E";
      message[5] = "Y";
      message[6] = "H";
      message[7] = "O";
      message[8] = "U";
      message[9] = "N";
      message[10] = "D";
      message[11] = "!";
      message[12] = " ";
      message[13] = " ";
      message[14] = " ";
      message[15] = " ";
    end
    
    logic [3:0] char_index, char_index_d;
    always_ff @(posedge clk_i) begin
        char_index <= counter_h  / GLYPH_WIDTH / MULTIPLY_WIDTH;
        char_index_d <= char_index;
    end
    
    logic [7:0] cur_char;
    always_ff @(posedge clk_i) begin
        cur_char <= message[char_index_d];
    end

    // font glyph ROM - line of glyph pixels at each location
    localparam DEPTH = GLYPH_HEIGHT * GLYPH_COUNT;
    logic [$clog2(DEPTH)-1:0] rom_addr_d, rom_addr_dd;
    logic [GLYPH_WIDTH-1:0] rom_data;
    rom_sync #(
        .WIDTH(GLYPH_WIDTH),
        .DEPTH(GLYPH_HEIGHT * GLYPH_COUNT),
        .INIT_F(FONT_FILE)
    ) glyph_rom (
        .clk (clk_i),
        .addr(rom_addr_d),
        .data(rom_data)
    );

    // Indexing logic
    logic signed [$clog2(VTOTAL) : 0] offset;

    always_ff @(posedge clk_i) begin
        offset <= (counter_v - sine_data_d) / MULTIPLY_HEIGHT;
    end

    always_ff @(posedge clk_i) begin
        rom_addr_d <= (cur_char - GLYPH_OFFSET) * GLYPH_HEIGHT + offset[$clog2(GLYPH_HEIGHT)-1:0];
    end

    logic [GLYPH_WIDTH-1:0] rom_data_flipped;
    generate for(genvar i=0; i<GLYPH_WIDTH; i++) assign rom_data_flipped[i]=rom_data[GLYPH_WIDTH-i-1]; endgenerate 
    
    // Make sure only one line of text is visible
    logic visible, visible_d, visible_dd;
    always_ff @(posedge clk_i) begin
        visible <= counter_v > ((GLYPH_HEIGHT*MULTIPLY_HEIGHT) * (6/MULTIPLY_HEIGHT) + sine_data_d[7:0])
                && counter_v < ((GLYPH_HEIGHT*MULTIPLY_HEIGHT) * (6/MULTIPLY_HEIGHT+1) + sine_data_d[7:0]);
        visible_d <= visible;
        visible_dd <= visible_d;
    end
    
    // Delay to match other signals
    logic signed [$clog2(HTOTAL) : 0] counter_h_delayed;
    always_ff @(posedge clk_i) begin
        counter_h_delayed <= counter_h - 4;
    end
    
    logic counter_h_delayed_ge_zero;
    always_ff @(posedge clk_i) begin
        counter_h_delayed_ge_zero <= (counter_h - 4) >= 0;
    end
    
    // Compose the final color data    
    logic [5:0] rgb_o;
    assign rgb_o = visible_dd ? (rom_data_flipped[counter_h_delayed / MULTIPLY_WIDTH] && counter_h_delayed_ge_zero ? 6'h3F : 6'hb100101) : 6'b110101;

    // Output color
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
