`timescale  1 ns / 1 ps

module  tb_klein_core ;

// constant and parameter
parameter CLK_HALF_PERIOD	= 1;
parameter CLK_PERIOD		= 2 * CLK_HALF_PERIOD;

// register and wire
reg				tb_iclk;
reg				tb_ireset;
reg				tb_iencdec;
reg				tb_iinit;
reg				tb_inext;
reg		[0:63]	tb_ikey;
reg		[0:63]	tb_iblock;

wire			tb_oready;
wire			tb_oresult_valid;
wire	[0:63]	tb_oblock;

// device under test
klein_core dut(
	.iclk(tb_iclk),
	.ireset(tb_ireset),
	.iencdec(tb_iencdec),
	.iinit(tb_iinit),
	.inext(tb_inext),
	.ikey(tb_ikey),
	.iblock(tb_iblock),

	.oready(tb_oready),
	.oresult_valid(tb_oresult_valid),
	.oblock(tb_oblock)
);

// clock generate
always begin : clk_gen
	#CLK_HALF_PERIOD;
	tb_iclk = !tb_iclk;	
end

// main test
initial begin
	// init
	tb_iclk 		= 1'b0;
	tb_ireset 	= 1'b1;
	tb_iencdec	= 1'b0;
	tb_iinit 		= 1'b0;
	tb_inext 		= 1'b0;
	tb_ikey			= 64'd0;
	tb_iblock		= 64'd0;
	#(4*CLK_PERIOD);

	// reset
	tb_ireset 	= 1'b1;
	#(2*CLK_PERIOD);
	tb_ireset 	= 1'b0;

	// enc and dec verification
	tb_iblock		= 64'hDEADBEEFF000000F; // setup enc
	tb_ikey			= 64'h1234567890ABCDEF;

	#(2*CLK_PERIOD);

	tb_inext 		= 1'b1; // start
	tb_iencdec	= 1'b1; // config enc
	#(CLK_PERIOD);
	tb_inext 		= 1'b0;
		
	while(~(tb_oready & tb_oresult_valid)) begin		
		#(CLK_PERIOD); // take cipher result
	end

	tb_iblock 	= tb_oblock; // setup dec

	tb_iinit 		= 1'b1; // start keyschedule
	#(CLK_PERIOD);
	tb_iinit 		= 1'b0;

	while(~tb_oready) begin		
		#(CLK_PERIOD); // take final key
	end

	tb_inext 		= 1'b1; // start
	tb_iencdec	= 1'b0; // config dec
	#(CLK_PERIOD);
	tb_inext 		= 1'b0;	

	while(~(tb_oready & tb_oresult_valid)) begin		
		#(CLK_PERIOD); // take decipher result
	end

	#(10*CLK_PERIOD);

	$finish;
end 

endmodule
