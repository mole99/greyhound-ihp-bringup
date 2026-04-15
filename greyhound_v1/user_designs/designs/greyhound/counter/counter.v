// SPDX-FileCopyrightText: © 2026 FABulous Contributors
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module counter (
    output wire [31:0] gpio
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

    reg [31:0] ctr1;

    // Reset before enable
    always @(posedge clk) begin
        if (rst) begin
            ctr1 <= '0;
        end else begin
            ctr1 <= ctr1 + 1'b1;
        end
    end

    // Enable before reset
    /*always @(posedge clk) begin
        if (ena) begin
            if (rst) begin
                ctr1 <= '0;
            end else begin
                ctr1 <= ctr1 + 1'b1;
            end
        end
    end*/

    assign gpio = ctr1;

endmodule
