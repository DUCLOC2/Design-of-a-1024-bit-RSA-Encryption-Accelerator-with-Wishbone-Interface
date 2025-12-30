module modu_expo_128_wb #(
    parameter WIDTH = 128
)(
    input  wire             clk,
    input  wire             rst_n,

    // Wishbone bus
    input  wire             cyc,
    input  wire             stb,
    input  wire             we,
    input  wire [3:0]       addr,
    input  wire [WIDTH-1:0] data_in,
    output reg  [WIDTH-1:0] data_out,
    output reg              ack
);

    // Internal registers
    reg  [WIDTH-1:0] base_reg, exp_reg, mod_reg;
    reg              start_reg;

    // Wires to core
    wire [WIDTH-1:0] r_w;
    wire             ready_w, busy_w;

    reg              strobe_core;

    //---------------------------------------
    // Instance of modu_expo_128
    //---------------------------------------
    modu_expo_128 u_modexp (
        .b      (base_reg),
        .e      (exp_reg),
        .m      (mod_reg),
        .r      (r_w),
        .clk    (clk),
        .strobe (strobe_core),
        .rst_n  (rst_n),
        .ready  (ready_w),
        .busy   (busy_w)
    );

    //---------------------------------------
    // Wishbone FSM
    //---------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            base_reg   <= 0;
            exp_reg    <= 0;
            mod_reg    <= 0;
            start_reg  <= 0;
            strobe_core<= 0;
            ack        <= 0;
            data_out   <= 0;
        end else begin
            ack        <= 0;
            strobe_core<= 0;   // mặc định

            if (cyc && stb && !ack) begin
                ack <= 1;

                if (we) begin
                    // WRITE
                    case (addr)
                        4'd0: base_reg <= data_in;
                        4'd1: exp_reg  <= data_in;
                        4'd2: mod_reg  <= data_in;
                        4'd3: begin
                            start_reg   <= data_in[0];
                            if (data_in[0]) strobe_core <= 1; // tạo 1 chu kỳ start
                        end
                        default: ;
                    endcase
                end else begin
                    // READ
                    case (addr)
                        4'd4: data_out <= r_w;
                        4'd5: data_out <= { {WIDTH-1{1'b0}}, ready_w };
                        4'd6: data_out <= { {WIDTH-1{1'b0}}, busy_w  };
                        default: data_out <= 0;
                    endcase
                end
            end
        end
    end

endmodule
