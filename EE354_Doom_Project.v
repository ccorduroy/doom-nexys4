

`timescale 1ns / 1ps

module Doom_top(
    input ClkPort,
    input BtnC,
    input BtnR,
    input BtnL,
    input BtnU,
	input BtnD,
	// Adds all switches as inputs just in case we want to use them and Vivado won't yell at us
    input Sw15, Sw14, Sw13, Sw12, Sw11, Sw10, Sw9, Sw8, Sw7, Sw6, Sw5, Sw4, Sw3, Sw2, Sw1, Sw0,
    //VGA signal
    //output hSync, vSync,
    //output [3:0] vgaR, vgaG, vgaB,
    
    //SSG signal 
    output An0, An1, An2, An3, An4, An5, An6, An7,
    output Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,
	// NOTE: will need to edit top file if LEDs are desired
    
	// Can comment these out when using testbench
    output MemOE, MemWR, RamCS,
    output  QuadSpiFlashCS
	
	// Only use this for testbench purposes
	//output wire[2:0] camera_view
    );
	
	
	assign {MemOE, MemWR, RamCS, QuadSpiFlashCS} = 4'b1111;
	
    wire Reset;
    assign Reset=BtnC;
    
	// NOTE: Need to assign start signal to some trigger for the game to run/trigger enemy spawns
	wire start;
	assign start = BtnD;
    
    reg [2:0]   SSD;
	
	// SSD0 shows the camera state (forward, left, right)
	// SSD4 shows the weapon state (loaded or empty)
	// SSDs 2-4 show if an enemy is present at a direction (Will show capital E for enemy)
	// SSD3 shows left, SSD2 shows forward, and SSD1 shows right
	// Additional wire variables for SSDs 1-4 are not created as they are hard coded later on
    wire [2:0]  SSD0, SSD1, SSD2, SSD3;
	
    reg [7:0]   SSD_CATHODES;
    wire [2:0]  ssdscan_clk;
	
	// For camera_view: Forward = 3'b001, Left = 3'b011, and Right = 3'b1100
	// Intermediate state codes can be found in camera_controller.v
	wire [2:0] camera_view;
	
	// For weapon_state: Loaded = 3'b001, Firing(Shooting) = 3'b010, and Idle(waiting for reload) = 3'b100
	wire [2:0] weapon_state;
	
	// NOTE: This enemy_state variable is not very useful, it will only indicate if the state machine is idle or actively running enemy spawns
	wire [2:0] enemy_state;
	
	// These flags indicate if there is an enemy in the respective direction
	wire forward_enemy_flag;
	wire left_enemy_flag;
	wire right_enemy_flag;
	
	// This variable will be active for one clock to indicate that an enemy from any direction has attacked the player
	wire enemy_attack;
	
	
	
	// This slow clock is roughly 100Hz and is used for enemy timers
	reg [27:0]  DIV_CLK;
	assign slow_clk = DIV_CLK[19];
	
	
    always @ (posedge ClkPort, posedge Reset)  
    begin : CLOCK_DIVIDER
      if (Reset)
            DIV_CLK <= 0;
      else
            DIV_CLK <= DIV_CLK + 1'b1;
    end
	
	camera_controller sc(
		.clk(ClkPort),
		.rst(BtnC),
		.leftB(BtnL),
		.rightB(BtnR),
		.camera_view(camera_view)
	);
	
	weapon_controller sc1(
		.clk(slow_clk),
		.rst(BtnC),
		.in_switch(Sw15),
		.weapon_state(weapon_state)
	);
	
	enemy_controller sc2(
		.clk(ClkPort),
		.slow_clk(slow_clk),
		.rst(BtnC),
		.start(start),
		.fire_state(weapon_state),
		.camera_view(camera_view),
		.enemy_state(enemy_state),
		.forward_enemy_flag(forward_enemy_flag),
		.left_enemy_flag(left_enemy_flag),
		.right_enemy_flag(right_enemy_flag),
		.enemy_attack(enemy_attack)
	);
	
  



    
    //assign vgaR = rgb[11 : 8];
    //assign vgaG = rgb[7  : 4];
    //assign vgaB = rgb[3  : 0];
    
    // disable mamory ports
    assign {MemOE, MemWR, RamCS, QuadSpiFlashCS} = 4'b1111;
    //assign QuadSpiFlashCS = 1'b1;
    
    //------------
// SSD (Seven Segment Display)
    // reg [3:0]    SSD;
    // wire [3:0]   SSD3, SSD2, SSD1, SSD0;
    
    //SSDs display 
    //to show how we can interface our "game" module with the SSD's, we output the 12-bit rgb background value to the SSD's
    //assign SSD3 = 4'b0000;
    //assign SSD2 = background[11:8];
    //assign SSD1 = background[7:4];
    //assign SSD0 = background[3:0];
	assign SSD0 = camera_view;
	assign SSD1 = {right_enemy_flag, 0, 0};


    // need a scan clk for the seven segment display 
    
    // 100 MHz / 2^18 = 381.5 cycles/sec ==> frequency of DIV_CLK[17]
    // 100 MHz / 2^19 = 190.7 cycles/sec ==> frequency of DIV_CLK[18]
    // 100 MHz / 2^20 =  95.4 cycles/sec ==> frequency of DIV_CLK[19]
    
    // 381.5 cycles/sec (2.62 ms per digit) [which means all 4 digits are lit once every 10.5 ms (reciprocal of 95.4 cycles/sec)] works well.
    
    //                  --|  |--|  |--|  |--|  |--|  |--|  |--|  |--|  |   
    //                    |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 
    //  DIV_CLK[17]       |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|
    //
    //               -----|     |-----|     |-----|     |-----|     |
    //                    |  0  |  1  |  0  |  1  |     |     |     |     
    //  DIV_CLK[18]       |_____|     |_____|     |_____|     |_____|
    //
    //         -----------|           |-----------|           |
    //                    |  0     0  |  1     1  |           |           
    //  DIV_CLK[19]       |___________|           |___________|
    //


    assign ssdscan_clk = DIV_CLK[19:17];
    assign An0  = !(~(ssdscan_clk[2]) && (~(ssdscan_clk[1]) && ~(ssdscan_clk[0])));  // when ssdscan_clk = 000
	assign An1  = !(~(ssdscan_clk[2]) && (~(ssdscan_clk[1]) && (ssdscan_clk[0])));   // when ssdscan_clk = 001
	assign An2  = !(~(ssdscan_clk[2]) &&  (ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 010
	assign An3  = !(~(ssdscan_clk[2]) &&  (ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 011
	assign An4  = !( (ssdscan_clk[2]) && ~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 100

    // Turn off another 3 anodes
    assign {An7, An6, An5} = 3'b111;
	
	

    always @ (ssdscan_clk, SSD0)
    begin : SSD_SCAN_OUT
        case (ssdscan_clk) 
                  3'b000: SSD = SSD0; // Covers camera view
				  3'b001: 
						begin
							if (right_enemy_flag == 1)
								SSD = 3'b111;
							else 
								SSD = 3'b000;
						end
				  3'b010: 
						begin
							if (forward_enemy_flag == 1)
								SSD = 3'b111;
							else 
								SSD = 3'b000;
						end
				  3'b011:
						begin
							if (left_enemy_flag == 1)
								SSD = 3'b111;
							else 
								SSD = 3'b000;
						end
				  3'b100:
						begin
							if (weapon_state == 3'b001)
								SSD = 3'b011; // Represents loaded state
							else 
								begin
									if (weapon_state == 3'b100)
										SSD = 3'b111; // Represents idle/empty state
									else 
										SSD = 3'b000;
								end
						end
        endcase 
    end

    // Following is Hex-to-SSD conversion
    always @ (SSD) 
    begin : HEX_TO_SSD
        case (SSD)
			3'b001: SSD_CATHODES = 8'b01110001; // F for Forward
			3'b011: SSD_CATHODES = 8'b11100011; // L for Left
			3'b110: SSD_CATHODES = 8'b11110101; // r for Right
			3'b111: SSD_CATHODES = 8'b01100001; // E for Enemy or Empty
			3'b000: SSD_CATHODES = 8'b11111111; // Blank space to represent no enemy
			
            default: SSD_CATHODES = 8'bXXXXXXXX; // default is not needed as we covered all cases
        endcase
    end 
    
    assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp} = {SSD_CATHODES};
	
	// Original hex to SSD mapping
	        //4'b0000: SSD_CATHODES = 8'b00000011; // 0
            //4'b0001: SSD_CATHODES = 8'b10011111; // 1
            //4'b0010: SSD_CATHODES = 8'b00100101; // 2
            //4'b0011: SSD_CATHODES = 8'b00001100; // 3
            //4'b0100: SSD_CATHODES = 8'b10011000; // 4
            //4'b0101: SSD_CATHODES = 8'b01001000; // 5
            //4'b0111: SSD_CATHODES = 8'b00011110; // 7
            //4'b0110: SSD_CATHODES = 8'b01000000; // 6
            //4'b1000: SSD_CATHODES = 8'b00000000; // 8
            //4'b1001: SSD_CATHODES = 8'b00001000; // 9
            //4'b1010: SSD_CATHODES = 8'b00010000; // A
            //4'b1011: SSD_CATHODES = 8'b11000000; // B
            //4'b1100: SSD_CATHODES = 8'b01100010; // C
            //4'b1101: SSD_CATHODES = 8'b10000100; // D
            //4'b1110: SSD_CATHODES = 8'b01100000; // E
            //4'b1111: SSD_CATHODES = 8'b01110000; // F

endmodule