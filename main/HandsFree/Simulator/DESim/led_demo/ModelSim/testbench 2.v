`timescale 10ns / 10ns

module testbench ();

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/

parameter CLOCK_PERIOD = 2; // 20ns


/*****************************************************************************
 *                          Testbench Port Declarations                      *
 *****************************************************************************/

 reg            clk;
 reg            reset;

 // Inputs
 reg        [3:0] key;
 reg        [9:0] switch;


 // Output
 wire       [9:0] led;
 wire       [6:0] hex0;
 wire       [6:0] hex1;
 wire       [6:0] hex2;
 wire       [6:0] hex3;
 wire       [6:0] hex4;
 wire       [6:0] hex5;


initial begin
    key <= 4'b1111;
    switch <= 0;
    
    reset <= 1'b1;
 #3 reset <= 1'b0;
end

initial begin
	clk <= 1'b0;
end

always begin : Clock_Generator
	#((CLOCK_PERIOD) / 2) clk = ~clk;
end


// Keyboard inputs
wire             key_action;
wire        [7:0] scan_code;


// Bit 0: Scroll Lock, bit 1: Num Lock, Bit 2: Caps lock
// Keyboard outputs
wire        [2:0]ps2_lock_control;


// VGA
wire hsync;
wire vsync;
wire [9:0] red;
wire [9:0] green;
wire [9:0] blue;
wire blank;
wire vga_clk;


/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

 top my_program(
    .CLOCK_50(clk),
    .KEY(key),
    .SW(switch),

    .PS2_CLK(ps2_clk),
    .PS2_DAT(ps2_dat),

    .LED(led),
    .HEX0(hex0),
    .HEX1(hex1),
    .HEX2(hex2),
    .HEX3(hex3),
    .HEX4(hex4),
    .HEX5(hex5),

    .VGA_CLK(vga_clk),
    .VGA_HS(hsync),
    .VGA_VS(vsync),
    .VGA_BLANK_N(blank),
    .VGA_SYNC_N(),
    .VGA_R(red),
    .VGA_G(green),
    .VGA_B(blue)
 );


 keyboard_interface KeyBoard(
     .clk(clk),
     .reset(reset),
     .key_action(key_action),
     .scan_code(scan_code),
     .ps2_clk(ps2_clk),
     .ps2_dat(ps2_dat),
     .lock_controls(ps2_lock_control)
 );

 vga_interface vga(
    .clk(clk),
    .reset(reset),
    .vga_clk(vga_clk),
    .hsync(hsync),
    .vsync(vsync),
    .blank(blank),
    .red(red),
    .green(green),
    .blue(blue)
);

endmodule