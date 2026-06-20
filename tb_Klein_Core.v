`timescale 1ns / 1ps

module tb_Klein_Core;

    parameter CLK_HALF_PERIOD = 5;
    parameter CLK_PERIOD      = 2 * CLK_HALF_PERIOD;

    reg          tb_iclk;
    reg          tb_ireset;
    reg          tb_istart;
    reg          tb_ienc;
    reg  [63:0]  tb_iblock;
    reg  [63:0]  tb_ikey;

    wire         tb_oready;
    wire [63:0]  tb_oblock;

    Klein_Full_Core dut (
        .iclk(tb_iclk),
        .ireset(tb_ireset),
        .istart(tb_istart),
        .ienc(tb_ienc),
        .iblock(tb_iblock),
        .ikey(tb_ikey),
        .oready(tb_oready),
        .oblock(tb_oblock)
    );

   
    always #CLK_HALF_PERIOD tb_iclk = ~tb_iclk;

    task run_test;
        input [63:0]  t_key;
        input [63:0]  t_in;
        input [63:0]  t_expected;
        input         t_is_enc;
        
        begin
            tb_ikey   = t_key;
            tb_iblock = t_in;
            tb_ienc   = t_is_enc;

            tb_istart = 1'b1;
            #(CLK_PERIOD);
            tb_istart = 1'b0;

            wait(tb_oready);
            
            if (tb_oblock === t_expected) begin
                $display("[PASS] %s", t_is_enc ? "ENCRYPT" : "DECRYPT");
                $display("   Key : %16h | In : %16h | Out : %16h", t_key, t_in, tb_oblock);
            end else begin
                $display("[FAIL] %s", t_is_enc ? "ENCRYPT" : "DECRYPT");
                $display("   Key : %16h | In : %16h", t_key, t_in);
                $display("   Exp : %16h | Got: %16h  <-- ERROR", t_expected, tb_oblock);
            end
            $display("\n");
            
            #(3 * CLK_PERIOD);
        end
    endtask

 
    initial begin
        tb_iclk   = 0;
        tb_ireset = 1;
        tb_istart = 0;
        tb_ienc   = 1;
        tb_iblock = 64'd0;
        tb_ikey   = 64'd0;

        #(4 * CLK_PERIOD);
        tb_ireset = 0;
        #(2 * CLK_PERIOD);


        // --- VECTOR 1 ---
        run_test(64'h0000000000000000, 64'hFFFFFFFFFFFFFFFF, 64'hCDC0B51F14722BBE, 1); // ENCRYPTION 
        run_test(64'h0000000000000000, 64'hCDC0B51F14722BBE, 64'hFFFFFFFFFFFFFFFF, 0); // DECRYPTION

        // --- VECTOR 2 ---
        run_test(64'hFFFFFFFFFFFFFFFF, 64'h0000000000000000, 64'h6456764E8602E154, 1); // ENCRYPTION
        run_test(64'hFFFFFFFFFFFFFFFF, 64'h6456764E8602E154, 64'h0000000000000000, 0); // DECRYPTION

        // --- VECTOR 3 ---
        run_test(64'h1234567890ABCDEF, 64'hFFFFFFFFFFFFFFFF, 64'h592356C4997176C8, 1); // ENCRYPTION
        run_test(64'h1234567890ABCDEF, 64'h592356C4997176C8, 64'hFFFFFFFFFFFFFFFF, 0); // DECRYPTION

        // --- VECTOR 4 ---
        run_test(64'h0000000000000000, 64'h1234567890ABCDEF, 64'h629F9D6DFF95800E, 1); // ENCRYPTION
        run_test(64'h0000000000000000, 64'h629F9D6DFF95800E, 64'h1234567890ABCDEF, 0); // DECRYPTION
        
        $finish;
    end

endmodule