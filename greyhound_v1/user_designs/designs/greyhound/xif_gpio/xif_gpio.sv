// SPDX-FileCopyrightText: © 2026 Stefan Huwar <stefan.huwar@gmail.com>
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module xif_gpio (
    output wire [31:0] gpio
);
    wire [31:0] RS1;
    wire [31:0] RS2;
    wire [31:0] RESULT;

    xif_wrapper i_xif_wrapper (
        .RS1,
        .RS2,
        .RESULT
    );

    assign RESULT = {RS2[15:0], RS1[15:0]};
    assign gpio = RESULT;
endmodule
