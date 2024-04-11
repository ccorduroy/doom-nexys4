//////////////////////////////////////////////////////////////////////////////////
// Author:			Shideh Shahidi, Bilal Zafar, Gandhi Puvvada
// Create Date:   02/25/08, 10/13/08
// File Name:		ee201_GCD_tb.v 
// Description: 
//
//
// Revision: 		2.1
// Additional Comments:  
// 10/13/2008 Clock Enable (CEN) has been added by Gandhi
// 3/1/2010 Signal names are changed in line with the divider_verilog design
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps // First parameter is the time unit for #[number] calls
// Second parameter is the accuracy/precision of this time scale

// No inputs and outputs bc DUT (design under test) is inside the testbench
module Doom_Project_tb_v;

	// Inputs
	reg Clk;
	reg Reset;
	reg BtnU, BtnL, BtnR, BtnC;
	
    
	// Outputs
    //SSD signal 
    wire An0, An1, An2, An3, An4, An5, An6, An7;
    wire Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp;
	//wire [2:0] camera_state;
    
    wire  QuadCS;

	wire[2:0] camera_state;

	reg [7*8:0] state_string; // 7-character string for symbolic display of state
	
	// Instantiate the Unit Under Test (UUT)
	Doom_top uut (
		.ClkPort(Clk), 
		.BtnC(BtnC), 
		.BtnR(BtnR),
		.BtnL(BtnL),
		.BtnU(BtnU),
		.An0(An0),
		.An1(An1),
		.An2(An2),
		.An3(An3),
		.An4(An4),
		.An5(An5),
		.An6(An6),
		.An7(An7),
		.Ca(Ca),
		.Cb(Cb),
		.Cc(Cc),
		.Cd(Cd),
		.Ce(Ce),
		.Cf(Cf),
		.Cg(Cg),
		.Dp(Dp),
		.QuadSpiFlashCS(QuadCS),
		.camera_view(camera_state)
		
	);
		
	
		initial begin
			begin: CLOCK_GENERATOR
				Clk = 0;
				forever begin
					#5 Clk = ~ Clk;
				end
			end
		end
		initial begin
			#0 BtnC = 0;
			#20 BtnC = 1;
			#20 BtnC = 0;
		end
		

		
		initial begin
		// Initialize Inputs
		BtnU = 0;
		BtnR = 0;
		BtnL = 0;
		
		


		// Wait 100 ns for global reset to finish
		#100;
		
		BtnL = 1; // Transitions from forward to "forward to left"
		#20;
		BtnL = 0; // Transitions from FtoL to left
		#20;
		
		BtnR = 1; // Transitions from left to LtoF
		#20;
		BtnR = 0; // Transitions from LtoF to Forward
		#20;
		BtnR = 1; // Transitions from Forward to FtoR
		#20;
		BtnR = 0; // Transitions from FtoR to Right
		#20;
		
		BtnL = 1; // Transitions from Right to RtoF
		#20;
		BtnL = 0; // Transitions from RtoF to Forward
		#20;
		
		BtnL = 1; // Transitions from Forward to FtoL
		#20;
		BtnL = 0; // Transitions from FtoL to Left
		#20;
				
	 
		$finish;
		
		


	end
	
		
		
	
	
	
	always @(*)
		begin
			case (camera_state)    // Note the concatenation operator {}
				3'b001: state_string = "Forward";  // ****** TODO ******
				3'b010: state_string = "Left   ";  // Fill-in the three lines
				3'b100: state_string = "Right  ";		
			endcase
		end
		
 
      
endmodule

