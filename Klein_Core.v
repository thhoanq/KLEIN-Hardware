module Klein_Full_Core (iclk, ireset, istart, iblock, ienc, ikey, oready, oblock);
    input   wire          iclk;
    input   wire          ireset;
    input   wire          istart;
    input   wire          ienc;
    input   wire  [63:0]  iblock;   
    input   wire  [63:0]  ikey;  
      
    output  wire          oready;   
    output  wire  [63:0]  oblock;  

    localparam S_IDLE  = 2'd0; 
    localparam S_SETUP = 2'd1; 
    localparam S_RUN   = 2'd2; 

    reg [1:0]   fsm_state;
    reg         ready_reg;
    reg [63:0]  result_reg;
    reg [3:0]   round;
    reg [63:0]  state, kstate;

    reg [63:0]  cached_k0;
    reg [63:0]  cached_k12;
    reg         k12_valid;

    wire [63:0] nstate, nkstate;

    assign oready = ready_reg;
    assign oblock = result_reg;

    Klein_Datapath datapath (
        .state  (state),
        .kstate (kstate),
        .ienc   (ienc),     
        .nstate (nstate)    
    );


    wire is_fwd_key = ienc | (fsm_state == S_SETUP);
    Klein_KeySchedule keyschedule (.kstate(kstate), .round(round), .is_fwd_key(is_fwd_key), .nkstate(nkstate));

    always @(posedge iclk) begin
        if (ireset) begin
            fsm_state   <= S_IDLE;
            ready_reg   <= 1'b0; 
            result_reg  <= 64'd0;
            round       <= 4'd0;
            state       <= 64'd0;
            kstate      <= 64'd0;
            cached_k0   <= 64'd0;
            cached_k12  <= 64'd0;
            k12_valid   <= 1'b0;
        end 
        else begin
            case (fsm_state)
                S_IDLE: begin
                    ready_reg <= 1'b0;
                    if (istart) begin
                        state <= iblock;
                        if (ikey != cached_k0 || !k12_valid) begin
                            cached_k0 <= ikey;
                            k12_valid <= 1'b0;
                            if (!ienc) begin
                                fsm_state <= S_SETUP;
                                round     <= 4'd0;
                                kstate    <= ikey;
                            end else begin
                                fsm_state <= S_RUN;
                                round     <= 4'd0;
                                kstate    <= ikey;
                            end
                        end 
                        else begin
                            fsm_state <= S_RUN;
                            if (ienc) begin
                                round  <= 4'd0;
                                kstate <= ikey;
                            end else begin
                                round  <= 4'd11;
                                kstate <= cached_k12; 
                            end
                        end
                    end
                end

                S_SETUP: begin
                    if (round < 4'd11) begin
                        round  <= round + 4'd1;
                        kstate <= nkstate; 
                    end 
                    else begin
                        cached_k12 <= nkstate; 
                        k12_valid  <= 1'b1;   
                        fsm_state  <= S_RUN;
                        round      <= 4'd11;    
                        kstate     <= nkstate;
                    endz
                end

                S_RUN: begin
                    state  <= nstate;
                    kstate <= nkstate; 
                    
                    if (ienc) begin
                        if (round < 4'd11) round <= round + 4'd1;
                        else begin
                            result_reg <= nstate ^ nkstate;
                            cached_k12 <= nkstate; 
                            k12_valid  <= 1'b1;   
                            ready_reg  <= 1'b1;
                            fsm_state  <= S_IDLE;
                        end
                    end 
                    else begin
                        if (round > 4'd0) round <= round - 4'd1;
                        else begin
                            result_reg <= nstate ^ nkstate;
                            ready_reg  <= 1'b1;
                            fsm_state  <= S_IDLE;
                        end
                    end
                end
            endcase
        end
    end
endmodule