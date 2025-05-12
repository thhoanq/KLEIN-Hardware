`timescale  1 ns / 1 ns

module  tb_klein_cipher ;

//  constant and parameter
parameter CLK_HALF_PERIOD = 1;
parameter CLK_PERIOD    = 2 * CLK_HALF_PERIOD;

//  register and wire
reg           tb_iclk;
reg           tb_ireset;
reg           tb_istart;
reg   [00:63] tb_iblock;
reg   [00:63] tb_ikey;

wire          tb_oready;
wire  [00:63] tb_oblock;

// device under test
klein_cipher dut (
  .iclk(tb_iclk),
  .ireset(tb_ireset),
  .istart(tb_istart),
  .iblock(tb_iblock),
  .ikey(tb_ikey),

  .oready(tb_oready),
  .oblock(tb_oblock)
);

// clock generate
always begin : clk_gen
  #CLK_HALF_PERIOD;
  tb_iclk = !tb_iclk; 
end

// main test
initial begin : main
  // init
  tb_iclk   = 1'b0;
  tb_istart = 1'b0;
  tb_iblock = 64'd0;
  tb_ikey   = 64'd0;
  #(2*CLK_PERIOD) ;  // Wait for 3 periods of time

  tb_ireset  = 1'b1;
  #(2*CLK_PERIOD);
  tb_ireset  = 1'b0;

  tb_ikey   = 64'h0000000000000000;
  tb_iblock = 64'hffffffffffffffff;
  tb_istart = 1'b1;  // Start pulled up
  #(CLK_PERIOD);     // After one period of time
  tb_istart = 1'b0;  // start is pulled down -> a single pulse
  //Wait until ready becomes "1"
  wait (tb_oready);
  #(5*CLK_PERIOD);  // Check to see if output is correct

  // Wait a few periods. Change inputs and send start
  #(3*CLK_PERIOD);   // Wait for 3 periods of time
  tb_ikey    = 64'hffffffffffffffff;
  tb_iblock  = 64'h0000000000000000;
  tb_istart  = 1'b1;  // Start pulled up
  #(CLK_PERIOD);      // After one period of time
  tb_istart  = 1'b0;  // start is pulled down -> a single pulse
  // Wait until ready becomes "1"
  wait (tb_oready);
  #(5*CLK_PERIOD);  // Check to see if output is correct

  // Wait a few periods. Change inputs and send start
  #(3*CLK_PERIOD);  // Wait for 3 periods of time
  tb_ikey    = 64'h1234567890abcdef;
  tb_iblock  = 64'hffffffffffffffff;
  tb_istart  = 1'b1;  // Start pulled up
  #(CLK_PERIOD);           // After one period of time
  tb_istart  = 1'b0;  // start is pulled down -> a single pulse
  // Wait until ready becomes "1"
  wait (tb_oready);
  #(5*CLK_PERIOD);  // Check to see if output is correct

  // Wait a few periods. Change inputs and send start
  #(3*CLK_PERIOD);  // Wait for 3 periods of time
  tb_ikey    = 64'h1234567890abcdef;
  tb_iblock  = 64'hdeadbeeff000000f;
  tb_istart  = 1'b1;  // Start pulled up
  #(CLK_PERIOD);           // After one period of time
  tb_istart  = 1'b0;  // start is pulled down -> a single pulse
  // Wait until ready becomes "1"
  wait (tb_oready);
  #(8*CLK_PERIOD);  // Check to see if output is correct

  $finish;
end

endmodule
