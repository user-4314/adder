module sub4(
// Clock Input (50 MHz)
  input  CLOCK_50,
  //  Push Buttons
  input  [3:0]  KEY,
  //  DPDT Switches 
  input  [17:0]  SW,
    //  7-SEG Displays
  output  [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
  //Declare Sum which is 8-bits long
  output diff,borrow,
  output [3:0] sum,
   // This is added to the convert the 8-bits to different HEX_
  output [3:0] ONES, TENS,
  output [3:0] HUNDREDS,
  //  LEDs
  output  [8:0]  LEDG,  //  LED Green[8:0]
  output  [17:0]  LEDR, //  LED Red[17:0]
  //  GPIO Connections
  inout  [35:0]  GPIO_0, GPIO_1
);
//  set all inout ports to tri-state
assign  GPIO_0    =  36'hzzzzzzzzz;
assign  GPIO_1    =  36'hzzzzzzzzz;

// Connect dip switches to red LEDs
assign LEDR[17:0] = SW[17:0];
wire [15:0] A;
assign bin = 1'b0;
//    A <= SW[15:0];
// I am adding this code to subtractor 4 bits code
Subtractor4bit(sum,borrow,SW[3:0],SW[7:4],bin);
// Now I call the BCD here to convert the result to various HEX display.
//BCD(diff[7:0],ONES, TENS,HUNDREDS);
//hex_7seg dsp0(ONES,HEX0);
//hex_7seg dsp1(TENS,HEX1);
//hex_7seg dsp2(HUNDREDS,HEX2);
hex_7seg dsp0(sum,HEX0);
assign HEX1 = blank;
assign HEX2 = blank;
assign HEX3 = blank;
assign HEX4 = blank;
assign HEX5 = blank;
assign HEX6 = blank;
assign HEX7 = blank;
wire [6:0] blank = ~7'h00;
assign A = SW[15:0];
endmodule

module Subtractor4bit(dif, bor, x, y, bin);
   input [3:0] x, y;
   input  bin;
   output [3:0] dif;
   output  bor;
   wire [3:0]x, y, dif;
   wire bin, b1, b2, b3;
   Subtractor1bit sub3(dif[3], bor, x[3], y[3], b3);
   Subtractor1bit sub2(dif[2], b3, x[2], y[2], b2);
   Subtractor1bit sub1(dif[1], b2, x[1], y[1], b1);
   Subtractor1bit sub0(dif[0], b1, x[0], y[0], bin);
endmodule

//One version of the 1 bit subtractor
module Subtractor1bit(dif, bor, x, y, bin);
   input x, y, bin;
   output dif, bor;
   wire x, y, bin, dif, bor;
   wire   o1, o2, o3, o4, nx;
   not n(nx, x);                // Take the Not of X store it in nx
   or  b1(o1,  y, bin);         // Take the Y and bin   store it in o1
   and b2(o2, x, y, bin);       // Take the x and y and bin store it on o2
   and b31(o3, o1, nx);         // Take o1 and ~x store it in o3
   or  b4(bor, o2, o3);         // Take o2 or o3 and bor 
   xor d2(o4,  y, bin);         // Xor of y and bin 
   xor d3(dif, x, o4);          // xor  x and o4
endmodule

module hex_7seg(hex_digit,seg);
input [3:0] hex_digit;
output [6:0] seg;
reg [6:0] seg;
// seg = {g,f,e,d,c,b,a};
// 0 is on and 1 is off

always @ (hex_digit)
case (hex_digit)
        4'h0: seg = ~7'h3F;
        4'h1: seg = ~7'h06;     // ---a----
        4'h2: seg = ~7'h5B;     // |      |
        4'h3: seg = ~7'h4F;     // f      b
        4'h4: seg = ~7'h66;     // |      |
        4'h5: seg = ~7'h6D;     // ---g----
        4'h6: seg = ~7'h7D;     // |      |
        4'h7: seg = ~7'h07;     // e      c
        4'h8: seg = ~7'h7F;     // |      |
        4'h9: seg = ~7'h67;     // ---d----
        4'ha: seg = ~7'h77;
        4'hb: seg = ~7'h7C;
        4'hc: seg = ~7'h39;
        4'hd: seg = ~7'h5E;
        4'he: seg = ~7'h79;
        4'hf: seg = ~7'h71;
endcase
endmodule

module BCD(
input  [7:0] binary,
output reg [3:0] Hundreds,
output reg[3:0] Tens,
output reg[3:0] Ones
);
integer i; 
always @ (binary)
begin 
//set 100's 10's and 1's to zero
Hundreds = 4'd0;
Tens     = 4'd0;
Ones     = 4'd0;
for(i=7; i >= 0; i=i-1)
begin
      if(Hundreds >= 5)
           Hundreds = Hundreds + 3;
		if(Tens >= 5)
           Tens = Tens + 3;
		if(Ones >= 5)
           Ones = Ones + 3;
	//Shift left one bit
	Hundreds = Hundreds << 1;
	Hundreds[0]=Tens[3];
	Tens = Tens << 1;
	Tens[0]= Ones[3];
	Ones = Ones << 1;
	Ones[0]=binary[i];
end     // begin end comes
end     // begin end comes
endmodule
