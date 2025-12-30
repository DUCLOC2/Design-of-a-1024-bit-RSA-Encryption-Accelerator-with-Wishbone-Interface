module modu_mul_128 (
    x, y, m, p, clk, strobe, rst_n,
    ready, busy
);
    parameter NLEN = 32;

    input clk, strobe, rst_n;
    input [NLEN-1:0] x;
    input [NLEN-1:0] y;
    input [NLEN-1:0] m;

    output reg ready, busy;
    output [NLEN-1:0] p; // p = (x * y) % m

    reg [NLEN+1:0] x_reg;
    reg [NLEN-1:0] y_reg;
    reg [NLEN+1:0] m_reg;
    reg [NLEN+1:0] p_reg;

    wire [NLEN+1:0] x1, x2;
    wire [NLEN+1:0] p1, p2, p3;

    assign p = p3[NLEN-1:0];
    assign p1 = y_reg[0] ? (p_reg + x_reg) : p_reg;
    assign p2 = p1 - m_reg;
    assign p3 = p2[NLEN+1] ? p1 : p2;
    assign x1 = {x_reg[NLEN:0], 1'b0} - m_reg;
    assign x2 = x1[NLEN+1] ? {x_reg[NLEN:0], 1'b0} : x1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x_reg <= 0;
            y_reg <= 0;
            m_reg <= 0;
            p_reg <= 0;
            busy <= 0;
            ready <= 0;
        end else begin
            ready <= 0;
            if (strobe) begin
                x_reg <= {2'b00, x};
                y_reg <= y;
                m_reg <= {2'b00, m};
                p_reg <= 0;
                busy <= 1;
            end else begin
                if (busy) begin
                    if (y_reg == 0) begin
                        ready <= 1;
                        busy <= 0;
                    end else begin
                        x_reg <= x2;
                        y_reg <= {1'b0, y_reg[NLEN-1:1]};
                        p_reg <= p3;
                    end
                end
            end
        end
    end

endmodule
