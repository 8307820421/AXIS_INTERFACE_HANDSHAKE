`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.08.2024 15:40:45
// Design Name: 
// Module Name: axis_write_interface_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`define clk_period 10

module axis_write_interface_tb();



    // Parameters
    parameter data_width = 512;
    parameter counter_width = 10;
    parameter mem_size_depth = 1024;
    parameter keep_width = data_width / 8;

    // Inputs
    reg axis_clk;
    reg reset;
    reg t_valid;
    reg [data_width-1:0] t_data;
    reg t_last;
    reg [keep_width-1:0] t_keep;
    reg [data_width-1:0] bram_dout;

    // Outputs
    wire t_ready;
    wire bram_ena;
    wire [0:0] bram_wena;
    wire [counter_width-1:0] bram_address;
    wire [data_width-1:0] bram_data;

    // Instantiate the Unit Under Test (UUT)
    axis_write_interface #(
        .data_width(data_width),
        .counter_width(counter_width),
        .mem_size_depth(mem_size_depth),
        .keep_width(keep_width)
    ) dut (
        .axis_clk(axis_clk),
        .reset(reset),
        .t_valid(t_valid),
        .t_data(t_data),
        .t_last(t_last),
        .t_keep(t_keep),
        .bram_dout(bram_dout),
        .t_ready(t_ready),
        .bram_ena(bram_ena),
        .bram_wena(bram_wena),
        .bram_address(bram_address),
        .bram_data(bram_data)
    );

  integer i;
   always #10 axis_clk = ~axis_clk;
   
   // stimuli for input reg
   initial begin
 
   t_valid = 1'b0;
   t_data =  0;
   t_last = 1'b0;
   reset = 1'b1;
   t_keep = {keep_width{1'b0}};
   repeat(5) @(posedge axis_clk) ;
    
    // stimuli for high reset and t_valid
    reset = 1'b0; 
    for (i = 0; i<mem_size_depth ; i= i+1) // for indexing based on that data will go
    begin
    @(posedge axis_clk); // clk for loop
    
    // tvalid
    t_valid = 1'b1;
    t_keep[i] = {keep_width{1'b1}};
    t_data = $urandom;
    bram_dout = bram_data;
    //@(posedge axis_clk);  // clk for tvalid//tdta
    
    end 
   @(posedge axis_clk); // clk for entire loop
    
    t_last = 1'b1;
    @(posedge axis_clk); // clk for t_last
    
    t_last = 0;
    t_valid = 0;
    @(posedge axis_clk); // clk for deasserted the tlast and tvalid
      $finish;
  
   end

endmodule

    
// alternate approach//


//// Clock generation
////initial axis_clk = 1'b1;
//always #10 axis_clk = ~axis_clk;

//integer i;
// // Stimulus generation
//initial begin
//// Initialize inputs
//reset = 1;
//t_valid = 1'b0;
//t_last = 1'b0;
//t_keep = {keep_width{1'b0}};
//repeat(10) @(posedge axis_clk);

 
// for (i = 0; i<= (mem_size_depth-1) ; i= i+1) begin

//@(posedge axis_clk);
//reset = 0;
//t_valid = 1'b1;
//t_keep[i] = {keep_width{1'b1}} ; // based upon t_keep validity
//t_data = $random;
//t_last = 1'b0;


//@(posedge t_ready);
//t_last = 1'b0;

//@(negedge t_ready);
//t_valid= 1'b0;
//t_last = 1'b1;



//end
 
 
//end
        











