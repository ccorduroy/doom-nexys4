// Needs for this file:
// Firing state input
// Clock 

`timescale 1ns / 1ps

module enemy_controller(
    input clk,
	input slow_clk,
    input rst,
	input start,
	input [2:0] fire_state, // 010 is firing state from weapon_controller
	input [2:0] camera_view, // 001 forward, 011 left, 110 right
	
	output reg [2:0] enemy_state,
	output reg forward_enemy_flag,
	output reg left_enemy_flag,
	output reg right_enemy_flag,
	output reg enemy_attack
	
	// Get rid of these after using testbench and use local variables
	//output reg [1:0] forward_enemy_health,
	//output reg [1:0] left_enemy_health,
	//output reg [1:0] right_enemy_health,
	//output reg [5:0] forward_enemy_timer,
	//output reg [2:0] forward_attack_timer,
	//output reg [5:0] left_enemy_timer,
	//output reg [2:0] left_attack_timer,
	//output reg [5:0] right_enemy_timer,
	//output reg [2:0] right_attack_timer
	
	
   );
    
	// Assigns health for all enemies (in thise case 2)
	// Change enemy health registers below accordingly
    reg [1:0] base_enemy_health = 2'b10;

	// State definitions
    localparam Initial = 3'b001, Running = 3'b010, UNK = 3'bXXX;


	// Uncomment and make these local after testbench use
    reg [9:0] forward_enemy_timer;
	reg [9:0] forward_attack_timer;
	reg [9:0] left_enemy_timer;
	reg [9:0] left_attack_timer;
	reg [9:0] right_enemy_timer;
	reg [9:0] right_attack_timer;

	
	// Defines max number of enemies per direction to 3
	// May need to change following registers accordingly
	reg [1:0] max_enemy_count = 2'b11;
	
	reg [1:0] forward_enemy_count = 2'b00;
	reg [1:0] left_enemy_count = 2'b00;
	reg [1:0] right_enemy_count = 2'b00;
	
	
	// NOTE: May have to change size of registers depending on base enemy health
	reg [1:0] forward_enemy_health = 2'b00;
	reg [1:0] left_enemy_health = 2'b00;
	reg [1:0] right_enemy_health = 2'b00;
	
   
    always@(posedge slow_clk, posedge rst)
    begin: Enemy_Control_SM
        if(rst)
        begin 
            enemy_state <= Initial;
			forward_enemy_flag = 0;
			left_enemy_flag = 0;
			right_enemy_flag = 0;
			forward_enemy_timer <= 0;
			forward_attack_timer <= 0;
			
			left_enemy_timer <= 0;
			left_attack_timer <= 0;
			
			right_enemy_timer <= 0;
			right_attack_timer <= 0;
        end
        else if (slow_clk) 
            case(enemy_state)
                Initial:
                    begin
                        if (start)
							begin
								enemy_state <= Running;
								forward_enemy_flag <= 0;
								left_enemy_flag <= 0;
								right_enemy_flag <= 0;
								forward_enemy_timer <= 0;
								forward_attack_timer <= 0;
			
								left_enemy_timer <= 0;
								left_attack_timer <= 0;
			
								right_enemy_timer <= 0;
								right_attack_timer <= 0;
								
								forward_enemy_count <= 0;
								left_enemy_count <= 0;
								right_enemy_count <= 0;
							end
                    end
				Running: 
                    begin
						if (!forward_enemy_flag)
							forward_enemy_timer <= forward_enemy_timer + 1;
						else
							forward_attack_timer <= forward_attack_timer + 1;
						if (!left_enemy_flag)
							left_enemy_timer <= left_enemy_timer + 1;
						else
							left_attack_timer <= left_attack_timer + 1;
						if (!right_enemy_flag)
							right_enemy_timer <= right_enemy_timer + 1;
						else
							right_attack_timer <= right_attack_timer + 1;
						// Spawns first enemy in forward direction after 2 seconds
						if (forward_enemy_timer == 6 && forward_enemy_count == 0)
							begin
								forward_enemy_flag <= 1;
								//first_forward_enemy <= 1;
								forward_enemy_timer <= 0;
								forward_enemy_count <= forward_enemy_count + 1;
								forward_enemy_health <= base_enemy_health;
							end
						// After 2 seconds and when there is no current forward enemy, spawns new enemy after 5 seconds
						else
							begin
								if (((forward_enemy_timer == 500) && (forward_enemy_count > 0)) && ((forward_enemy_flag == 0) && (forward_enemy_count < max_enemy_count)))
									begin
										forward_enemy_flag <= 1;
										forward_enemy_timer <= 0;
										forward_enemy_health <= base_enemy_health;
										forward_enemy_count <= forward_enemy_count + 1;
									end
							end
							
                        if (forward_enemy_flag == 1)
							begin
								if (fire_state == 3'b010 && camera_view == 3'b001)
									begin
										if (forward_enemy_health == 1)
											begin
												forward_enemy_health <= forward_enemy_health - 1;
												forward_enemy_flag <= 0;
												forward_attack_timer <= 0;
											end
										else 
											forward_enemy_health <= forward_enemy_health - 1;
									end
							end
							
							
						// Spawns first enemy in left direction after 5 seconds
						if (left_enemy_timer == 500 && left_enemy_count == 0)
							begin
								left_enemy_flag <= 1;
								left_enemy_timer <= 0;
								left_enemy_count <= left_enemy_count + 1;
								left_enemy_health <= base_enemy_health;
							end
						// After 5 seconds and when there is no current left enemy, spawns new enemy after 5 seconds
						else
							begin
								if ((left_enemy_timer == 500) && (left_enemy_count > 0) && (left_enemy_flag == 0) && (left_enemy_count < max_enemy_count))
									begin
										left_enemy_flag <= 1;
										left_enemy_timer <= 0;
										left_enemy_health <= base_enemy_health;
										left_enemy_count <= left_enemy_count + 1;
									end
							end
							
						if (left_enemy_flag)
							begin
								if ((fire_state == 3'b010) && (camera_view == 3'b011)) // Indicates weapon is fired and player is looking left
									begin
										if (left_enemy_health == 1)
											begin
												left_enemy_health <= left_enemy_health - 1;
												left_enemy_flag <= 0;
												left_attack_timer <= 0;
											end
										else 
											left_enemy_health <= left_enemy_health - 1;
									end
							end
							
						// Spawns first enemy in right direction after 8 seconds
						if (right_enemy_timer == 800 && right_enemy_count == 0)
							begin
								right_enemy_flag <= 1;
								right_enemy_timer <= 0;
								right_enemy_count <= right_enemy_count + 1;
								right_enemy_health <= base_enemy_health;
							end
						// After 5 seconds and when there is no current right enemy, spawns new enemy after 5 seconds
						else
							begin
								if ((right_enemy_timer == 500) && (right_enemy_count > 0) && (right_enemy_flag == 0) && (right_enemy_count < max_enemy_count))
									begin
										right_enemy_flag <= 1;
										right_enemy_timer <= 0;
										right_enemy_health <= base_enemy_health;
										right_enemy_count <= right_enemy_count + 1;
									end
							end
							
						if (right_enemy_flag)
							begin
								if ((fire_state == 3'b010) && (camera_view == 3'b110)) // Indicates weapon is fired and player is looking right
									begin
										if (right_enemy_health == 1)
											begin
												right_enemy_health <= right_enemy_health - 1;
												right_enemy_flag <= 0;
												right_attack_timer <= 0;
											end
										else 
											right_enemy_health <= right_enemy_health - 1;
									end
							end
							
							
							// Add checks for all attack timers at the same time
							if (forward_attack_timer == 200 || (left_attack_timer == 200 || right_attack_timer == 200))
									begin
										enemy_attack <= 1;
										if (forward_attack_timer == 200)
											forward_attack_timer <= 0;
										if (left_attack_timer == 200)
											left_attack_timer <= 0;
										if (right_attack_timer == 200)
											right_attack_timer <= 0;
									end
							else 
								enemy_attack <= 0;
								
                    end

			endcase
    end  
endmodule