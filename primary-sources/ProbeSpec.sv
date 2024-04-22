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

  always @(posedge clock) begin
    if (!reset & hasBeenResetReg === 1'h1) begin
      $fwrite(32'h80000002, "[%d]: dut.r = 0x%h, dut.out = 0x%h\n", cycle, ProbeSpec.dut.r, ProbeSpec.dut.out);
      if (cycle > 5'd0) begin
        force ProbeSpec.dut.r = 16'hdead;
        // If you comment out the below line, the $fatal below does not occur
        force ProbeSpec.dut.out = 16'hbeef;
      end
      if (cycle > 5'd1 & ProbeSpec.dut.r != 16'hdead) begin
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
