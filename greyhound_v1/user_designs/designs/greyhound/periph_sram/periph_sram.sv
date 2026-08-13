// SPDX-FileCopyrightText: © 2026 Stefan Huwar <stefan.huwar@gmail.com>
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module periph_sram (
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

    // SRAM
    parameter NUM_SRAM = 7;
    logic [32-1:0] DOUT_SRAMS [NUM_SRAM];
    logic [32-1:0] DOUT, DOUT_D;

    // Peripheral
    logic        REQ;
    logic        WE;
    logic [3: 0] BE;
    logic [23:0] ADDR;
    logic [31:0] WDATA;
    
    logic        GNT;
    logic        RVALID;
    logic [31:0] RDATA;
    
    logic [2:0] select_sram, select_sram_d;
    assign select_sram = ADDR[12+2:10+2];
    
    generate
        for (genvar i=0; i<NUM_SRAM; i++) begin : gen
        
            IHP_SRAM_1024x32_wrapper sram (
                .ADDR   (ADDR[9+2:0+2]),
                .BM     ({{8{BE[3]}}, {8{BE[2]}}, {8{BE[1]}}, {8{BE[0]}}}),
                .DIN    (WDATA),
                .WEN    (WE),
                .MEN    (select_sram == i && REQ),
                .REN    (!WE),
                .DOUT   (DOUT_SRAMS[i])
            );
        end
    endgenerate
    
    always_ff @(posedge clk) begin
        RVALID <= REQ;
        select_sram_d <= select_sram;
    end
    
    always_comb begin
        DOUT = 0;
        if (select_sram_d < NUM_SRAM) begin
            DOUT = DOUT_SRAMS[select_sram_d];
        end
    end
    
    assign RDATA = DOUT;
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
    
    assign gpio = '0;

endmodule
