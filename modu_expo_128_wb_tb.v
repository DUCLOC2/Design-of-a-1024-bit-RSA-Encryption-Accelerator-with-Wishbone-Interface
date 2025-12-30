`timescale 1ns / 1ps

module modu_expo_128_wb_tb;

    parameter WIDTH = 128;

    reg clk, rst_n;
    reg [3:0] addr;
    reg [WIDTH-1:0] data_in;
    wire [WIDTH-1:0] data_out;
    reg we, stb, cyc;
    wire ack;

    // Instance DUT
    modu_expo_128_wb #(.WIDTH(WIDTH)) dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .addr    (addr),
        .data_in (data_in),
        .data_out(data_out),
        .we      (we),
        .stb     (stb),
        .cyc     (cyc),
        .ack     (ack)
    );

    // Clock gen
    initial clk = 0;
    always #5 clk = ~clk;

    //-----------------------------------------
    // Wishbone Tasks
    //-----------------------------------------
    task write_reg(input [3:0] address, input [WIDTH-1:0] value);
    begin
        @(posedge clk);
        addr    <= address;
        data_in <= value;
        we      <= 1; stb <= 1; cyc <= 1;
        @(posedge clk);
        while (!ack) @(posedge clk);
        we <= 0; stb <= 0; cyc <= 0;
    end
    endtask

    task read_reg(input [3:0] address, output [WIDTH-1:0] value);
    begin
        @(posedge clk);
        addr    <= address;
        we      <= 0; stb <= 1; cyc <= 1;
        @(posedge clk);
        while (!ack) @(posedge clk);
        value = data_out;
        stb <= 0; cyc <= 0;
    end
    endtask

    //-----------------------------------------
    // Run one modular exponentiation test
    //-----------------------------------------
    task run_modexp_test(
        input [WIDTH-1:0] base,
        input [WIDTH-1:0] exp,
        input [WIDTH-1:0] mod,
        input [WIDTH-1:0] expected
    );
    reg [WIDTH-1:0] val;
    begin
        // Load base, exp, mod
        write_reg(4'd0, base);
        write_reg(4'd1, exp);
        write_reg(4'd2, mod);

        // Start
        write_reg(4'd3, {{(WIDTH-1){1'b0}}, 1'b1});
        $display("Running test: base=%0d exp=%0d mod=%0d", base, exp, mod);

        // Wait for ready
        begin : wait_for_ready
            while (1) begin
                read_reg(4'd5, val);
                if (val[0] == 1'b1) disable wait_for_ready;
                @(posedge clk);
            end
        end

        // Read result
        read_reg(4'd4, val);
        $display("Result = %0d, Expected = %0d", val, expected);

        if (val == expected)
            $display("Test PASSED\n");
        else
            $display("Test FAILED\n");
    end
    endtask

    //-----------------------------------------
    // Stimulus
    //-----------------------------------------
    initial begin
        rst_n   = 0;
        addr    = 0;
        data_in = 0;
        we      = 0;
        stb     = 0;
        cyc     = 0;

        #20 rst_n = 1;

        // Test case 1: 4^13 mod 497 = 445
      //  run_modexp_test(128'd4, 128'd13, 128'd497, 128'd445);

        // Test case 2: 5^117 mod 19 = 1
   //     run_modexp_test(128'd5, 128'd117, 128'd19, 128'd1); //sai 

        // Test case 3: 7^256 mod 13 = 9
  //      run_modexp_test(128'd7, 128'd256, 128'd13, 128'd9);

        #100 $finish;
    end

endmodule
