// SPDX-FileCopyrightText: © 2026 Leo Moser <leo.moser@pm.me>
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module periph_regfile (
    output wire [31:0] gpio
);

    // CLK
    logic clk;
    (* keep *) Global_Clock clk_i (.CLK(clk));

    // RST
    logic rst;
    WARMBOOT_wrapper WARMBOOT_wrapper (
        .SLOT   (4'd0),
        .BOOT   (1'b0),
        .RESET  (rst)
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

    logic [31:0] regs [32];

    assign GNT = 1'b1;

    always_ff @(posedge clk) begin
        RVALID = 1'b0;
        if (REQ) begin
            RVALID = 1'b1;
            if (WE) begin
                if (BE[0]) regs[ADDR[6:2]][ 7: 0] <= WDATA[7 : 0];
                if (BE[1]) regs[ADDR[6:2]][15: 8] <= WDATA[15: 8];
                if (BE[2]) regs[ADDR[6:2]][23:16] <= WDATA[23:16];
                if (BE[3]) regs[ADDR[6:2]][31:24] <= WDATA[31:24];
            end else begin
                RDATA <= regs[ADDR[6:2]];
            end
        end
    end

    assign gpio = '0;

endmodule
