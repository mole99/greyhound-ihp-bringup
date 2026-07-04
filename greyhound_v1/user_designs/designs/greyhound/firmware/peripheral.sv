// SPDX-FileCopyrightText: © 2026 Stefan Huwar <stefan.huwar@gmail.com>
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module peripheral(
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

module peripheral_wrapper (
    output        REQ,
    output        WE,
    output [3: 0] BE,
    output [23:0] ADDR,
    output [31:0] WDATA,
    
    input         GNT,
    input         RVALID,
    input  [31:0] RDATA
);

    wire [63:0] O, I;

    assign WDATA = O[31:0];
    assign ADDR  = O[55:32];
    assign BE    = O[59:56];
    assign WE    = O[60];
    assign REQ   = O[61];
    
    assign I[31:0] = RDATA;
    assign I[32]   = RVALID;
    assign I[33]   = GNT;

    (* keep, BEL="X5Y15.A" *) CPU_IF i_CPU_IF_0 (
        .I0     (I[0]),
        .I1     (I[1]),
        .I2     (I[2]),
        .I3     (I[3]),
        .I4     (I[4]),
        .I5     (I[5]),
        .I6     (I[6]),
        .I7     (I[7]),
        .I8     (I[8]),
        .I9     (I[9]),
        .I10     (I[10]),
        .I11     (I[11]),
        .I12     (I[12]),
        .I13     (I[13]),
        .I14     (I[14]),
        .I15     (I[15]),

        .O0     (O[0]),
        .O1     (O[1]),
        .O2     (O[2]),
        .O3     (O[3]),
        .O4     (O[4]),
        .O5     (O[5]),
        .O6     (O[6]),
        .O7     (O[7]),
        .O8     (O[8]),
        .O9     (O[9]),
        .O10     (O[10]),
        .O11     (O[11]),
        .O12     (O[12]),
        .O13     (O[13]),
        .O14     (O[14]),
        .O15     (O[15])
    );
    
    (* keep, BEL="X6Y15.A" *) CPU_IF i_CPU_IF_1 (
        .I0     (I[16]),
        .I1     (I[17]),
        .I2     (I[18]),
        .I3     (I[19]),
        .I4     (I[20]),
        .I5     (I[21]),
        .I6     (I[22]),
        .I7     (I[23]),
        .I8     (I[24]),
        .I9     (I[25]),
        .I10     (I[26]),
        .I11     (I[27]),
        .I12     (I[28]),
        .I13     (I[29]),
        .I14     (I[30]),
        .I15     (I[31]),

        .O0     (O[16]),
        .O1     (O[17]),
        .O2     (O[18]),
        .O3     (O[19]),
        .O4     (O[20]),
        .O5     (O[21]),
        .O6     (O[22]),
        .O7     (O[23]),
        .O8     (O[24]),
        .O9     (O[25]),
        .O10     (O[26]),
        .O11     (O[27]),
        .O12     (O[28]),
        .O13     (O[29]),
        .O14     (O[30]),
        .O15     (O[31])
    );
    
    (* keep, BEL="X8Y15.A" *) CPU_IF i_CPU_IF_2 (
        .I0     (I[32]),
        .I1     (I[33]),
        .I2     (I[34]),
        .I3     (I[35]),
        .I4     (I[36]),
        .I5     (I[37]),
        .I6     (I[38]),
        .I7     (I[39]),
        .I8     (I[40]),
        .I9     (I[41]),
        .I10     (I[42]),
        .I11     (I[43]),
        .I12     (I[44]),
        .I13     (I[45]),
        .I14     (I[46]),
        .I15     (I[47]),

        .O0     (O[32]),
        .O1     (O[33]),
        .O2     (O[34]),
        .O3     (O[35]),
        .O4     (O[36]),
        .O5     (O[37]),
        .O6     (O[38]),
        .O7     (O[39]),
        .O8     (O[40]),
        .O9     (O[41]),
        .O10     (O[42]),
        .O11     (O[43]),
        .O12     (O[44]),
        .O13     (O[45]),
        .O14     (O[46]),
        .O15     (O[47])
    );
    
    (* keep, BEL="X9Y15.A" *) CPU_IF i_CPU_IF_3 (
        .I0     (I[48]),
        .I1     (I[49]),
        .I2     (I[50]),
        .I3     (I[51]),
        .I4     (I[52]),
        .I5     (I[53]),
        .I6     (I[54]),
        .I7     (I[55]),
        .I8     (I[56]),
        .I9     (I[57]),
        .I10     (I[58]),
        .I11     (I[59]),
        .I12     (I[60]),
        .I13     (I[61]),
        .I14     (I[62]),
        .I15     (I[63]),

        .O0     (O[48]),
        .O1     (O[49]),
        .O2     (O[50]),
        .O3     (O[51]),
        .O4     (O[52]),
        .O5     (O[53]),
        .O6     (O[54]),
        .O7     (O[55]),
        .O8     (O[56]),
        .O9     (O[57]),
        .O10     (O[58]),
        .O11     (O[59]),
        .O12     (O[60]),
        .O13     (O[61]),
        .O14     (O[62]),
        .O15     (O[63])
    );

endmodule
