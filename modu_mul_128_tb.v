`timescale 1ns / 1ps

module modu_mul_128_tb;

    parameter NLEN = 32;

    // Inputs
    reg clk;
    reg rst_n;
    reg strobe;
    reg [NLEN-1:0] x;
    reg [NLEN-1:0] y;
    reg [NLEN-1:0] m;

    // Outputs
    wire [NLEN-1:0] p;
    wire ready, busy;

    // Internal expected result
    reg [NLEN-1:0] expected;

    // Instantiate DUT
    modu_mul_128 uut (
        .clk(clk),
        .rst_n(rst_n),
        .strobe(strobe),
        .x(x),
        .y(y),
        .m(m),
        .p(p),
        .ready(ready),
        .busy(busy)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;  // 100MHz clock

    // Task to run one test case
    task run_test(
        input [NLEN-1:0] in_x,
        input [NLEN-1:0] in_y,
        input [NLEN-1:0] in_m,
        input [NLEN-1:0] expected_p
    );
    begin
        x = in_x;
        y = in_y;
        m = in_m;
        expected = expected_p;

        strobe = 1;
        #10;
        strobe = 0;

        wait (ready == 1);
        #10;

        if (p === expected) begin
            $display("[PASS] x=%0d, y=%0d, m=%0d => p=%0d", x, y, m, p);
        end else begin
            $display("[FAIL] x=%0d, y=%0d, m=%0d => p=%0d (expected %0d)", x, y, m, p, expected);
        end
    end
    endtask

    // Test procedure
    initial begin
        $display("Starting self-checking testbench...");
        rst_n = 0;
        strobe = 0;
        x = 0; y = 0; m = 0;
        #20;

        rst_n = 1;
        #10;
 // Test 2: (15 * 25) % 7 = 375 % 7 = 4
       run_test(32'd15, 32'd25, 32'd7, 32'd4);
        // Test 1: (5 * 13) % 17 = 65 % 17 = 14
        run_test(32'd5, 32'd13, 32'd17, 32'd14);
			
       

        // Test 3: (12345678 * 87654321) % 999999937
        // You can precompute this value externally:
        // 12345678 * 87654321 = 1082152022374638
        // 1082152022374638 % 999999937 = 242135169
       // run_test(128'd12345678, 128'd87654321, 128'd999999937, 128'd242135169);

        $display("All tests completed.");
        $finish;
    end

endmodule
