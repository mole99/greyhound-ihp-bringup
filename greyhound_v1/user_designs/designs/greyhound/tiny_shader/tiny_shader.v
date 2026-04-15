// SPDX-FileCopyrightText: © 2026 FABulous Contributors
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module tiny_shader (
    output wire [1:0] tinyvga_r,
    output wire [1:0] tinyvga_g,
    output wire [1:0] tinyvga_b,
    output wire       tinyvga_hs,
    output wire       tinyvga_vs
);

    wire clk;
    (* keep *) Global_Clock clk_i (.CLK(clk));
    
    wire rst;
    
    (* keep *)
    WARMBOOT warmboot_i (
        .SLOT0 (1'b0),
        .SLOT1 (1'b0),
        .SLOT2 (1'b0),
        .SLOT3 (1'b0),
        .BOOT  (1'b0),
        .RESET (rst)
    );

    wire [5:0] rrggbb;
    wire hsync;
    wire vsync;
    
    tiny_shader_top tiny_shader_top_inst (
        .clk_i      (clk),
        .rst_ni     (!rst),

        // SPI signals
        .spi_sclk_i     (1'b0),
        .spi_mosi_i     (1'b0),
        .spi_miso_o     (),
        .spi_cs_i       (1'b1),
        
        // Mode signal
        .mode_i         (1'b0),

        // SVGA signals
        .rrggbb_o         (rrggbb),
        .hsync_o          (hsync),
        .vsync_o          (vsync),
        .next_vertical_o  (),
        .next_frame_o     (),
        
        // Debug signals
        .debug_i (2'b00),
        .debug_o ()
    );

    // Output PMOD - Tiny VGA
    
    assign tinyvga_r = rrggbb[5:4];
    assign tinyvga_g = rrggbb[3:2];
    assign tinyvga_b = rrggbb[1:0];
    assign tinyvga_vs = vsync;
    assign tinyvga_hs = hsync;

endmodule
