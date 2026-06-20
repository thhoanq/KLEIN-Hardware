module Klein_Mixnibbles(idata, iinv, odata);
    input       wire    [31:0]   idata;
    input       wire             iinv;
    output      wire    [31:0]   odata;


////////////////////////////////////////////////////////////////////////
function [7 : 0] gm2(input [7 : 0] op);
  begin
    gm2 = {op[6:4], op[3]^op[7], op[2]^op[7], op[1], op[0]^op[7], op[7]}; //
  end
endfunction // gm2
////////////////////////////////////////////////////////////////////////


function [7 : 0] gm4(input [7 : 0] op);
  begin
    gm4 = gm2(gm2(op));
  end
endfunction // gm4

wire [7:0] w0, w1, w2, w3;    // data in
wire [7:0] a0, a1, a2, a3;    // mix data
wire [7:0] b0, b1, b2, b3;    // inv mix data

assign w0 = idata[31:24];
assign w1 = idata[23:16];
assign w2 = idata[15:08];
assign w3 = idata[07:00];

///////////////////////////////////////
wire [7:0] sum = w0 ^ w1 ^ w2 ^ w3;

assign a0 = gm2(w0 ^ w1) ^ sum ^ w0;
assign a1 = gm2(w1 ^ w2) ^ sum ^ w1;
assign a2 = gm2(w2 ^ w3) ^ sum ^ w2;
assign a3 = gm2(w3 ^ w0) ^ sum ^ w3;
/////////////////////////////////////


assign b0 = gm4(a0 ^ a2) ^ a0;
assign b1 = gm4(a1 ^ a3) ^ a1;
assign b2 = gm4(a0 ^ a2) ^ a2;
assign b3 = gm4(a1 ^ a3) ^ a3;

assign odata = (iinv) ? {b0, b1, b2, b3} : {a0, a1, a2, a3};

endmodule
