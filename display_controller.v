`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

module display_controller(
    input clk,
    output hSync, vSync,
    output reg bright,
    output reg[9:0] hCount,
    output reg [9:0] vCount, // Covers 800, width of the screen, because it's 2^10
    output [3:0] vgaR, vgaG, vgaB   // VGA output
);

    reg pulse;
    reg clk25;

    initial begin // Set all of them initially to 0
        clk25 = 0;
        pulse = 0;
    end

    always @(posedge clk)
        pulse = ~pulse;
    always @(posedge pulse)
        clk25 = ~clk25;

    always @ (posedge clk25)
        begin
            if (hCount < 10'd799)
                begin
                    hCount <= hCount + 1;
                end
            else if (vCount < 10'd524)
                begin
                    hCount <= 0;
                    vCount <= vCount + 1;
                end
            else
                begin
                    hCount <= 0;
                    vCount <= 0;
                end
        end

    assign hSync = (hCount < 96) ? 0:1;
    assign vSync = (vCount < 2) ? 0:1;

    always @(posedge clk25)
        begin
            if(hCount > 10'd143 && hCount < 10'd784 && vCount > 10'd34 && vCount < 10'd516)
                bright <= 1;
            else
                bright <= 0;
        end

endmodule : display_controller