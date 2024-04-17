`timescale 1ns / 1ps

module rendering_controller(
    input clk,
    //input slow_clk,
    input start,
    input camera_view,
    input weapon_state,
    input forward_enemy_flag,
    input right_enemy_flag,
    input left_enemy_flag,
    input bright,
    input [9:0] vCount,
    input [9:0] hCount,
    output reg[11:0] rgb
);

    //------------------------------------------------------------------------
    // utils
    reg [3:0] clk_counter;  // slowclock counter for gif frames - max 15 = 5sec

    // wires: rgb color data
    wire [11:0] titlescreen;
    wire [11:0] bgf;
    wire [11:0] bgr;
    wire [11:0] bgl;
    wire [11:0] shotgun;
    wire [11:0] shoot1;
    wire [11:0] shoot2;
    wire [11:0] enemy;
    //wire [11:0] reload1;
    //wire [11:0] reload2;
    //wire [11:0] reload3;
    //wire [11:0] reload4;

    //------------------------------------------------------------------------
    // rom instantiation TODO
    // params: clock, row, column, color_data
    // all of these images have static coordinates!
    // xpos, ypos = top left corner
    titlescreen_rom d0(.clk(clk),.row(ypos),.col(xpos),.color_data(titlescreen));

    // background for each position
    bgf_rom d1(.clk(clk),.row(vCount-250),.col(hCount-70),.color_data(bgf));	// front
    bgr_rom d2(.clk(clk),.row(vCount-250),.col(hCount-70),.color_data(bgr));	// right
    bgl_rom d3(.clk(clk),.row(vCount-250),.col(hCount-70),.color_data(bgl));	// left
    // gun (static)
    shotgun_rom d4(.clk(clk),.row(vCount-150),.col(hCount-300),.color_data(shotgun));
    // gun (shooting) - 2 frames
    shoot1_rom d5(.clk(clk),.row(vCount-150),.col(hCount-300),.color_data(shoot1));
    //shoot2_rom d6(.clk(clk),.row(vCount-300),.col(hCount-320),.color_data(shoot2));
    // gun (reloading) - 4 frames - not yet implemented in gun SM
    //reload_rom_1 r1(.clk(clk),.color_data(reload1));
    //reload_rom_2 r2(.clk(clk),.color_data(reload2));
    //reload_rom_3 r3(.clk(clk),.color_data(reload3));
    //reload_rom_4 r4(.clk(clk),.color_data(reload4));
    // enemies
    enemy_rom d7(.clk(clk),.row(vCount-200),.col(hCount-350),.color_data(enemy));

    //------------------------------------------------------------------------
    // gif timer
    /*always @ (posedge clk)
    begin : GIF_TIMER
        if(reset)
            clk_counter <= 0;
        else
            clk_counter <= clk_counter + 1'b1;
            // this number will rollback to 0 every ~5 seconds.
            // this is fine. we will use modulus of the # of frames/
            // since max number is 15, we can't use %3, lest 0 and 15 have the same output.
            // luckily, the gifs in this format are never 3 frames long.
    end*/

    //------------------------------------------------------------------------
    // render image at correct location based on source ROM size
    // loads in pixels from top left to bottom right of the sprite
    // used in SM to limit rendering to area of source image

    // images should only load when display scan pixel is at the right coords.
    // title screen: 256x128
    assign titlescreen_fill = (vCount >= (ypos)) && (vCount <= (ypos+127)) && (hCount >= (xpos+1)) && (hCount <= (xpos+255));
    // bg (all angles): wh: 256x160
    assign bg_fill = (vCount >= (ypos)) && (vCount <= (ypos+159)) && (hCount >= (xpos+1)) && (hCount <= (xpos+255));
    // shotgun and shoot (all frames): 67x62
    assign shotgun_fill = (vCount >= (ypos)) && (vCount <= (ypos+61)) && (hCount >= (xpos+1)) && (hCount <= (xpos+66));
    // enemy: 50x69
    assign enemy_fill = (vCount >= (ypos)) && (vCount <= (ypos+68)) && (hCount >= (xpos+1)) && (hCount <= (xpos+49));


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

    always @*
        begin
            // force black if out of screen
            if(~bright)
                rgb = 12'b000000000000;

                // PRIO 0: start menu (should disappear once the game begins)
                // controlled by enemy SM - when enemies are not actively spawning, hold title screen.
                // enemy state machine changes to running when start button is pressed, so this works??
            else if(titlescreen_fill && (enemy_state == 3'b001))
                    rgb = titlescreen;

                // PRIO 1a: gun idle (overwrites shoot ani  if shooting period over)
            else if(shotgun_fill && (weapon_state == 3'b001))
                begin
                    rgb = shotgun;
                end
                // PRIO 1b: shoot
            else if(shotgun_fill && ((weapon_state == 3'b010) || (weapon_state == 3'b100)))
                begin
                    // sequence?? run gif and then change behavior.
                    rgb = shoot1;
                    //rgb = shoot2;
                end

                // PRIO 2: enemy
            else if(enemy_fill && (
                ((camera_view == 3'b001) && forward_enemy_flag == 1)
                || ((camera_view == 3'b110) && right_enemy_flag == 1)
                || ((camera_view == 3'b011) && left_enemy_flag == 1))) // if enemy is present and player is facing it
                    rgb = enemy;

                // PRIO 3: background (directional)
            else if(bg_fill && (camera_view == 3'b001)) rgb = bg_f;
            else if(bg_fill && (camera_view == 3'b110)) rgb = bg_r;
            else if(bg_fill && (camera_view == 3'b011)) rgb = bg_l;
        end

endmodule