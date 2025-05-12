/*
  This module is used for klein cipher
  Author: thh
*/

module  klein_cipher (
  input   wire          iclk,
  input   wire          ireset,
  input   wire          istart,
  input   wire  [00:63] iblock,
  input   wire  [00:63] ikey,

  output  wire          oready,
  output  wire  [00:63] oblock
);

reg             ready_reg;
reg             ready_new;
reg             ready_we;

reg     [00:63] result_reg;
reg             result_we;

reg     [00:03] round; 
reg     [00:63] state, kstate;

wire    [00:63] nstate, nkstate;
wire    [00:63] ssum, ssubs, srot;
wire    [00:63] krot, kfei;

// update output
assign oready = ready_reg;
assign oblock = result_reg;

// control
always @(posedge iclk) begin
  if (ireset) begin
    // reset
    round       <= 4'd0;
    result_reg  <= 64'd0;
    state       <= 64'd0;
    kstate      <= 64'd0;
    ready_reg   <= 1'b0;
  end
  else begin
    if(istart) begin
      round       <=  4'd0;
      result_reg  <=  64'd0;
      state       <=  iblock;
      kstate      <=  ikey;
      ready_reg   <=  1'b0;
    end
    else begin
      if(round < 4'd12)
        round       <=  round + 4'd1;
      state       <=  nstate;
      kstate      <=  nkstate;
      if(result_we)
        result_reg  <= nstate ^ nkstate;
      if(round == 4'd11)
        round       <= 4'd12;
      if(ready_we)
        ready_reg   <= ready_new;
    end
  end
end

// AddKeys
assign ssum = state ^ kstate;

//Sboxes
klein_sbox s1  (.in(ssum[00:03]), .out(ssubs[00:03]));
klein_sbox s2  (.in(ssum[04:07]), .out(ssubs[04:07]));
klein_sbox s3  (.in(ssum[08:11]), .out(ssubs[08:11]));
klein_sbox s4  (.in(ssum[12:15]), .out(ssubs[12:15]));
klein_sbox s5  (.in(ssum[16:19]), .out(ssubs[16:19]));
klein_sbox s6  (.in(ssum[20:23]), .out(ssubs[20:23]));
klein_sbox s7  (.in(ssum[24:27]), .out(ssubs[24:27]));
klein_sbox s8  (.in(ssum[28:31]), .out(ssubs[28:31]));
klein_sbox s9  (.in(ssum[32:35]), .out(ssubs[32:35]));
klein_sbox s10 (.in(ssum[36:39]), .out(ssubs[36:39]));
klein_sbox s11 (.in(ssum[40:43]), .out(ssubs[40:43]));
klein_sbox s12 (.in(ssum[44:47]), .out(ssubs[44:47]));
klein_sbox s13 (.in(ssum[48:51]), .out(ssubs[48:51]));
klein_sbox s14 (.in(ssum[52:55]), .out(ssubs[52:55]));
klein_sbox s15 (.in(ssum[56:59]), .out(ssubs[56:59]));
klein_sbox s16 (.in(ssum[60:63]), .out(ssubs[60:63]));

// RotateNibbles
assign srot = {ssubs[16:63], ssubs[0:15]};

// MixNibbles
klein_mixnibbles mix1(.idata(srot[00:31]), .iinv(1'b0), .odata(nstate[00:31]));
klein_mixnibbles mix2(.idata(srot[32:63]), .iinv(1'b0), .odata(nstate[32:63]));

// Rotate keys
assign krot = {kstate[8:31], kstate[0:7], kstate[40:63], kstate[32:39]};

// Feistel
assign kfei[00:31] = krot[32:63];
assign kfei[32:63] = krot[00:31] ^ krot[32:63];

// Next keys
assign nkstate[00:15] = kfei[00:15];
assign nkstate[16:23] = kfei[16:23] ^ {4'd0, round + 1};
assign nkstate[24:39] = kfei[24:39];
klein_sbox sk0 (.in(kfei[40:43]), .out(nkstate[40:43]));
klein_sbox sk1 (.in(kfei[44:47]), .out(nkstate[44:47]));
klein_sbox sk2 (.in(kfei[48:51]), .out(nkstate[48:51]));
klein_sbox sk3 (.in(kfei[52:55]), .out(nkstate[52:55]));
assign nkstate[56:63] = kfei[56:63];


always @* begin
    result_we   = 1'b0;
    ready_new   = 1'b0;
    ready_we    = 1'b0;
  
    if(round == 4'd11) begin
        result_we   = 1'b1;
        ready_new   = 1'b1;
        ready_we    = 1'b1; 
    end
end

endmodule
