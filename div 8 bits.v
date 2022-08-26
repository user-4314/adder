// This is to start the multiply module
// It begins here.
module div8(
// Clock Input (50 MHz)
  input  CLOCK_50,
  //  Push Buttons
  input  [3:0]  KEY,
  //  DPDT Switches 
  input  [17:0]  SW,
  
   //  7-SEG Displays
  output  [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
  output [15:0] sum,
  output cout,
  // This is added to the convert the 8-bits to different HEX_
  output [3:0] ONES, TENS,
  output [3:0] HUNDREDS,
  output [3:0] THOUSANDS,
  output [3:0] TENTHOUSANDS,
  output  [1:0] finaltenthousand,
  
  
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
//always @(negedge KEY[3])
//    A <= SW[15:0];
// The algorithm to be used comes here.
//module divu(dividend, divisor, St, clk, quotient);
// input [7:0] dividend; input [3:0] divisor; input St, clk; 
//output [3:0] quotient;
divu(SW[7:0],SW[15:8],KEY[0],KEY[1],sum[3:0]); 

// Before assigning the 8-bit sum to different HEX,
// we call this module to send the desired decimal.
// multiply_to_BCD(A,ONES, TENS, HUNDREDS);
BCD(sum[15:0],TENTHOUSANDS,THOUSANDS,HUNDREDS,TENS,ONES);
//assign finaltenthousand = {2'b00,TENTHOUSANDS[1:0]};
hex_7seg dsp0(ONES,HEX0);
hex_7seg dsp1(TENS,HEX1);
hex_7seg dsp2 (HUNDREDS, HEX2);
hex_7seg dsp3 (THOUSANDS, HEX3);
hex_7seg dsp4(TENTHOUSANDS,HEX4);

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

module divu(dividend, divisor, St, clk, quotient); 
input [7:0] dividend; 
input [3:0] divisor; 
input St, clk; 
output [3:0] quotient;
reg [2:0] state, nextstate; 
reg [7:0] X; 
reg [3:0] Y; 
wire [4:0] Subout; 
wire sub;
initial 
begin 
state = 0; 
nextstate = 0; 
X = 0; 
Y = 0; 
end
assign quotient = X[3:0]; 
assign sub = (X[7:3] >= Y)? 1 : 0; 
assign Subout = X[7:3] - Y;
always @(posedge clk) 
begin 
case(state) 
	0: begin 
	    if(St == 1) 
		begin X <= dividend; 
		      Y <= divisor; 
		      state <= 1; 
		end 
		 else 
		   state <= 0; 
		end 
	1,2,3,4:  begin 
          if(sub == 1) begin 
         X[7:4] <= Subout[3:0]; 
		   X[3:0] <= {X[2:0],1'b1}; 
		end 
        else 
			X <= {X[6:0], 1'b0}; 
		   if(state < 4) 
			  state <= state + 1; 
		else 
          state <= 0; 
			end 
	  default: begin 
	  end
	  endcase
	  end
endmodule

module BCD(
input  [15:0] binary,
output reg[3:0]Tenthousands,
output reg[3:0]Thousands,
output reg [3:0] Hundreds,
output reg[3:0] Tens,
output reg[3:0] Ones
);
integer i; 
always @ (binary)
begin 
//set 100's 10's and 1's to zero
Tenthousands = 4'd0;
Thousands    = 4'd0;
Hundreds     = 4'd0;
Tens         = 4'd0;
Ones         = 4'd0;
for(i=15; i >= 0; i=i-1)
begin
      if(Tenthousands >=5)
          Tenthousands = Tenthousands+ 3;
       if(Thousands >=5)
           Thousands = Thousands + 3;
      if(Hundreds >= 5)
           Hundreds = Hundreds + 3;
		if(Tens >= 5)
           Tens = Tens + 3;
		if(Ones >= 5)
           Ones = Ones + 3;
	//Shift left one bit
        Tenthousands = Tenthousands <<1;
        Tenthousands[0]=Thousands[3];
        Thousands = Thousands << 1;
        Thousands[0] = Hundreds[3];
	Hundreds = Hundreds << 1;
	Hundreds[0]=Tens[3];
	Tens = Tens << 1;
	Tens[0]= Ones[3];
	Ones = Ones << 1;
	Ones[0]=binary[i];
end     // begin end comes
end     // begin end comes
endmodule
