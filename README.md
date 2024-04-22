# Verilator Force Issue

**Disclaimer**: Apologies that the C++ wrapping the Verilator simulation is a more complex than it needs to be.
I believe the problem is understandable from just the Verilog so I figured I wouldn't bother minimizing that infrastructure any further.

# Introduction

This is a reproducible test case for a probable bug in Verilator v5.024

You can run the test with `make replay` (or just `make`).
It will default to using the `verilator` on your `PATH`, but you can set the `VERILATOR` environment variable to point to a different `verilator` binary.

Correct operation, e.g. using Verilator v5.022 results in the following output (and an exit value of `0`):

```
r ready
k ack
b 00000040 000000000000000A
k ack
[ 0]: dut.r = 0x002a, dut.out = 0x002a
[ 1]: dut.r = 0x002a, dut.out = 0x002a
[ 2]: dut.r = 0xdead, dut.out = 0xbeef
[ 3]: dut.r = 0xdead, dut.out = 0xbeef
b 00000040 0000000000000003
grep 'Verilog $finish' /Users/koenig/work/verilator-testcase-simple/simulation-log.txt
- primary-sources/ProbeSpec.sv:26: Verilog $finish
```

Incorrect operation using Verilator v5.024 results in the following output (and a non-zero exit value):

```
r ready
k ack
b 00000040 000000000000000A
k ack
[ 0]: dut.r = 0x002a, dut.out = 0x002a
[ 1]: dut.r = 0x002a, dut.out = 0x002a
[ 2]: dut.r = 0xbeef, dut.out = 0xbeef
/bin/sh: line 1: 19207 Done                    cat /Users/koenig/work/verilator-testcase-simple/execution-script.txt
     19208                       | sed -n 's/^[0-9]*> \(.*\)/\1/p'
     19209 Abort trap: 6           | SVSIM_SIMULATION_LOG=/Users/koenig/work/verilator-testcase-simple/simulation-log.txt SVSIM_SIMULATION_TRACE=/Users/koenig/work/verilator-testcase-simple/trace /Users/koenig/work/verilator-testcase-simple/simulation
grep 'Verilog $finish' /Users/koenig/work/verilator-testcase-simple/simulation-log.txt
make: *** [replay] Error 1
```

## Diagnosis

The issue is with forcing both a register and an output port driven by that register.
The target code in question:
```verilog
// From primary-sources/Top.sv
module Top(
  input         clock,
  output [15:0] out
);
  reg [15:0] r;
  always @(posedge clock)
    r <= 16'h2A;
  assign out = r;
endmodule
```

These values are forced by a module above:
```verilog
// From primary-sources/ProbeSpec.sv

force ProbeSpec.dut.r = 16'hdead;
// If you comment out the below line, the $fatal below does not occur
force ProbeSpec.dut.out = 16'hbeef;
```

When both `Top.r` and `Top.out` are forced to different values, `Top.r` should get the value it is forced to, but instead, it is getting the value forced to `Top.out` as illustrated in the output above.

I bisected the issue to be introduced in commit https://github.com/verilator/verilator/commit/5e1fc6e24d9c2706d9871de9bec25cebf2a95ac7
