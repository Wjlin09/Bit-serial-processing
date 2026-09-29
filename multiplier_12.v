module multiplier_12 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,

    input  wire signed [7:0]  activation,
    input  wire signed [3:0]  weight,

    output reg         busy,
    output reg         done,
    output reg signed [11:0] product
);

    // Input registers
    reg signed [7:0] activation_reg;
    reg signed [3:0] weight_reg;

    // Accumulator
    reg signed [11:0] accumulator;

    // Bit counter: 0, 1, 2, 3
    reg [1:0] bit_count;

    // FSM states
    reg [1:0] state, next_state;
    localparam IDLE    = 2'b00;
    localparam PROCESS = 2'b01;
    localparam DONE    = 2'b10;

    // =========================================
    // Combinational Logic
    // Current weight bit
    wire current_bit;
    assign current_bit = weight_reg[bit_count];

    // Sign-extended activation
    wire signed [11:0] activation_ext;
    assign activation_ext = {{4{activation_reg[7]}}, activation_reg};

    // Partial product
    wire signed [11:0] partial_product;

    assign partial_product =
        (current_bit) ?
        (
            (bit_count == 2'd3) ?
            -(activation_ext <<< 3) :
            (activation_ext <<< bit_count)
        ) :
        12'sd0;
    
    // =========================================
    // FSM: Next-State Logic状态转换
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start)
                    next_state = PROCESS;
            end

            PROCESS: begin
                if (bit_count == 2'd3)
                    next_state = DONE;
            end

            DONE: begin
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // =========================================
    // Sequential Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
        begin
            state          <= IDLE;
            activation_reg <= 8'sd0;
            weight_reg     <= 4'sd0;
            accumulator    <= 12'sd0;
            bit_count      <= 2'd0;
            busy           <= 1'b0;
            done           <= 1'b0;
            product        <= 12'sd0;
        end

        else begin
            state <= next_state;
            done <= 1'b0;
            case (state)

                // IDLE
                IDLE:begin
                    busy <= 1'b0;
                    if (start) begin
                        activation_reg <= activation;
                        weight_reg     <= weight;
                        accumulator <= 12'sd0;
                        bit_count <= 2'd0;
                        busy <= 1'b1;
                    end
                end
                // PROCESS
                PROCESS: begin
                    busy <= 1'b1;
                    accumulator <= accumulator + partial_product;

                    if (bit_count == 2'd3) begin
                        // Final result
                        product <= accumulator + partial_product;
                    end
                    else begin
                        bit_count <= bit_count + 1'b1;
                    end
                end
                // DONE
                DONE: begin
                    busy <= 1'b0;
                    done <= 1'b1;
                end
                default: begin
                    busy <= 1'b0;
                    done <= 1'b0;
                end

            endcase
        end
    end




endmodule