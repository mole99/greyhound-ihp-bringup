// SPDX-FileCopyrightText: © 2026 FABulous Contributors
// SPDX-License-Identifier: GPL-2.0

// Code taken from: https://github.com/icebreaker-fpga/WTFpga

`default_nettype none

module seven_seg (
    output wire [6:0] seg,
    output wire       ca
);
    // System
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

    // Design
    // This design assumes a clock frequency of 2^16 = 65536 Hz
    
    logic [15:0] precounter;
    logic [7:0] counter;
    
    always @(posedge clk) begin
	      if (rst) begin
	          precounter <= 0;
	          counter <= 0;
	      end else begin
	          precounter <= precounter + 1;
	      
            if (&precounter) begin
                counter <= counter + 1;
            end
        end
    end
    

	  wire [6:0] disp0, disp1;

	  nibble_to_seven_seg nibble0(
		    .nibblein(counter[3:0]),
		    .segout(disp0)
	  );	 
	  
	  nibble_to_seven_seg nibble1(
		    .nibblein(counter[7:4]),
        .segout(disp1)
	  );	
	  
	  logic trigger;
	  assign trigger = precounter[7];

	  logic current;
	  logic [6:0] segout;
	  always @(posedge clk) begin
	      if (rst) begin
	          current <= 1'b0;
	      end else begin
            if (trigger) begin
                current <= ~current;
	              case (current)
		                1'b1: segout  <= disp1;
		                1'b0: segout  <= disp0;
	              endcase
	          end
        end
    end
    
    assign seg = segout;
    assign ca = current;

endmodule
