// SPDX-License-Identifier: Apache-2.0
module ProbeSpec(
  input clock,
        reset
);

  wire [15:0] _unused;
  reg  [4:0]  cycle;
  reg         hasBeenResetReg;
  initial begin
    hasBeenResetReg = 1'bx;
  end

  wire [15:0] value = {11'h0, cycle};
  always @(posedge clock) begin
    if (!reset & hasBeenResetReg === 1'h1) begin
      $fwrite(32'h80000002, "cycle = %d\n", cycle);
      if (cycle > 5'd0) begin
        force ProbeSpec.dut.r = value;
        // If you comment out the below line, the $fatal below does not occur
        force ProbeSpec.dut.out = 16'h7B;
      end
      if (cycle > 5'd1 & ProbeSpec.dut.r != value) begin
        $error("Assertion failed\n    at ProbeSpec.scala:652 chisel3.assert(read(dut.b.refs.reg) === cycle)\n");
        $fatal;
      end
      if (cycle > 5'd2)
        $finish;
    end
  end

  always @(posedge clock) begin
    if (reset) begin
      hasBeenResetReg <= 1'h1;
      cycle <= 5'h0;
    end
    else
      cycle <= cycle + 5'h1;
  end

  Top dut (
    .clock (clock),
    .out   (_unused)
  );
endmodule
