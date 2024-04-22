// SPDX-License-Identifier: Apache-2.0
module Top(
  input         clock,
  output [15:0] out
);

  reg [15:0] r;
  always @(posedge clock)
    r <= 16'h2A;
  assign out = r;
endmodule
