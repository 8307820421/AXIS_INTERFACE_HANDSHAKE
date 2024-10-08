`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.08.2024 15:40:14
// Design Name: 
// Module Name: axis_write_interface
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

// here code will further edit as if (last byte transfered then t_last will active)
// when t_last active then the tready deasserted based upon the testbench.
module axis_write_interface #(
    parameter data_width = 512,
    parameter counter_width = 10, // AXI stream does not support address interface
    parameter mem_size_depth = 1024,
    parameter keep_width = data_width / 8
)(
    input wire axis_clk,
    input wire reset,

    // PCIe completer_request (m_axis_cq)_write_module
    input wire t_valid,
   // output reg t_ready,
    input wire [data_width-1:0] t_data,
    input wire t_last, // t_last is provided to signal the end of a packet
    input wire [keep_width-1:0] t_keep, 
    
    // BRAM interface Write Interface
    input wire [data_width - 1:0] bram_dout,
    output reg t_ready, // axis t_ready signal
    output reg [data_width-1:0] bram_data = 0,
    output reg bram_ena = 0,
    output reg [0:0]bram_wena = 0,
    output reg [counter_width-1:0] bram_address = 0
);

reg [counter_width - 1:0] address_counter = 0;
//reg[data_width - 1 :0 ] mem[0:mem_size_depth - 1];
reg [1:0] state = 0;
integer i;

always @(posedge axis_clk or posedge reset) begin
    if (reset) begin
        bram_ena <= 0;
        bram_wena <= 0;
        t_ready <= 1'b0;
        address_counter <= 0;
        bram_address <= address_counter;
        bram_data <= 0;
        bram_ena <= 0;
        bram_wena <= 0;
       
        state <= 0;
    end else begin
        case (state)
        0: begin // IDLE
                t_ready <= 1'b1; // Ready to accept data
                bram_ena <= 0;
                bram_wena <= 0;
                
                if (t_valid && t_ready) begin
                    state <= 1;
                end
                

        end
        
        1: begin // DATA
      
           bram_ena <= 1'b0;
            bram_wena <= 1'b0;
                if ((t_valid && t_ready)== 1'b1) begin
                         bram_ena <= 1'b1;
                         bram_wena <= 1'b0;
                     
                    if (address_counter < mem_size_depth) begin
                      
                        for (i = 0; i < keep_width; i = i + 1) begin
                        
                            if (t_keep[i]) begin // for 64 bytes valid // checking the byte by byte valid
                               bram_data[(i*8) +: 8] <= t_data[(i*8) +: 8]; // Write valid bytes 
                                address_counter <= address_counter + 1;
                                bram_address <= address_counter;
                                bram_wena <= 1'b1;  
                            end
                            
                            else  begin
                            bram_data[(i*8) +: 8]  <= 8'b0;
                           //bram_wena <= 1'b0;
                          end
                      end
                         
                 end
                 
                  if ((t_last==1'b1)||(address_counter == mem_size_depth))
                   begin
                    // Check for t_last to end the packet transfer
                   state <= 2; // Transition to FINISH state after receiving the last beat
                 end
            end
     end
        2: begin // FINISH
                t_ready <= 1'b0;
                bram_ena <= 0;
                bram_wena <= 0;
                address_counter <= 0;
                bram_address<= address_counter;
                
                if ( (t_valid && t_ready )== 1'b1 ) //
                begin
                state <= 2;
              end
              else begin //
              state <= 0;
              end
              
              end
        endcase
    end
    

end

assign bram_dout = (bram_address == mem_size_depth) ? bram_data :0;

endmodule


