
`timescale 1ns / 1ps

module mac_row_tb;

parameter bw = 4;
parameter psum_bw = 16;
parameter col = 8;

// Testbench signals
reg clk;
reg reset;
reg [bw-1:0] in_w;
reg [1:0] inst_w;
reg [psum_bw*col-1:0] in_n;

wire [psum_bw*col-1:0] out_s;
wire [col-1:0] valid;

// Instantiate the DUT (Device Under Test)
mac_row #(.bw(bw), .psum_bw(psum_bw), .col(col)) dut (
    .clk(clk),
    .reset(reset),
    .in_w(in_w),
    .inst_w(inst_w),
    .in_n(in_n),
    .out_s(out_s),
    .valid(valid)
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

    // Load weight into each column
    #10;
    inst_w = 2'b01; // Set load weight instruction
    in_w = 4'b1101; // Example weight: -3 (signed 4-bit)
    in_n = {col{16'h0000}}; // Initialize partial sum input to 0

    #10;
    inst_w = 2'b00; // Disable instructions

    // Perform MAC operation for all columns
    #10;
    inst_w = 2'b10; // Set execute instruction
    in_w = 4'b0101; // Example activation: 5 (signed 4-bit)
    in_n = {col{16'h000A}}; // Example partial sum: 10 (signed 16-bit)

    #10;
    inst_w = 2'b00; // Disable instructions

    // Observe outputs
    #20;
    $display("Output South (out_s): %h", out_s);
    $display("Valid signals: %b", valid);

    // Check results for first column
    if (out_s[psum_bw-1:0] !== ((5 * -3) + 10)) begin
        $display("TEST FAILED: Incorrect MAC calculation for column 1.");
    end else begin
        $display("TEST PASSED: Correct MAC calculation for column 1.");
    end

    // End simulation
    #10;
    $stop;
end

endmodule
