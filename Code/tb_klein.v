`timescale 1ns / 1ns

module tb_klein;

parameter CLK_HALF_PERIOD	= 1;
parameter CLK_PERIOD		= 2 * CLK_HALF_PERIOD;

// The DUT address map
//
parameter ADDR_CTRL			= 8'h00;
parameter CTRL_INIT_BIT  	= 0;
parameter CTRL_NEXT_BIT		= 1;

parameter ADDR_CONF			= 8'h01;
parameter CONF_ENCDEC_BIT	= 0;

parameter ADDR_STATUS		= 8'h02;
parameter STATUS_READY_BIT	= 0;
parameter STATUS_VALID_BIT	= 1;

parameter ADDR_KEY0			= 8'h10;
parameter ADDR_KEY1			= 8'h11;

parameter ADDR_BLOCK0		= 8'h20;
parameter ADDR_BLOCK1		= 8'h21;

parameter ADDR_RESULT0		= 8'h30;
parameter ADDR_RESULT1		= 8'h31;

// Register and Wire declarations
//
reg 	[31:0]	read_data;
reg		[63:0]	out_data;

reg				tb_clk;
reg				tb_reset;
reg				tb_cs;
reg				tb_we;
reg 	[8:0]	tb_address;
reg 	[31:0]	tb_write_data;
wire 	[31:0]	tb_read_data;

// DUT
//
klein dut (
	.iclk(tb_clk),
	.ireset(tb_reset),
	.ics(tb_cs),
	.iwe(tb_we),
	.iaddress(tb_address),
	.iwrite_data(tb_write_data),
	.oread_data(tb_read_data)
	);

// clock generater
//
always begin : clk_gen
	#CLK_HALF_PERIOD;
	tb_clk = !tb_clk;	
end

// reset_dut()
//
task reset_dut;
	begin
		tb_reset = 1;

	    #(2 * CLK_PERIOD);
	    tb_reset = 0;
	end
endtask

// init_sim()
//
task init_sim;
	begin
		tb_clk 			= 0;
		tb_reset		= 0;

		tb_cs			= 0;
		tb_we 			= 0;

		tb_address		= 3'b0;
		tb_write_data	= 32'b0;
	end
endtask

// write_word()
//
task write_word(input 	[8:0] 	address,
				input 	[31:0]	word);
	begin
		tb_address 		= address;
		tb_write_data 	= word;
		tb_cs			= 1;
		tb_we 			= 1;

		#(2*CLK_PERIOD);
		tb_cs			= 0;
		tb_we 			= 0; 
	end
endtask

// write_block()
//
task write_block(input [63:0] block);
	begin
		write_word(ADDR_BLOCK0, block[63:32]);
		write_word(ADDR_BLOCK1, block[31:00]);
	end
endtask

// write_key()
//
task write_key(input [63:0] key);
	begin
		write_word(ADDR_KEY0, key[63:32]);
		write_word(ADDR_KEY1, key[31:00]);
	end
endtask

// read_word()
//
task read_word(input [8:0] address);
	begin
		tb_address 	= address;
		tb_cs 		= 1;
		tb_we 		= 0;

		#(CLK_PERIOD);
		read_data 	= tb_read_data;
		tb_cs		= 0;
	end
endtask

// read_result()
//
task read_result;
	begin
		read_word(ADDR_RESULT0);
		out_data[63:32] = read_data;
		read_word(ADDR_RESULT1);
		out_data[31:00] = read_data;
	end
endtask

// encipher_test()
//
task encipher_test (input 	[63:0] key,
					input	[63:0] inp);
	begin
		write_block(inp);
		write_key(key);

		write_word(ADDR_CONF, (32'h00 ^ 1'h1));
		write_word(ADDR_CTRL, (32'h00 ^ 2'h2));

		#(20*CLK_PERIOD);
		read_result();
		#(20*CLK_PERIOD);
	end
endtask

// decipher_test()
//
task decipher_test (input 	[63:0] key,
					input	[63:0] inp);
	begin
		write_block(inp);
		write_key(key);

		write_word(ADDR_CONF, (32'h00 ^ 1'h0));
		write_word(ADDR_CTRL, (32'h00 ^ 2'h1));

		#(20*CLK_PERIOD);

		write_word(ADDR_CTRL, (32'h00 ^ 2'h2));

		#(20*CLK_PERIOD);
		read_result();
		#(20*CLK_PERIOD);
	end
endtask

// klein_test()
//
task klein_test;
	reg [63:0] key0;
	reg [63:0] key1;
	reg [63:0] key2;
	reg [63:0] key3;

	reg [63:0] plaintext0;
	reg [63:0] plaintext1;
	reg [63:0] plaintext2;
	reg [63:0] plaintext3;

	reg [63:0] ciphertext0;
	reg [63:0] ciphertext1;
	reg [63:0] ciphertext2;
	reg [63:0] ciphertext3;

	begin
		key0 			= 64'h0000000000000000;
		plaintext0		= 64'hffffffffffffffff;
		ciphertext0		= 64'hCDC0B51F14722BBE;

		key1 			= 64'hffffffffffffffff;
		plaintext1 		= 64'h0000000000000000;
		ciphertext1		= 64'h6456764E8602E154;

		key2			= 64'h1234567890ABCDEF;
		plaintext2		= 64'hffffffffffffffff;
		ciphertext2		= 64'h592356C4997176C8;

		key3			= 64'h0000000000000000;
		plaintext3		= 64'h1234567890ABCDEF;
		ciphertext3		= 64'h629F9D6DFF95800E;



		encipher_test(key0, plaintext0);
		reset_dut();
		decipher_test(key0, ciphertext0);
		reset_dut();

		encipher_test(key1, plaintext1);
		reset_dut();
		decipher_test(key1, ciphertext1);
		reset_dut();

		encipher_test(key2, plaintext2);
		reset_dut();
		decipher_test(key2, ciphertext2);
		reset_dut();

		encipher_test(key3, plaintext3);
		reset_dut();
		decipher_test(key3, ciphertext3);
		reset_dut();
	end
endtask	



// main
//
initial
	begin : main
		init_sim();
		#CLK_PERIOD;
		reset_dut();
		#CLK_PERIOD;
		klein_test();
		$finish;
	end
endmodule