//This module is the highest level of the module.
// it includes all the input and output in the DE2-70
module mul4(
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
  output [7:0] sum,
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
// I am adding this code to multiply 4 bit code
shift_add_mul(SW[3:0],SW[7:4],sum[7:0],1'b0);
// Now I call the BCD here to convert the result to various HEX display.
BCD(sum[7:0],HUNDREDS,TENS,ONES);
hex_7seg dsp0(ONES,HEX0);
hex_7seg dsp1(TENS,HEX1);
hex_7seg dsp2(HUNDREDS,HEX2);
assign HEX3 = blank;
assign HEX4 = blank;
assign HEX5 = blank;
assign HEX6 = blank;
assign HEX7 = blank;

wire [6:0] blank = ~7'h00;
assign A = SW[15:0];
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

module shift_add_mul(x,y,z,reset); 
input [3:0] x,y; 
input reset; 
output [7:0] z; 
//wire co,ci; 
reg [7:0] t; 
reg [7:0] z; 
integer i,j; 

always @ (x or y or reset ) 
begin 
if(reset) 
z = 8'b0; 
//j = 0; 
for(i = 0; i < 4 ; i = i + 1) 
begin 
t = 8'b0; 
if(y[i]) 
begin 
  t[i] = x[0]; 
t[i+1] = x[1]; 
t[i+2] = x[2]; 
t[i+3] = x[3]; 
end 
z = z + t; 
end 
end
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
