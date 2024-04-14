
`timescale 1ns / 1ps // First parameter is the time unit for #[number] calls
// Second parameter is the accuracy/precision of this time scale

// No inputs and outputs bc DUT (design under test) is inside the testbench
module weapon_tb_v;

	// Inputs
	reg Clk;
	//reg Reset;
	reg BtnU, BtnL, BtnR, BtnC;
	reg Sw15;
	
    
	// Outputs
    //SSD signal 
    //wire An0, An1, An2, An3, An4, An5, An6, An7;
    //wire Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp;
	//wire [2:0] camera_state;
    
    //wire  QuadCS;

	wire[2:0] weapon_state;

	reg [7*8:0] state_string; // 7-character string for symbolic display of state
	
	// Instantiate the Unit Under Test (UUT)
	weapon_controller uut (
		.clk(Clk), 
		.rst(BtnC),
		.in_switch(Sw15),
		.weapon_state(weapon_state)
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
		Sw15 = 0;

		// Wait 100 ns for global reset to finish
		#100;
		
		Sw15 = 1; // Transitions from forward to "forward to left"
		#60;
		Sw15 = 0;
		#20;
		
		Sw15 = 1;
		#20;
		Sw15 = 0;
		#40;
		
				
	 
		$finish;
		
		


	end
	
		
		
	
	
	
	always @(*)
		begin
			case (weapon_state)    // Note the concatenation operator {}
				3'b001: state_string = "Loaded ";  // ****** TODO ******
				3'b010: state_string = "Firing ";  // Fill-in the three lines
				3'b100: state_string = "Fire_Id";		
			endcase
		end
		
 
      
endmodule

