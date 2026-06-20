module Klein_KeySchedule (kstate, nkstate, round, is_fwd_key);
    input  wire [63:0] kstate;
    input  wire [3:0]  round;
    input  wire        is_fwd_key;
    
    output wire [63:0] nkstate;
    
    //STATE 1: Divide 2 tuples and Cycle left shift 1 byte (ENCRYPTION)
    wire [63:0] krot_enc = {kstate[55:32], kstate[63:56], kstate[23:0], kstate[31:24]};
    wire [63:0] kfei_enc;

    //STATE 2: Feistel-like structure (ENCRYPTION)
    assign kfei_enc[63:32] = krot_enc[31:00];
    assign kfei_enc[31:00] = krot_enc[63:32] ^ krot_enc[31:00];
    
    //STATE 3: S-box sk 5th and sk 6th (ENCRYPTION-DECRYPTION)
    wire [15:0] ks_sbox_in = is_fwd_key ? kfei_enc[23:8] : kstate[23:8];
    wire [15:0] ks_sbox_out;
    /////////////////////////////////////////////////////////////////
    Klein_Sbox sk0 (.in(ks_sbox_in[15:12]), .out(ks_sbox_out[15:12]));
    Klein_Sbox sk1 (.in(ks_sbox_in[11:08]), .out(ks_sbox_out[11:08]));
    /////////////////////////////////////////////////////////////////
    Klein_Sbox sk2 (.in(ks_sbox_in[7:4]),   .out(ks_sbox_out[7:4]));
    Klein_Sbox sk3 (.in(ks_sbox_in[3:0]),   .out(ks_sbox_out[3:0]));
   
     //STATE 3: (ENCRYPTION)
    wire [63:0] nkstate_enc;
    assign nkstate_enc[63:48] = kfei_enc[63:48];
    assign nkstate_enc[47:40] = kfei_enc[47:40] ^ {4'd0, round + 4'd1}; //sk 2th xor round counter i 

    assign nkstate_enc[39:24] = kfei_enc[39:24];
    assign nkstate_enc[23:8]  = ks_sbox_out; //S-box sk 5th and sk 6th 
    assign nkstate_enc[7:0]   = kfei_enc[7:0];
   
   //STATE 1: (DECRYPTION)
    wire [63:0] kfei_dec_pre;
    assign kfei_dec_pre[63:48] = kstate[63:48];
    assign kfei_dec_pre[47:40] = kstate[47:40] ^ {4'd0, round + 4'd1}; //sk 2th xor round counter i 
    assign kfei_dec_pre[39:24] = kstate[39:24];
    assign kfei_dec_pre[23:8]  = ks_sbox_out; //S-box sk 5th and sk 6th 
    assign kfei_dec_pre[7:0]   = kstate[7:0];
   
   //STATE 2: Feistel-like structure (DECRYPTION)
    wire [63:0] krot_dec;
    assign krot_dec[31:0]  = kfei_dec_pre[63:32];
    assign krot_dec[63:32] = kfei_dec_pre[63:32] ^ kfei_dec_pre[31:0];
   
    //STATE 3: Rotate (DECRYPTION)
    wire [63:0] nkstate_dec = {krot_dec[39:32], krot_dec[63:40], krot_dec[7:0], krot_dec[31:8]};
    
    //MUX : ENCRYPTION AND DECRYPTION 
    assign nkstate = is_fwd_key ? nkstate_enc : nkstate_dec;
endmodule