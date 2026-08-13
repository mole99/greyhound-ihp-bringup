// SPDX-FileCopyrightText: © 2024 Leo Moser <leo.moser@pm.me>
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module big_sram (
    input  logic        clk_i,
    input  logic [12:0] addr_i,
    input  logic [3:0]  be_i,   // byte enable
    input  logic [31:0] din_i,
    input  logic        wen_i,
    input  logic        men_i,
    input  logic        ren_i,
    
    output logic [31:0] dout_o,
);

    // SRAM
    parameter NUM_SRAM = 7;
    logic [32-1:0] dout_srams [NUM_SRAM];

    logic [2:0] select_sram, select_sram_d;
    assign select_sram = addr_i[12:10];
    
    generate
        for (genvar i=0; i<NUM_SRAM; i++) begin : gen
        
            // note: implicit clock
            IHP_SRAM_1024x32_wrapper sram (
                .ADDR   (addr_i[9:0]),
                .BM     ({{8{be_i[3]}}, {8{be_i[2]}}, {8{be_i[1]}}, {8{be_i[0]}}}),
                .DIN    (din_i),
                .WEN    (wen_i),
                .MEN    (select_sram == i && men_i),
                .REN    (ren_i),
                .DOUT   (dout_srams[i])
            );
        end
    endgenerate
    
    always_ff @(posedge clk_i) begin
        select_sram_d <= select_sram;
    end
    
    always_comb begin
        dout_o = 0;
        if (select_sram_d < NUM_SRAM) begin
            dout_o = dout_srams[select_sram_d];
        end
    end

endmodule


module vga_framebuffer_periph_core (
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


    logic [12:0] framebuffer_addr;
    logic [1:0] offset, offset_d;
    logic [7:0] pixel_data;
    
    // power of two
    parameter PIXEL_SIZE = 2;
    
    always_ff @(posedge clk_i) begin
          // One word has 4 bytes, i.e. 4 pixel    
          framebuffer_addr <= (counter_v>>PIXEL_SIZE) * (WIDTH>>2>>PIXEL_SIZE) + (counter_h>>2>>PIXEL_SIZE);
          offset <= counter_h[PIXEL_SIZE+1:PIXEL_SIZE];
          offset_d <= offset;
          
          pixel_data <= RDATA >> (offset_d * 8);
    end

    // Peripheral
    logic        REQ;
    logic        WE;
    logic [3: 0] BE;
    logic [23:0] ADDR;
    logic [31:0] WDATA;
    
    logic        GNT;
    logic        RVALID;
    logic [31:0] RDATA;
    
    // SRAM has 1 cycle delay
    always_ff @(posedge clk_i) begin
        RVALID <= REQ;
    end
    
    // always grant
    assign GNT = 1'b1;

    peripheral_wrapper i_peripheral_wrapper (
        .REQ,
        .WE,
        .BE,
        .ADDR,
        .WDATA,
        
        .GNT,
        .RVALID,
        .RDATA
    );


    big_sram big_sram_i (
        .clk_i    (clk_i),
        .addr_i   (REQ ? ADDR[12+2:2] : framebuffer_addr),
        .be_i     (BE),
        .din_i    (WDATA),
        .wen_i    (WE && REQ),
        .men_i    (1'b1),
        .ren_i    (!(WE && REQ)),
        
        .dout_o   (RDATA)
    );
    
    // Compose the final colore
    logic [5:0] rgb_o;
    always_comb begin
        rgb_o = pixel_data;
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
    
    // 4 cycles delays
    logic [6:0] hsync_d, vsync_d;
    
    // Delay output signals one cycle
    // to account for rgb_d
    always_ff @(posedge clk_i) begin
        hsync_d <= {hsync_d[5:0], hsync};
        vsync_d <= {vsync_d[5:0], vsync};
        
        next_vertical_o <= next_vertical;
        next_frame_o    <= next_frame;
    end
    
    assign hsync_o = hsync_d[6];
    assign vsync_o = vsync_d[6];

endmodule
