
`timescale 1ns / 1ps // First parameter is the time unit for #[number] calls
// Second parameter is the accuracy/precision of this time scale

// No inputs and outputs bc DUT (design under test) is inside the testbench
module enemy_tb_v;

	// Inputs
	reg Clk;
	reg slow_clk;
	reg Reset;
	reg start;
	reg [2:0] fire_state;
	reg [2:0] camera_view;
	
	// Outputs
	wire [2:0] enemy_state;
	wire forward_enemy_flag;
	wire left_enemy_flag;
	wire right_enemy_flag;
	wire enemy_attack;
	
	// Comment these when returning to local timer counts
	//wire[1:0] forward_enemy_health;
	//wire[1:0] left_enemy_health;
	//wire[1:0] right_enemy_health;
	//wire [5:0] forward_enemy_timer;
	//wire [2:0] forward_attack_timer;
	
	//wire [5:0] left_enemy_timer;
	//wire [2:0] left_attack_timer;
	
	//wire [5:0] right_enemy_timer;
	//wire [2:0] right_attack_timer;
	
	
	

	reg [7*8:0] state_string; // 7-character string for symbolic display of state
	
	// Instantiate the Unit Under Test (UUT)
	enemy_controller uut (
		.clk(Clk), 
		.slow_clk(slow_clk),
		.rst(Reset),
		.start(start),
		.fire_state(fire_state),
		.camera_view(camera_view),
		.enemy_state(enemy_state),
		.forward_enemy_flag(forward_enemy_flag),
		.left_enemy_flag(left_enemy_flag),
		.right_enemy_flag(right_enemy_flag),
		.enemy_attack(enemy_attack)
		
	
	);
		
	
		initial begin
			begin: CLOCK_GENERATOR
				Clk = 0;
				forever begin
					#5 Clk = ~ Clk;
				end
			end
		end
		
		// Starts slow clock at 10MHz
		initial begin
			begin: SLOW_CLOCK_GENERATOR
				slow_clk = 0;
				forever begin
					#50 slow_clk = ~ slow_clk;
				end
			end
		end
		
		
		initial begin
			#0 Reset = 0;
			#20 Reset = 1;
			#20 Reset = 0;
		end
		

		
		initial begin
		// Initialize Inputs
		start = 0;
		fire_state = 3'b001; // Loaded state
		camera_view = 3'b001; // Forward state

		// Wait 100 ns for global reset to finish
		#100;
		
		start = 1;
		#10;
		start = 0;
		
		// 3 full clock cycles at 100ns period per "second"
		// 300ns per simulation Second
		
		// Waits for first forward enemy to spawn
		#700;
		// camera_view still in forward state
		// Weapon is fired for one clock
		fire_state = 3'b010; // weapon fired
		#20;
		fire_state = 3'b100; // weapon enters idle state
		#20;
		fire_state = 3'b001; // weapon Loaded
		#10;
		fire_state = 3'b010; // weapon fired
		#10;
		fire_state = 3'b100; // weapon idle
		#10;
		fire_state = 3'b001; // weapon loaded
		#10;
		fire_state = 3'b010;
		#10;
		fire_state = 3'b001; // weapon loaded
		
		// First enemy should be defeated
		
		// 780ns since start
		camera_view = 3'b011; // camera pans left
		// waits 720ns to reach 5 seconds for left enemy to spawn (1500ns)
		#720;
		
		fire_state = 3'b010; // weapon fired
		#10;
		fire_state = 3'b100; // weapon enters idle state
		#20;
		fire_state = 3'b001; // weapon Loaded
		#10;
		fire_state = 3'b010; // weapon fired
		#10;
		fire_state = 3'b100; // weapon idle
		#10;
		fire_state = 3'b001; // weapon loaded
		#10;
		fire_state = 3'b010;
		#10;
		fire_state = 3'b001; // weapon loaded
		
		camera_view = 3'b110; // camera pans to right
		
		// waits to reach 8 seconds for first right enemy to spawn (2400ns)
		#820
		
		fire_state = 3'b010; // weapon fired
		#10;
		fire_state = 3'b100; // weapon enters idle state
		#20;
		fire_state = 3'b001; // weapon Loaded
		#10;
		fire_state = 3'b010; // weapon fired
		#10;
		fire_state = 3'b100; // weapon idle
		#10;
		fire_state = 3'b001; // weapon loaded
		#10;
		fire_state = 3'b010;
		#10;
		fire_state = 3'b001; // weapon loaded
		
		camera_view = 3'b001; // Forward state
		
		fire_state = 3'b010; // weapon fired
		#10;
		fire_state = 3'b100; // weapon enters idle state
		#20;
		fire_state = 3'b001; // weapon Loaded
		#10;
		fire_state = 3'b010; // weapon fired
		#10;
		fire_state = 3'b100; // weapon idle
		#10;
		fire_state = 3'b001; // weapon loaded
		#10;
		fire_state = 3'b010;
		#10;
		fire_state = 3'b001; // weapon loaded
		
		#1600; // Wait for last forward enemy to spawn
		
		// Defeat last forward enemy
		fire_state = 3'b010; // weapon fired
		#10;
		fire_state = 3'b100; // weapon enters idle state
		#20;
		fire_state = 3'b001; // weapon Loaded
		#10;
		fire_state = 3'b010; // weapon fired
		#10;
		fire_state = 3'b100; // weapon idle
		#10;
		fire_state = 3'b001; // weapon loaded
		#10;
		fire_state = 3'b010;
		#10;
		fire_state = 3'b001; // weapon loaded
		
		
		
		// waits 2000ns to observe enemy actions and spawns
		#2000;
		
		
		
				
	 
		$finish;
		
		


	end
	
		
		
	
	
	
	always @(*)
		begin
			case (enemy_state)    // Note the concatenation operator {}
				3'b001: state_string = "Initial";  // ****** TODO ******
				3'b010: state_string = "Running";  // Fill-in the three lines
				//3'b100: state_string = "Fire_Id";		
			endcase
		end
		
 
      
endmodule

