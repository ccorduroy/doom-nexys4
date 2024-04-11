// Needs for this file:
// Left and right input
// Clock 

`timescale 1ns / 1ps

module camera_controller(
    input clk,
    //input bright,
    input rst,
    input leftB,
	input rightB,
    //output reg [11:0] rgb,
    //output reg [11:0] background,
	output reg [2:0] camera_view
    //input start,
	
	
   );
    
    

	// State definitions
    localparam Forward = 3'b001, FtoL = 3'b010, Left = 3'b011, LtoF = 3'b100, FtoR = 3'b101, Right = 3'b110, RtoF = 3'b111, UNK = 3'bXXX;

    
   
    always@(posedge clk, posedge rst) 
    begin: Camera_Control_SM
        if(rst)
        begin 
            camera_view <= Forward;
        end
        else if (clk) 
            case(camera_view)
                Forward:
                    begin
                        if (leftB && !rightB)
                            camera_view <= FtoL;
						if (!leftB && rightB)
							camera_view <= FtoR;
                    end
				FtoL: // Forward to left
                    begin
                        if (!leftB && !rightB)
                            camera_view <= Left;
                    end
                Left:
                    begin
                        if (!leftB && rightB)
							camera_view <= LtoF;
                    end 
				LtoF: // Left to forward
                    begin
                        if (!leftB && !rightB)
                            camera_view <= Forward;
                    end
				FtoR: // Forward to left
                    begin
                        if (!leftB && !rightB)
                            camera_view <= Right;
                    end
                Right:
                    begin
                        if (leftB && !rightB)
							camera_view <= RtoF;
                        
                    end
				RtoF: // Forward to left
                    begin
                        if (!leftB && !rightB)
                            camera_view <= Forward;
                    end

			endcase
    end  
endmodule