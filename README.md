# Verilator Force Issue

This is a reproducible test case for a probable bug in Verilator v5.024

You can run the test with `make replay`.
It will default to using the `verilator` on your `PATH`, but you can set the `VERILATOR` environment variable to point to a different `verilator` binary.

Correct operation, e.g. using Verilator v5.022 results in the following output (and an exit value of `0`):
```
r ready
k ack
b 00000040 000000000000000A
k ack
cycle =  0
cycle =  1
cycle =  2
cycle =  3
b 00000040 0000000000000003
grep 'Verilog $finish' /Users/koenig/work/verilator-testcase-simple/simulation-log.txt
- primary-sources/ProbeSpec.sv:28: Verilog $finish
```

Incorrect operation using Verilator v5.024 results in the following output (and a non-zero exit value):
```
r ready
k ack
b 00000040 000000000000000A
k ack
cycle =  0
cycle =  1
cycle =  2
/bin/sh: line 1:  8820 Done                    cat /Users/koenig/work/verilator-testcase-simple/execution-script.txt
      8821                       | sed -n 's/^[0-9]*> \(.*\)/\1/p'
      8822 Abort trap: 6           | SVSIM_SIMULATION_LOG=/Users/koenig/work/verilator-testcase-simple/simulation-log.txt SVSIM_SIMULATION_TRACE=/Users/koenig/work/verilator-testcase-simple/trace /Users/koenig/work/verilator-testcase-simple/simulation
grep 'Verilog $finish' /Users/koenig/work/verilator-testcase-simple/simulation-log.txt
make: *** [replay] Error 1
```
