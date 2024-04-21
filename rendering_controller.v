`timescale 1ns / 1ps

module rendering_controller(
    input clk,
    input fast_clk,
    input start,
    input [2:0] camera_view,
    input weapon_state,
    input enemy_state,
    input forward_enemy_flag,
    input right_enemy_flag,
    input left_enemy_flag,
    input bright,
    input [9:0] vCount, hCount,
    output reg [11:0] rgb
);

    //------------------------------------------------------------------------
    // colors for rom instantiation
    wire [11:0] titlescreen;
    wire [11:0] bgf;
    wire [11:0] bgr;
    wire [11:0] bgl;
    wire [11:0] shotgun;
    wire [11:0] shoot1;
    wire [11:0] shoot2;
    wire [11:0] enemy;

    // fill limiter instantiation
    //wire temp_fill;
    wire bg_fill;
    wire shotgun_fill;
    wire titlescreen_fill;
    wire enemy_fill;

    // debug
    parameter RED   = 12'b1000_0000_0000;
    parameter BLACK = 12'b0000_0000_0000;
    parameter WHITE = 12'b1111_1111_1111;
    parameter GREEN = 12'b0000_1000_0000;
    parameter BLUE = 12'b0000_0000_1000;

    // state enumaerations for camera control (easier to read)
    localparam Forward = 3'b001, FtoL = 3'b010, Left = 3'b011, LtoF = 3'b100, FtoR = 3'b101, Right = 3'b110, RtoF = 3'b111, UNK = 3'bXXX;

    //------------------------------------------------------------------------
    // all of these images have static coordinates!
    // xpos, ypos = top left corner of sprite
    // rough center of the screen: x = 450 y = 250
    // visible pixels: x[144, 783] y[35, 515]
    // rom d(.clk(clk),.row(vCount-ypos),.col(hCount-xpos),.color_data(wire data));

    titlescreen_rom d0(.clk(clk),.row(vCount-186),.col(hCount-322),.color_data(titlescreen));

    // background for each position
    //**bgf_rom d1(.clk(clk),.row(vCount-170),.col(hCount-322),.color_data(bgf));	// front
    //**bgr_rom d2(.clk(clk),.row(vCount-170),.col(hCount-322),.color_data(bgr));	// right
    //**bgl_rom d3(.clk(clk),.row(vCount-170),.col(hCount-322),.color_data(bgl));	// left
    // gun (static)
    //**shotgun_rom d4(.clk(clk),.row(vCount-152),.col(hCount-416),.color_data(shotgun));
    // gun (shooting) - 2 frames
    //**shoot1_rom d5(.clk(clk),.row(vCount-152),.col(hCount-416),.color_data(shoot1));
    //shoot2_rom d6(.clk(clk),.row(vCount-300),.col(hCount-320),.color_data(shoot2));
    // gun (reloading) - 4 frames - not yet implemented in gun SM
    //reload_rom_1 r1(.clk(clk),.color_data(reload1));
    //reload_rom_2 r2(.clk(clk),.color_data(reload2));
    //reload_rom_3 r3(.clk(clk),.color_data(reload3));
    //reload_rom_4 r4(.clk(clk),.color_data(reload4));
    // enemies
    /**enemy_rom d7(.clk(clk),.row(vCount-250),.col(hCount-425),.color_data(enemy));

    //------------------------------------------------------------------------
    //--- MASTER RENDERING STATE MACHINE - WITH PRIORITY ---

    //example:
    /*
    always@ (*) // paint a white box on a red background
         if (~bright)
            rgb = BLACK; // force black if not bright
         else if (greenMiddleSquare == 1)
            rgb = GREEN;
         else if (whiteZone == 1)
            rgb = WHITE; // white box
         else
            rgb = RED; // background color
    */

    /* PRIORITY TIERS:
        0. start menu (overlaps all)
        1. gun
        2. enemy
        3. background
    */

    /* when outputting the rgb value in an always block like this, make sure to include the
    if(~bright) statement, as this ensures the monitor will output some data to every pixel
    and not just the images you are trying to display. */

    // always @*
    always @ (*)
        begin: RENDER_SM
            // force black if out of screen
            if(~bright)
                rgb = BLACK;

                // PRIO 0: start menu (should disappear once the game begins)
                // controlled by enemy SM - when enemies are not actively spawning, hold title screen.
            else if(titlescreen_fill && (enemy_state == 3'b001))    // TODO : titlescreen_fill &&
                rgb = titlescreen;
                //rgb = WHITE;

                // PRIO 1a: gun idle (overwrites shoot ani  if shooting period over)
            else if(shotgun_fill && (weapon_state == 3'b001))
                //rgb = shotgun;
                rgb = BLACK;

                // PRIO 1b: shoot
            else if(shotgun_fill && ~(weapon_state == 3'b001))
                // sequence?? run gif and then change behavior.
                //rgb = shoot1;
                rgb = BLACK;

                // PRIO 2: enemy TODO: enemy_fill &&
            else if(enemy_fill && (camera_view == Forward) && (forward_enemy_flag == 1)) rgb = WHITE;
            else if(enemy_fill && (camera_view == Right) && (right_enemy_flag == 1)) rgb = WHITE;
            else if(enemy_fill && (camera_view == Left) && (left_enemy_flag == 1)) rgb = WHITE;

                // PRIO 3: background (directional) TODO: bg_fill &&
            else if(bg_fill && (camera_view == Forward)) rgb = RED;     // forward
            else if(bg_fill && (camera_view == Right)) rgb = GREEN;   // right
            else if(bg_fill && (camera_view == Left)) rgb = BLUE;    // left

            else rgb = BLACK;
        end

    // --------------------------------------------------------------------
    // assign block_fill = vCount>=(ypos) && vCount<=(ypos+height) && hCount>=(xpos) && hCount<=(xpos+width);
    // screen size: 900 x 500
    // rough center of the screen: x = 450 y = 250
    // visible pixels: x[144, 783] y[35, 515]

    // note: hcount and vcount weren't connected to display controller! now they are
    // title screen: 256x128 at (322, 186)
    //assign temp_fill=vCount>=(450-25) && vCount<=(450+25) && hCount>=(450-25) && hCount<=(450+25);
    assign titlescreen_fill = (vCount>=(186)) && (vCount<=(186+127)) && (hCount>=(322+1)) && (hCount<=(322+255));
    // bg (all angles): wh: 256x160 at (322, 170)
    assign bg_fill = (vCount>=(170)) && (vCount<=(170+159)) && (hCount>=(322+1)) && (hCount<=(322+255));
    // shotgun and shoot (all frames): 67x62 at (416, 152)
    assign shotgun_fill = (vCount>=(280)) && (vCount<=(280+61)) && (hCount>=(416+1)) && (hCount<=(416+66));
    // enemy: 50x69 at (425, 250)
    assign enemy_fill = (vCount>=(220)) && (vCount<=(220+68)) && (hCount>=(425+1)) && (hCount<=(425+49));

endmodule : rendering_controller