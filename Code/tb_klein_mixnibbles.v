`timescale 1ns / 1ps

module tb_klein_mixnibbles;

//	register and wire
reg		[31:0]	tb_idata;
reg						tb_iinv;

wire	[31:0]	tb_odata;

// device under test
klein_mixnibbles dut(
	.idata(tb_idata),
	.iinv(tb_iinv),
	.odata(tb_odata)
	);

// main test
initial begin
	tb_iinv		= 1'b1;
	tb_idata 	= 32'h473794ED;		
	#2;
	tb_idata 	= 32'h40D4E4A5;
	#2;
	tb_iinv		= 1'b0;
	tb_idata 	= 32'h876E46A6;
	#2;
	tb_idata	= 32'hF24CE78C;
	#2;
	
	$finish;
end

endmodule
