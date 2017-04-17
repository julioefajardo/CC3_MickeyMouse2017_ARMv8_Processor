`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:27:11 04/15/2017
// Design Name:   MM2017
// Module Name:   D:/Workspace_Xilinx/c/MickeyMickey2017/Testing.v
// Project Name:  MickeyMickey2017
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: MM2017
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Testing;

	// Inputs
	reg clk;
	reg rst;

	// Outputs
	wire [63:0] PC_out;

	// Instantiate the Unit Under Test (UUT)
	MM2017 mm2017 (
		.clk(clk), 
		.rst(rst), 
		.PC_out(PC_out)
	);
	
	always #1 clk=!clk;
	
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;

		// Wait 100 ns for global reset to finish
		#1;
      // Add stimulus here
		rst = 0;  
		
	end
      
endmodule

