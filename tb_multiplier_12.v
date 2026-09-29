//~ `New testbench
`timescale  1ns / 1ps

module tb_multiplier_12;

// multiplier_12 Parameters 10ns
parameter PERIOD  = 10;


// multiplier_12 Inputs
reg   clk                                  = 1 ;
reg   rst_n                                = 0 ;
reg   start                                = 0 ;
reg   [7:0]  activation                    = 0 ;
reg   [3:0]  weight                        = 0 ;

// multiplier_12 Outputs
wire  busy                                 ;
wire  done                                 ;
wire  [11:0]  product                      ;

integer i                                  ; 

initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
end

multiplier_12  u_multiplier_12 (
    .clk                     ( clk                ),
    .rst_n                   ( rst_n              ),
    .start                   ( start              ),
    .activation              ( activation  [7:0]  ),
    .weight                  ( weight      [3:0]  ),

    .busy                    ( busy               ),
    .done                    ( done               ),
    .product                 ( product     [11:0] )
);

initial
begin

    @(posedge rst_n);

    //=========================Test Case 1: 5 × 3 = 15====================================
    activation = 8'sd5;
    weight     = 4'sd3; 

    @(posedge clk);
    #1;
    #1;
    // check idle state
    if (busy !== 1'b0 || done !== 1'b0)
        $display("TEST 1 FAIL: DUT is not in IDLE state");

    // start the multiplication
    start      = 1'b1;
    @(posedge clk);
    
    start      = 1'b0;

    // Check 4 PROCESS cycles
    for (i = 0; i < 4; i = i + 1) begin
        @(posedge clk);
        #1;
        if (busy !== 1'b1 || done !== 1'b0)
            $display("TEST 1 FAIL: PROCESS cycle %0d timing error", i + 1);
    end
    // i = 4, PROCESS done, enter DONE state
    @(posedge clk);
    #1;

    // @(posedge clk), because of non‑blocking assignment
    wait(done == 1'b1 && busy == 1'b0);
    #1;
    
    if (product == 12'sd15)
        $display("TEST 1 PASS: %0d x %0d = %0d", $signed(activation), $signed(weight), $signed(product));
    else
        $display("TEST 1 FAIL: %0d x %0d = %0d, expected = 15",
                 $signed(activation), $signed(weight), $signed(product));

    
    @(posedge clk);
    #1;

    if (done !== 1'b0)
        $display("TEST 1 FAIL: done is not one-cycle pulse");

    //=========================Test Case 2: -5 × 3 = -15====================================
    @(posedge clk);
    activation = -8'sd5;
    weight     = 4'sd3; 

    @(posedge clk);
    #1;
    // check idle state
    if (busy !== 1'b0 || done !== 1'b0)
        $display("TEST 2 FAIL: DUT is not in IDLE state");


    start      = 1'b1;
    @(posedge clk);
   
    start      = 1'b0;

    // Check 4 PROCESS cycles
    for (i = 0; i < 4; i = i + 1) begin
        @(posedge clk);
        #1;

        if (busy !== 1'b1 || done !== 1'b0)
            $display("TEST 2 FAIL: PROCESS cycle %0d timing error", i + 1);
    end

     @(posedge clk);
    #1;   
    wait(done == 1'b1);
    #1;
    if (product == - 12'sd15)
        $display("TEST 2 PASS: %0d x %0d = %0d", $signed(activation), $signed(weight), $signed(product));
    else
        $display("TEST 2 FAIL: %0d x %0d = %0d, expected = -15",
                 $signed(activation), $signed(weight), $signed(product));
    
    @(posedge clk);
    #1;
    if (done !== 1'b0)
        $display("TEST 2 FAIL: done is not one-cycle pulse");

    // ====================================Test Case 3: -5 × -3 = 15====================================
    
    @(posedge clk);
    activation = -8'sd5;
    weight     = -4'sd3; 

    @(posedge clk);
    #1;
    // check idle state
    if (busy !== 1'b0 || done !== 1'b0)
        $display("TEST 3 FAIL: DUT is not in IDLE state");
    start      = 1'b1;

    @(posedge clk);
    start      = 1'b0;

    // Check 4 PROCESS cycles
    for (i = 0; i < 4; i = i + 1) begin
        @(posedge clk);
        #1;
        if (busy !== 1'b1 )
            $display("TEST 3 FAIL: PROCESS cycle %0d timing error", i + 1);
    end
    
    @(posedge clk);
    #1;
    wait(done == 1'b1);
    #1;
    if (product == 12'sd15)
        $display("TEST 3 PASS: %0d x %0d = %0d", $signed(activation), $signed(weight), $signed(product));
    else
        $display("TEST 3 FAIL: %0d x %0d = %0d, expected = 15",
                $signed(activation), $signed(weight), $signed(product));
    
    @(posedge clk);
    #1;
    if (done !== 1'b0)
        $display("TEST 3 FAIL: done is not one-cycle pulse");

    // ====================================Test Case 4: 0 × -3 = 0====================================
    @(posedge clk);
    activation = 8'sd0;
    weight     = -4'sd3; 

    @(posedge clk);
    #1;
    // check idle state
    if (busy !== 1'b0 || done !== 1'b0)
        $display("TEST 4 FAIL: DUT is not in IDLE state");
    start      = 1'b1;
    
    @(posedge clk);
    start      = 1'b0;

    // Check 4 PROCESS cycles
    for (i = 0; i < 4; i = i + 1) begin
        @(posedge clk);
        #1;
        if (busy !== 1'b1)
            $display("TEST 4 FAIL: PROCESS cycle %0d timing error", i + 1);
    end

    @(posedge clk);
    #1;
    wait(done == 1'b1);
    #1;
    if (product == 12'sd0)
        $display("TEST 4 PASS: %0d x %0d = %0d", $signed(activation), $signed(weight), $signed(product));
    else
        $display("TEST 4 FAIL: %0d x %0d = %0d, expected = 0", $signed(activation), $signed(weight), $signed(product));
    
    @(posedge clk);
    #1;
    if (done !== 1'b0)
        $display("TEST 4 FAIL: done is not one-cycle pulse");

    // ====================================Test Case 5: 127 × 7 = 889====================================
    @(posedge clk);
    activation = 8'sd127;
    weight     = 4'sd7;
    
    @(posedge clk);
    #1;
    // check idle state
    if (busy !== 1'b0 || done !== 1'b0)
        $display("TEST 5 FAIL: DUT is not in IDLE state");
    start      = 1'b1;

    @(posedge clk);
    start      = 1'b0;

    // Check 4 PROCESS cycles
    for (i = 0; i < 4; i = i + 1) begin
        @(posedge clk);
        #1;
        if (busy !== 1'b1)
            $display("TEST 5 FAIL: PROCESS cycle %0d timing error", i + 1);
    end

    @(posedge clk);
    #1;
    wait(done == 1'b1);
    #1;
    if (product == 12'sd889)
        $display("TEST 5 PASS: %0d x %0d = %0d", $signed(activation), $signed(weight), $signed(product));
    else
        $display("TEST 5 FAIL: %0d x %0d = %0d, expected = 889", $signed(activation), $signed(weight), $signed(product));
    
    @(posedge clk);
    #1;
    if (done !== 1'b0)
        $display("TEST 5 FAIL: done is not one-cycle pulse");

    // ====================================Test Case 6: -128 × -8 = 1024====================================
    @(posedge clk);
    activation = -8'sd128;
    weight     = -4'sd8; 

    @(posedge clk);
    #1;
    // check idle state
    if (busy !== 1'b0 || done !== 1'b0)
        $display("TEST 6 FAIL: DUT is not in IDLE state");
    start      = 1'b1;

    @(posedge clk);
    start      = 1'b0;
    
    // Check 4 PROCESS cycles
    for (i = 0; i < 4; i = i + 1) begin
        @(posedge clk);
        #1;
        if (busy !== 1'b1)
            $display("TEST 6 FAIL: PROCESS cycle %0d timing error", i + 1);
    end
    
    @(posedge clk);
    #1;
    wait(done == 1'b1);
    #1;
    if (product == 12'sd1024)
        $display("TEST 6 PASS: %0d x %0d = %0d", $signed(activation), $signed(weight), $signed(product));
    else
        $display("TEST 6 FAIL: %0d x %0d = %0d, expected = 1024", $signed(activation), $signed(weight), $signed(product));
    
    @(posedge clk);
    #1;
    if (done !== 1'b0)
        $display("TEST 6 FAIL: done is not one-cycle pulse");

    $finish;
end

endmodule
