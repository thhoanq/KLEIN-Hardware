`timescale 1ns / 1ps

module tb_klein_keyschedule;

//	constant and parameter
parameter CLK_HALF_PERIOD	= 1;
parameter CLK_PERIOD		= 2 * CLK_HALF_PERIOD;

//	register and wire
reg						tb_iclk;
reg						tb_ireset;
reg						tb_istart;
reg		[00:63]	tb_ikey;

wire	[00:63]	tb_okey;
wire					tb_oready;

// device under test
klein_keyschedule dut(
	.iclk(tb_iclk),
	.ireset(tb_ireset),
	.istart(tb_istart),
	.ikey(tb_ikey),

	.okey(tb_okey),
	.oready(tb_oready)
);

// clock generate
always begin : clk_gen
	#CLK_HALF_PERIOD;
	tb_iclk = !tb_iclk;	
end

// main test
initial begin : main
	// init
	tb_iclk = 1'b0;
	tb_istart = 1'b0;
	tb_ikey = 64'd0;
	tb_ireset = 1;
	#(5*CLK_PERIOD);

	tb_ireset = 0;

	// main
	tb_ikey = 64'h1234567890ABCDEF;
	tb_istart = 1'b1;
	#(2*CLK_PERIOD);
	tb_istart = 1'b0;
	#(50*CLK_PERIOD);

	tb_ikey = 64'h0000000000000000;
	tb_istart = 1'b1;
	#(2*CLK_PERIOD);
	tb_istart = 1'b0;
	#(50*CLK_PERIOD);

	$finish;
end

endmodule
