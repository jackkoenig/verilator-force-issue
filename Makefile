# This Makefile enables lightweight debugging of `svsim` tests. 
# To rebuild the simulation run `make simulation` in this directory.
# To replay the simulation run `make replay` in this directory.
# Changes to `generated-sources` and `primary-sources` will be picked up when running `make replay` and `make simulation`. This is useful for debugging issues. You can also freely add, remove or change any of the arguments to the backend or simulation in the targets below.

.PHONY: clean simulation replay

clean:
	rm -rf verilated-sources simulation simulation-log.txt

VERILATOR ?= verilator

simulation: clean
	$(compilerEnvironment) \
	$(VERILATOR) \
		'--cc' \
		'--exe' \
		'--build' \
		'-j' \
		'0' \
		'-o' \
		'../simulation' \
		'--top-module' \
		'svsimTestbench' \
		'--Mdir' \
		'verilated-sources' \
		'-Wno-fatal' \
		'-Wno-WIDTH' \
		'-Wno-STMTDLY' \
		'-O1' \
		'-MAKEFLAGS' \
		'-j 10' \
		'-CFLAGS' \
		'-O1 -std=c++14 -I$(shell pwd) -DSVSIM_ENABLE_VERILATOR_SUPPORT' \
		'+define+ASSERT_VERBOSE_COND=!svsimTestbench.reset' \
		'+define+PRINTF_COND=!svsimTestbench.reset' \
		'+define+STOP_COND=!svsimTestbench.reset' \
		$(sourcefiles)

replay: simulation
	cat $(shell pwd)/execution-script.txt | { grep '^#' || true; } && \
	cat $(shell pwd)/execution-script.txt | sed -n 's/^[0-9]*> \(.*\)/\1/p' | \
		$(simulationEnvironment) $(shell pwd)/simulation || true
	grep 'Verilog $$finish' $(shell pwd)/simulation-log.txt

sourcefiles = \
	'primary-sources/Top.sv' \
	'primary-sources/ProbeSpec.sv' \
	'generated-sources/testbench.sv' \
	'generated-sources/c-dpi-bridge.cpp' \
	'generated-sources/simulation-driver.cpp'

compilerEnvironment = \

simulationEnvironment = \
	SVSIM_SIMULATION_LOG=$(shell pwd)/simulation-log.txt \
	SVSIM_SIMULATION_TRACE=$(shell pwd)/trace

