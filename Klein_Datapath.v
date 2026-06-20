module Klein_Datapath (
    input  wire [63:0] state,
    input  wire [63:0] kstate,
    input  wire        ienc,   
    output wire [63:0] nstate
);

    wire [63:0] ssum = state ^ kstate;

 
    wire [63:0] srot_dec; 

    wire [63:0] sbox_in = ienc ? ssum : srot_dec; 
    wire [63:0] sbox_out;

    Klein_Sbox s1  (.in(sbox_in[63:60]), .out(sbox_out[63:60]));
    Klein_Sbox s2  (.in(sbox_in[59:56]), .out(sbox_out[59:56]));
    Klein_Sbox s3  (.in(sbox_in[55:52]), .out(sbox_out[55:52]));
    Klein_Sbox s4  (.in(sbox_in[51:48]), .out(sbox_out[51:48]));
    Klein_Sbox s5  (.in(sbox_in[47:44]), .out(sbox_out[47:44]));
    Klein_Sbox s6  (.in(sbox_in[43:40]), .out(sbox_out[43:40]));
    Klein_Sbox s7  (.in(sbox_in[39:36]), .out(sbox_out[39:36]));
    Klein_Sbox s8  (.in(sbox_in[35:32]), .out(sbox_out[35:32]));
    Klein_Sbox s9  (.in(sbox_in[31:28]), .out(sbox_out[31:28]));
    Klein_Sbox s10 (.in(sbox_in[27:24]), .out(sbox_out[27:24]));
    Klein_Sbox s11 (.in(sbox_in[23:20]), .out(sbox_out[23:20]));
    Klein_Sbox s12 (.in(sbox_in[19:16]), .out(sbox_out[19:16]));
    Klein_Sbox s13 (.in(sbox_in[15:12]), .out(sbox_out[15:12]));
    Klein_Sbox s14 (.in(sbox_in[11:08]), .out(sbox_out[11:08]));
    Klein_Sbox s15 (.in(sbox_in[07:04]), .out(sbox_out[07:04]));
    Klein_Sbox s16 (.in(sbox_in[03:00]), .out(sbox_out[03:00]));

    
    wire [63:0] srot_enc = {sbox_out[47:0], sbox_out[63:48]};

    wire [63:0] mix_in = ienc ? srot_enc : ssum;
    wire [63:0] mix_out;

    Klein_Mixnibbles mix1(.idata(mix_in[63:32]), .iinv(!ienc), .odata(mix_out[63:32]));
    Klein_Mixnibbles mix2(.idata(mix_in[31:00]), .iinv(!ienc), .odata(mix_out[31:00]));

    assign srot_dec = {mix_out[15:0], mix_out[63:16]};

    assign nstate = ienc ? mix_out : sbox_out;

endmodule