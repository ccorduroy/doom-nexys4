// Needs for this file:
// Switch input
// Clock 

`timescale 1ns / 1ps

module weapon_controller(
    input clk,
    //input bright,
    input rst,
    input in_switch,
    //output reg [11:0] rgb,
    //output reg [11:0] background,
	output reg [2:0] weapon_state
    //input start,
	
	
   );
    
    

	// State definitions
    localparam Loaded = 3'b001, Firing = 3'b010, Fire_Idle = 3'b100, UNK = 3'bXXX;

    
   
    always@(posedge clk, posedge rst) 
    begin: Weapon_Control_SM
        if(rst)
        begin 
            weapon_state <= Loaded;
        end
        else if (clk) 
            case(weapon_state)
                Loaded:
                    begin
                        if (in_switch)
                            weapon_state <= Firing;
                    end
				Firing: // Only in firing state for one clock to signal animation and update enemy health
                    begin
                        weapon_state <= Fire_Idle;
                    end
                Fire_Idle:
                    begin
                        if (!in_switch)
							weapon_state <= Loaded;
                    end 

			endcase
    end  
endmodule