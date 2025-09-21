module first_layer_tb;
// Parameters
parameter imgSize = 256*256;
parameter imgDepth = 1;
parameter depth = 256;
// Testbench signals
reg clk;
reg rst;
reg start;
reg done_i;
wire [25:0] out;
wire done_o;
// File pointer and counter
integer outfile;
integer count = 0;
// Instantiate the DUT (Device Under Test)
first_layer #(imgDepth, depth, imgSize) DUT (
.clk(clk),
.rst(rst),
.done_i(done_i),
.start(start),
.out(out),
.done_o(done_o)
);
// Clock Generation: 10 ns period (100 MHz)
always #5 clk = ~clk;
// Test Procedure
initial begin
// Initialize signals
clk = 1;
rst = 1;
start = 0;
done_i = 0;
// Open output file
outfile = $fopen("sharp.txt", "w");
// Apply reset
#10 rst = 0;
// Start the module
#10 start = 1;
#10 start = 0;
#10 done_i = 1;
// Let the simulation run for enough time to write all outputs
#(256*256*1*10 + 2700); // 10 ns per clock cycle
#10 done_i = 0;
// End simulation
$display("Total values written: %0d", count);
$fclose(outfile);
$finish;
end
// Monitor outputs (optional)
initial begin
$monitor("Time=%0t | Out=%b | Done=%b", $time, out, done_o);
end
// Write output at each clock edge if done_o and done_i are high
always @(posedge clk) begin
if (done_i && done_o) begin
$fwrite(outfile, "%b\n", out);
count = count + 1;
end
end
endmodule

////////////////////////////////complete testbench////////////////////////////////////////////////////////////
module cnn_first_layer_top_tb;
parameter imgDepth = 2;//number of kernels
parameter depth = 128;//number of pixels in single row of image
parameter imgSize = 128*128;
parameter DATA_WIDTH = 26;
parameter BUFFER_DEPTH = 6;
parameter CHUNK_SIZE = 128*128;//same as image size
parameter NUM_PORTS = 2;//same as imgDepth
parameter DEPTH = CHUNK_SIZE * NUM_PORTS * 4;
parameter ADDR_WIDTH = 31;
reg clk = 0;
reg rst;
// reg done_i1, done_i2;
// reg start1, start2;
// reg wr_en, rd_en;
wire [42:0] maxpool_out;
wire done_o1;
wire signed [25:0] relu_out_1;
wire control; // Must be exposed from DUT
wire done_i1;
// File descriptors
integer f_relu1, f_maxpool;
// Instantiate DUT
temp_top_first_second #(
.imgDepth(imgDepth),
.depth(depth),
.imgSize(imgSize),
.DATA_WIDTH(DATA_WIDTH),
.BUFFER_DEPTH(BUFFER_DEPTH),
.CHUNK_SIZE(CHUNK_SIZE),
.NUM_PORTS(NUM_PORTS),
.DEPTH(DEPTH),
.ADDR_WIDTH(ADDR_WIDTH)
) dut (
.clk(clk),
.rst(rst),
// .done_i1(done_i1),
// .done_i2(done_i2),
// .start1(start1),
// .start2(start2),
// .wr_en(wr_en),
// .rd_en(rd_en),
.maxpool_out(maxpool_out),
.relu_out_1(relu_out_1),
.done_o1(done_o1),
.control(control)
);
assign done_i1 = dut.done_i1;
// Clock generation
always #5 clk = ~clk; // 100MHz
// initial begin
// // Initialization
// rst = 1;
// start1 = 0;
// start2 = 0;
// wr_en = 0;
// rd_en = 0;
// done_i1 = 0;
// done_i2 = 0;
// // Apply reset
// #10 rst = 0;
// // --------------------
// // Phase 1: First Layer
// // --------------------
// #10 start1 = 1; // Start first layer
// #10 start1 = 0;
// #10;
// repeat (57) begin // simulate output write from first_layer
// done_i1 = 1;
// if(done_i1 && done_o1) begin
// wr_en = 1;
// end
// #10;
// end
// done_i1 = 0;
// wr_en = 0;
// // Optional swap (if ping-pong buffer used internally)
// // ---------------------
// // Phase 2: Second Layer
// // ---------------------
// #10 start2 = 1; // Start second layer
// #10 start2 = 0;
// rd_en = 1;
// #10;
// repeat (57) begin // simulate reading from inter_buffer
// done_i2 = 1;
// #10;
// end
// done_i2 = 0;
// rd_en = 0;
// // Finish
// #50;
// $finish;
// end
always @(posedge clk) begin
if (done_i1 && done_o1)
$fwrite(f_relu1, "%b\n", relu_out_1); // add \n explicitly
//if (done_i2 && done_o2)
//$fwrite(f_relu2, "%b\n", relu_out_2); // add \n explicitly
if (control)
$fwrite(f_maxpool, "%b\n", maxpool_out); // add \n explicitly
end
initial begin
rst = 1;
#10 rst = 0;
f_relu1 = $fopen("relu_out_1.txt", "w");
//f_relu2 = $fopen("relu_out_2.txt", "w");
f_maxpool = $fopen("maxpool_out.txt", "w");
#(512*512*50);
$fclose(f_relu1);
//$fclose(f_relu2);
$fclose(f_maxpool);
$finish;
end
endmodule
