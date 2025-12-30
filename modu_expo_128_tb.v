`timescale 1ns/1ns

module modu_expo_128_tb;

    parameter NLEN = 32;

    reg clk, strobe, rst_n;
    reg [NLEN-1:0] b;
    reg [NLEN-1:0] e;
    reg [NLEN-1:0] m;
    wire ready, busy;
    wire [NLEN-1:0] r;

    // Instantiate the module under test
    modu_expo_128 inst (
        .b(b), .e(e), .m(m), .r(r),
        .clk(clk), .strobe(strobe), .rst_n(rst_n),
        .ready(ready), .busy(busy)
    );

    initial begin
        // Initial reset and clock setup
        clk = 1;
        rst_n = 0;
        strobe = 0;

        #1 rst_n = 1; // Deassert reset

        // Encryption test
        b = 128'd179441695220040973036856247560209845703;
        e = 128'd78624383815806095082831236375207684303;
        m = 128'd291173165596690131543379395216261834371;

        #2 strobe = 1;
        #2 strobe = 0;

        wait (ready);  // Wait until operation is done

        // Decryption test
        b = 128'd212957456342734650649396939600336433714;
        e = 128'd232543530691965449749356023879307323711;

        #2 strobe = 1;
        #2 strobe = 0;

        wait (ready);  // Wait until done

        #800 $stop;
    end

    // Clock generation: 1ns high, 1ns low (2ns period = 500 MHz)
    always #1 clk = ~clk;

endmodule
