`timescale 1ns / 1ps

module mac_tile_tb;

parameter bw = 4;
parameter psum_bw = 16;

// Testbench signals
reg clk;
reg reset;
reg [bw-1:0] in_w;
reg [1:0] inst_w;
reg [psum_bw-1:0] in_n;

wire [psum_bw-1:0] out_s;
wire [bw-1:0] out_e;
wire [1:0] inst_e;

// Instantiate the DUT (Device Under Test)
mac_tile #(.bw(bw), .psum_bw(psum_bw)) dut (
    .clk(clk),
    .out_s(out_s),
    .in_w(in_w),
    .out_e(out_e),
    .in_n(in_n),
    .inst_w(inst_w),
    .inst_e(inst_e),
    .reset(reset)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10ns clock period
end

// Test sequence
initial begin
    // Initialize inputs
    reset = 1;
    in_w = 0;
    inst_w = 2'b00;
    in_n = 0;

    // Apply reset
    #10;
    reset = 0;

    // Load weight
    #10;
    inst_w = 2'b01; // Set load weight instruction
    in_w = 4'b1101; // Example weight: -3 (signed 4-bit)
    in_n = 16'h0000;

    #10;
    inst_w = 2'b00; // Disable instructions

    // Perform MAC operation
    #10;
    inst_w = 2'b10; // Set execute instruction
    in_w = 4'b0101; // Example activation: 5 (signed 4-bit)
    in_n = 16'h000A; // Example partial sum: 10 (signed 16-bit)

    #10;
    inst_w = 2'b00; // Disable instructions

    // Observe outputs
    #20;
    $display("Output South (out_s): %h", out_s);
    $display("Output East (out_e): %h", out_e);
    $display("Instruction Out (inst_e): %b", inst_e);

    // Check results
    if (out_s !== ((5 * -3) + 10)) begin
        $display("TEST FAILED: Incorrect MAC calculation.");
    end else begin
        $display("TEST PASSED: Correct MAC calculation.");
    end

    // End simulation
    #10;
    $stop;
end

endmodule
