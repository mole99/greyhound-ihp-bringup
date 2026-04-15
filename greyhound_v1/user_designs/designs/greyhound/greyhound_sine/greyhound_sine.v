// SPDX-FileCopyrightText: © 2026 FABulous Contributors
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module greyhound_sine (
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
    
    greyhound_sine_core greyhound_sine_core_i (
        .clk_i      (clk),
        .rst_ni     (!rst),

        // VGA signals
        .rrggbb_o         (rrggbb),
        .hsync_o          (hsync),
        .vsync_o          (vsync),
        .next_vertical_o  (),
        .next_frame_o     ()
    );

    // Output PMOD - Tiny VGA
    
    assign tinyvga_r = rrggbb[5:4];
    assign tinyvga_g = rrggbb[3:2];
    assign tinyvga_b = rrggbb[1:0];
    assign tinyvga_vs = vsync;
    assign tinyvga_hs = hsync;

endmodule
