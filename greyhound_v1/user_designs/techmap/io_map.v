module \$__FABULOUS_IBUF (input PAD, output OUT);
	IO_1_bidirectional_frame_config_pass _TECHMAP_REPLACE_ (.PAD(PAD), .O(OUT), .T(1'b1));
endmodule

module \$__FABULOUS_OBUF (output PAD, input IN);
	IO_1_bidirectional_frame_config_pass _TECHMAP_REPLACE_ (.PAD(PAD), .I(IN), .T(1'b0));
endmodule

module \$__FABULOUS_TBUF (output PAD, input IN, input EN);
	IO_1_bidirectional_frame_config_pass _TECHMAP_REPLACE_ (.PAD(PAD), .I(IN), .T(!EN));
endmodule

module \$__FABULOUS_IOBUF (inout PAD, output OUT, input IN, input EN);
	IO_1_bidirectional_frame_config_pass _TECHMAP_REPLACE_ (.PAD(PAD), .O(OUT), .I(IN), .T(!EN));
endmodule
