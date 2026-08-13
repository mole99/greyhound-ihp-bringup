// SPDX-FileCopyrightText: © 2026 Stefan Huwar <stefan.huwar@gmail.com>
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module periph_gpio (
    output wire [31:0] gpio
);
    // CLK
    logic clk;
    (* keep *) Global_Clock clk_i (.CLK(clk));

    // RST
    logic rst;
    WARMBOOT warmboot_i (
        .SLOT0 (1'b0),
        .SLOT1 (1'b0),
        .SLOT2 (1'b0),
        .SLOT3 (1'b0),
        .BOOT  (1'b0),
        .RESET (rst)
    );

    logic        REQ;
    logic        WE;
    logic [3: 0] BE;
    logic [23:0] ADDR;
    logic [31:0] WDATA;
    
    logic        GNT;
    logic        RVALID;
    logic [31:0] RDATA;

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

    logic [31:0] periph_reg;

    assign gpio = periph_reg;

    always_ff @(posedge clk) begin
        if (rst) begin
            periph_reg <= '0;
        end
        else begin
            RVALID = 1'b0;
            if (REQ) begin
                RVALID = 1'b1;
                if (WE) begin
                    if (BE[0]) periph_reg[ 7: 0] <= WDATA[7 : 0];
                    if (BE[1]) periph_reg[15: 8] <= WDATA[15: 8];
                    if (BE[2]) periph_reg[23:16] <= WDATA[23:16];
                    if (BE[3]) periph_reg[31:24] <= WDATA[31:24];
                end else begin
                    RDATA <= periph_reg;
                end
            end
        end
    end
endmodule
