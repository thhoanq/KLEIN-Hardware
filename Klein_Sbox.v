module Klein_Sbox(in, out);
  input wire [3:0] in;
  output wire [3:0] out;
  
  reg [3:0] reg_out;
  
  assign out = reg_out;
  
  always @(*) begin
   case (in)
    4'h0: reg_out = 4'h7;
    4'h1: reg_out = 4'h4;
    4'h2: reg_out = 4'hA;
    4'h3: reg_out = 4'h9;
    4'h4: reg_out = 4'h1;
    4'h5: reg_out = 4'hF;
    4'h6: reg_out = 4'hB;
    4'h7: reg_out = 4'h0;
    4'h8: reg_out = 4'hC;
    4'h9: reg_out = 4'h3;
    4'hA: reg_out = 4'h2;
    4'hB: reg_out = 4'h6;
    4'hC: reg_out = 4'h8;
    4'hD: reg_out = 4'hE;
    4'hE: reg_out = 4'hD;
    4'hF: reg_out = 4'h5;
   default: reg_out = 4'h5;
  endcase 
 end 
  
endmodule 

