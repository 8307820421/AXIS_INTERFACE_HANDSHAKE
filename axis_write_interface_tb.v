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

 


     
     initial
     axis_clk = 1'b1;
    // Clock generation
    always #(`clk_period/2) axis_clk = ~axis_clk;
    
    integer i;
    // Stimulus generation
    initial begin
        // Initialize inputs
        axis_clk = 0;
        reset = 1;
        t_valid = 0;
        t_data = 0;
        t_last = 0;
        t_keep = 0;
        bram_dout = 0;
        // Apply reset
       repeat(3) @(posedge axis_clk);
       
        reset = 0;
        // do not specify the clk here or repeating the clock here as it reset will be 0 (as per current situation)
        /*  based upon need you can again set the reset high  */
        
        // Test stimulus
         t_valid = 1;
         
         
         
        // Apply `t_keep` logic and move `t_data` to `bram_data`
        for (i = 0; i <= counter_width - 1; i = i + 1) begin
            t_keep = {keep_width{1'b1}} << i; // Shift t_keep bits to represent varying valid byte lanes

            // Assign bram_dout based on t_keep
            if (t_keep[i]) begin
                t_data = $random;   /// some random data coming
            end

            @(posedge axis_clk); //2

            // Set t_last on the last cycle
            if (i == counter_width - 1) begin
                t_last <= 1'b1;
            end 
            
        end
     
        // End the transfer
        
        t_valid = 0;
         @(posedge axis_clk); //2
        
         t_last = 0;
         @(posedge axis_clk); //2
        // End simulation
       // #100;
         
         
         

        $finish;
    end

endmodule

    
    
        







// This is another way to give data depends upon user: 

  // Clock generation
  /*  initial begin
        axis_clk = 0;
        forever #5 axis_clk = ~axis_clk; // 100 MHz clock (10ns period)
    end

    // Test stimulus
    initial begin
        // Initialize inputs
        reset = 1;
        t_valid = 0;
        t_data = 0;
        t_last = 0;
        t_keep = 0;
        bram_dout = 0;

        // Apply reset
        #20;  // Hold reset for 2 clock cycles
        reset = 0;

        // Test case 1: Write a single packet with all bytes valid
        @(posedge axis_clk);
        t_valid = 1;
        t_data = 512'hAABBCCDDEEFF00112233445566778899AABBCCDDEEFF00112233445566778899AABBCCDDEEFF00112233445566778899AABBCCDDEEFF00112233445566778899;
        t_keep = {keep_width{1'b1}};
        t_last = 0;

        @(posedge axis_clk);
        t_valid = 1;
        t_data = 512'h11223344556677889900AABBCCDDEEFF00112233445566778899AABBCCDDEEFF00112233445566778899AABBCCDDEEFF00112233445566778899AABBCCDDEEFF;
        t_last = 0; // Indicate this is the last beat of the packet

        @(posedge axis_clk);
        t_valid = 0;
        t_data = 0;
        t_keep = 0;
        t_last = 0;

        // Wait for some time
        #100;

        // Test case 2: Write a packet with partial valid bytes
        @(posedge axis_clk);
        t_valid = 1;
        t_data = 512'hFFEEDDCCBBAA99887766554433221100FFEEDDCCBBAA99887766554433221100FFEEDDCCBBAA99887766554433221100FFEEDDCCBBAA99887766554433221100;
        t_keep = 64'hFFFFFFFF00000000; // Only the first half of the data is valid
        t_last = 1; // Indicate this is the last beat of the packet

        @(posedge axis_clk);
        t_valid = 0;
        t_data = 0;
        t_keep = 0;
        t_last = 0;

        // Wait for some time
        #100;

        // Test case 3: Write a packet with a single valid byte
        @(posedge axis_clk);
        t_valid = 1;
        t_data = 512'h11223344556677889900AABBCCDDEEFF00112233445566778899AABBCCDDEEFF00112233445566778899AABBCCDDEEFF00112233445566778899AABBCCDDEEFF;
        t_keep = 64'h0000000000000001; // Only the first byte is valid
        t_last = 1; // Indicate this is the last beat of the packet

        @(posedge axis_clk);
        t_valid = 0;
        t_data = 0;
        t_keep = 0;
        t_last = 0;

        // Wait for some time
        #100;

        $stop;
    end   */
    
    



