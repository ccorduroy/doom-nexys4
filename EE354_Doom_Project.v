

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
    //wire bright;
    wire left,right;
    //wire [3:0] anode;
    //wire [11:0] rgb;
    //wire rst;
    
    reg [3:0]   SSD;
    wire [3:0]  SSD3, SSD2, SSD1, SSD0;
    reg [7:0]   SSD_CATHODES;
    wire [1:0]  ssdscan_clk;
	wire [2:0] camera_view;
	
	reg [27:0]  DIV_CLK;
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
    //display_stuff dc(.clk(ClkPort), .hSync(hSync), .vSync(vSync), .bright(bright), .hCount(hc), .vCount(vc));
    //dinno_controller sc(.clk(move_clk),.mast_Clk(ClkPort),.bright(bright),.rst(BtnC),.left(Sw1),.right(Sw0),.hCount(hc),.vCount(vc),.rgb(rgb),.background(background),.start(BtnU));   
    //asteriod_controller sc1(.clk(move_clk), .mastClk(ClkPort), .bright(bright), .rst(BtnC),.hCount(hc), .vCount(vc), .rgb(rgb2));   



    
    //assign vgaR = rgb[11 : 8];
    //assign vgaG = rgb[7  : 4];
    //assign vgaB = rgb[3  : 0];
    
    // disable mamory ports
    //assign {MemOE, MemWR, RamCS, QuadSpiFlashCS} = 4'b1111;
    assign QuadSpiFlashCS = 1'b1;
    
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


    assign ssdscan_clk = DIV_CLK[19:18];
    assign An0  = !(~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 00
	
	
    //assign An1  = !(~(ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 01
    //assign An2  =  !((ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 10
    //assign An3  =  !((ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 11
    // Turn off another 7 anodes
	
    assign {An7, An6, An5, An4, An3, An2, An1} = 7'b1111111;
	
	

   // always @ (ssdscan_clk, SSD0, SSD1, SSD2, SSD3)
    always @ (ssdscan_clk, SSD0)
    begin : SSD_SCAN_OUT
        case (ssdscan_clk) 
                  2'b00: SSD = SSD0;
                  //2'b01: SSD = SSD1;
                  //2'b10: SSD = SSD2;
                  //2'b11: SSD = SSD3;
        endcase 
    end

    // Following is Hex-to-SSD conversion
    always @ (SSD) 
    begin : HEX_TO_SSD
        case (SSD)
			3'b001: SSD_CATHODES = 8'b01110001; // F for Forward
			3'b010: SSD_CATHODES = 8'b11100011; // L for Left
			3'b100: SSD_CATHODES = 8'b11110101; // r for Right
			
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