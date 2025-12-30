module modu_expo_128 (
    b, e, m, r, clk, strobe, rst_n,
    ready, busy
);
    parameter NLEN = 32;

    input clk, strobe, rst_n;
    input [NLEN-1:0] b;
    input [NLEN-1:0] e;
    input [NLEN-1:0] m;

    output reg ready, busy;
    output [NLEN-1:0] r; // r = b^e % m

    wire ready_r, ready_b;
    wire busy_r, busy_b;
    wire [NLEN-1:0] p_r;
    wire [NLEN-1:0] p_b;

    reg strobe_r, strobe_b;
    reg state;
    reg [NLEN-1:0] b_reg;
    reg [NLEN-1:0] e_reg;
    reg [NLEN-1:0] m_reg;
    reg [NLEN-1:0] r_reg;

    assign r = r_reg;

    // Multiply: r_reg * b_reg % m_reg
    modu_mul_128 res (
        .x(r_reg), .y(b_reg), .m(m_reg), .p(p_r),
        .clk(clk), .strobe(strobe_r), .rst_n(rst_n),
        .ready(ready_r), .busy(busy_r)
    );

    // Square: b_reg * b_reg % m_reg
    modu_mul_128 bas (
        .x(b_reg), .y(b_reg), .m(m_reg), .p(p_b),
        .clk(clk), .strobe(strobe_b), .rst_n(rst_n),
        .ready(ready_b), .busy(busy_b)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            b_reg <= 0;
            e_reg <= 0;
            m_reg <= 0;
            r_reg <= 0;
            busy <= 0;
            ready <= 0;
            state <= 0;
        end else begin
            ready <= 0;
            strobe_r <= 0;
            strobe_b <= 0;

            if (strobe) begin
                b_reg <= b;
                e_reg <= e;
                m_reg <= m;
                r_reg <= 1;
                busy <= 1;
                ready <= 0;
                state <= 0;
            end else begin
                if (busy) begin
                    if ((e_reg == 1) && ready_r) begin
                        ready <= 1;
                        busy <= 0;
                        r_reg <= p_r;
                    end else begin
                        case (state)
                            0: begin // Multiply step
                                if (~busy_r && ~ready_r) begin
                                    if (e_reg[0]) begin
                                        if (~strobe_r)
                                            strobe_r <= 1;
                                        else
                                            strobe_r <= 0;
                                    end
                                end
                                state <= 1;
                            end
                            1: begin // Square step
                                if (~busy_b && ~ready_b) begin
                                    if (~strobe_b)
                                        strobe_b <= 1;
                                    else
                                        strobe_b <= 0;
                                end
                                if (ready_b) begin
                                    b_reg <= p_b;
                                    e_reg <= {1'b0, e_reg[NLEN-1:1]};
                                    state <= 0;
                                end
                                if (ready_r) begin
                                    r_reg <= p_r;
                                end
                            end
                        endcase
                    end
                end
            end
        end
    end

endmodule
