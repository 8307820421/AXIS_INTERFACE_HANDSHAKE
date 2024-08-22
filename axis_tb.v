`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.08.2024 12:40:35
// Design Name: 
// Module Name: axis_tb
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

/*
Relationship between the t_valid and t_ready signal :

// 1) when tready is active after one clock edge (posedge or negedge deppend upon
//always block) 
// Data will start reading or writing after the ending of ready signal.

// 2) checking when t_valid andd t_tready active at the same time

*/
module axis_tb();

localparam new_data = 0;
localparam wait_for_slave = 1; // until slave tends to 1
localparam   wait_for_data = 0;
localparam   process_data = 0;

// state 
reg m_state = 0, s_state = 0;

// master nd slave decleration

reg [7:0] m_data;  // master data
reg [7:0]  s_data; // slave data
reg m_valid_out;   // valid signal
reg s_ready_out;   // ready signal
reg reset_n;
reg clk = 0;


// clk signal logic

always  #10 clk = ~clk;
initial begin
reset_n =  0;
repeat(10) @ (posedge clk); // repeat the clock cycle up to 10 posedge
reset_n = 1;
end

//master logic
always @(posedge clk) 
begin
if (reset_n == 1'b0) 
begin
m_data <= 0;
m_valid_out <= 0;
end
else begin

case(m_state) // master axis logic
new_data : begin
m_data <= $urandom_range(0,15);
m_valid_out <= 1'b1;
m_state <= wait_for_slave;
end

wait_for_slave :begin // slave axis statee

if(s_ready_out) begin //slave ready used as input 
m_state<=new_data;
m_valid_out <= 1'b0;
end

else begin
m_state <= wait_for_slave;
end

end

endcase
end
end

/////////////////////// slave logic

always@(posedge clk)
begin
  if(reset_n==1'b0)
    begin
    s_data     <= 0;
    s_ready_out <= 0;
    end
  else
   begin
    case(s_state)
    wait_for_data: 
        begin
            s_ready_out <= 1'b1;
            if(m_valid_out == 1'b1)
               begin
               s_state     <= process_data;
               s_ready_out <= 1'b0;
               s_data      <= m_data;
               end
            else
               s_state <= wait_for_data; 
        end
    process_data: 
        begin
            s_state <= wait_for_data;
            s_ready_out <= 1'b1; 
        end 
    endcase 
   end
end


//end
endmodule


