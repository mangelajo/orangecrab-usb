# test_clkdiv.py (simple)

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge, Timer
from cocotb import utils

CLK_IN_NS = int(1/(48000*64)*1000000000)

async def setup_and_reset(dut):
    clock = Clock(dut.clk_in, CLK_IN_NS, units="ns")  # Create a 10ns period clock on port clk_in
    # Start the clock. Start it low to avoid issues on the first RisingEdge
    cocotb.start_soon(clock.start(start_high=False))

    # assert reset for 1 clock cycle...
    dut.rstn.value = 0
    await ClockCycles(dut.clk_in, 1)
    dut.rstn.value = 1
    await Timer(10, 'ns')


@cocotb.test()
async def check_i2s_falling_edge(dut):
    
    await setup_and_reset(dut)

    for cycle in range(4):
        dut._log.debug("verifying i2s_ws is low for 32 first clocks on falling edge")    
        for _ in range(32):
            assert dut.i2s_ws.value == 0
            await FallingEdge(dut.clk_in)
            await Timer(10, 'ns')
        
        dut._log.debug("verifying i2s_ws is high for 32 next clocks on falling edge")
        for _ in range(32):
            assert dut.i2s_ws.value == 1
            await FallingEdge(dut.clk_in)
            await Timer(10, 'ns')

@cocotb.test()
async def check_i2s_cycle(dut):
    
    await setup_and_reset(dut)
    await FallingEdge(dut.clk_in)
    await ClockCycles(dut.i2s_ws, 1)
    
    for cycle in range(4):
        # the clk_out period must be clk_in period * DIVISOR
        ns_start = utils.get_sim_time('ns')
        await ClockCycles(dut.i2s_ws, 1)
        ns_end = utils.get_sim_time('ns')

        assert round(ns_end-ns_start) == CLK_IN_NS * 64


@cocotb.test()
async def check_i2s_l_r(dut):
    
    await setup_and_reset(dut)
    await FallingEdge(dut.clk_in)
    
    DATA_LR = [0x0123456789abcdef,
               0xabcdef0123456789,
               0xaaaaaaaabbbbbbbb,
               0xeeeeeeeeffffffff]


    for cycle in range(4):
        data = DATA_LR[cycle]
        await FallingEdge(dut.i2s_ws)
        await RisingEdge(dut.clk_in)
        await Timer(10, 'ns')
        dut._log.debug("data=%s bc=%d ws=%s", dut.data.value, dut.bit_counter.value, dut.i2s_ws.value)
           
        for _ in range(64):
            dut.i2s_sd.value = 1 if data & (1<<63) else 0
            data = (data << 1) & 0xffffffffffffffff
            await RisingEdge(dut.i2s_mclk)
            await Timer(10, 'ns')
            dut._log.debug("data=%s bc=%d ws=%s", dut.data.value, dut.bit_counter.value, dut.i2s_ws.value)
           
        assert dut.data.value == DATA_LR[cycle]
        assert dut.bit_counter.value == 0
        assert dut.i2s_ws.value == 0
    
        # data outputs must not be latched until next clk_in when bit_counter == 0
        await RisingEdge(dut.clk_in)
        await Timer(10, 'ns')

        assert dut.left_data.value == DATA_LR[cycle] >> 32
        assert dut.right_data.value == DATA_LR[cycle] & 0xffffffff
