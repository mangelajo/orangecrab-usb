# test_clkdiv.py (simple)

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
from cocotb import utils
DEFAULT_DIVISOR = 8
CLK_IN_NS = 10

@cocotb.test()
async def check_counter(dut):
    clock = Clock(dut.clk_in, CLK_IN_NS, units="ns")  # Create a 10ns period clock on port clk_in
    # Start the clock. Start it low to avoid issues on the first RisingEdge
    cocotb.start_soon(clock.start(start_high=False))

    # the initial clk_out value is not defined, until latched by a clk cycle
    await RisingEdge(dut.clk_in)
    expected_counter = 0

    # iterate the clk divisor making sure that output matches expectations
    await RisingEdge(dut.clk_in)

    for cycle in range(DEFAULT_DIVISOR * 4):
        dut._log.debug("clk_out is %s, counter is %s", dut.clk_out.value, dut.counter.value)
        expected_clkout =  0 if expected_counter>=DEFAULT_DIVISOR/2 else 1
        expected_counter = (expected_counter + 1) % DEFAULT_DIVISOR
        assert int(dut.counter.value) == expected_counter
        assert dut.clk_out.value == expected_clkout
        await RisingEdge(dut.clk_in)


@cocotb.test()
async def check_clk_out_period(dut):
    clock = Clock(dut.clk_in, CLK_IN_NS, units="ns")  # Create a 10ns period clock on port clk_in
    # Start the clock. Start it low to avoid issues on the first RisingEdge
    cocotb.start_soon(clock.start(start_high=False))

    await RisingEdge(dut.clk_out)

    for cycle in range(10):
        # the clk_out period must be clk_in period * DIVISOR
        ns_start = utils.get_sim_time('ns')
        await ClockCycles(dut.clk_out, 1)
        ns_end = utils.get_sim_time('ns')

        assert ns_end-ns_start == CLK_IN_NS * DEFAULT_DIVISOR


