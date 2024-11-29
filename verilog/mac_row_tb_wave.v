
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

// Internal wires to monitor
wire [(col+1)*bw-1:0] temp;
wire [(col+1)*2-1:0] inst_temp;

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
    in_n = {col{16'h0000}};

    // Apply reset
    #10;
    reset = 0;

    // Load weights
    #10;
    inst_w = 2'b01; // Kernel loading
    in_w = 4'b1010; // Example weight: -6
    in_n = {col{16'h0000}}; // Partial sums set to 0

    #10;
    inst_w = 2'b00; // Disable instructions

    // Perform MAC operations
    #10;
    inst_w = 2'b10; // Execution
    in_w = 4'b0101; // Example activation: 5
    in_n = {col{16'h000A}}; // Partial sum: 10

    #20;
    inst_w = 2'b00; // Disable instructions

    // End simulation
    #50;
    $stop;
end

// Monitor critical signals
initial begin
    $monitor("Time=%0t | in_w=%b | inst_w=%b | in_n=%h | temp=%h | inst_temp=%b | out_s=%h | valid=%b", 
             $time, in_w, inst_w, in_n, dut.temp, dut.inst_temp, out_s, valid);
end

endmodule
