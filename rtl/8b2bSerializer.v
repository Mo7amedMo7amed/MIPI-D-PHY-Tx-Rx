// Description : 8 bits to 2 bits serializer
// Date : 22/9/2024
// Revision :
// Designer : Mohamed Ruby


module Serializer_8b2b #(parameter WIDTH = 8)(input TxDDRClk, input TxByteClk, input TxRst, input [WIDTH-1:0]DataIn, input serializer_enable, output  ser_b1, output  ser_b2);
	
		integer counter;
		reg [3:0] reg1;
		reg [3:0] reg2;
		
		// Edge detection from TxByteClk to use it as an enable signal not as a clock signal
		reg last_TxByteClk;
		wire TxByteClk_trigger;

		always @(*)begin
			if (TxByteClk_trigger && serializer_enable)begin 	// Using ByteClk as enable signal to avoid some timing issues
						reg1 <= {DataIn[7],DataIn[5],DataIn[3],DataIn[1]};
						reg2 <= {DataIn[6],DataIn[4],DataIn[2],DataIn[0]};
			end
		end
		
		always @(posedge TxDDRClk or negedge TxRst)begin 
			if (!TxRst)begin
				counter <= 0;
				last_TxByteClk <= 1'b0;
				reg1 <= 4'b0000;
				reg2 <= 4'b0000;
			end else begin							// if (serializer_enable)begin
					last_TxByteClk <= TxByteClk;
					if (counter < 3)begin 			// 4clk cycles of DDRClk
						counter <= counter + 1;		// required to store one byte from DataIn
					end else begin 
							counter <= 0;					
						end					
				end
			end	
		
		// Get the parallel DataIn serialized from the shift registers
		assign ser_b1 = serializer_enable ? reg1[counter] : 1'bz;
		assign ser_b2 = serializer_enable ? reg2[counter] : 1'bz;
		assign TxByteClk_trigger = ~last_TxByteClk && TxByteClk;
				
			
endmodule 			



/////////////////////////////////////////////////////////////////////////////////////////////
//
//							Direct TestBench for this 8bit to 2bit serializer 
//
/////////////////////////////////////////////////////////////////////////////////////////////

/*module Serializer_TB (); // Uncomment this if u wanna use the below TestBench 
	// Define the inputs and outputs signals
	localparam WIDTH = 8;
	reg TxDDRClk  = 1'b1; 
	reg TxByteClk = 1'b1;
	reg TxRst  ;
	reg serializer_enable  ;
	reg [WIDTH-1:0]DataIn;
	wire ser_b1;
	wire ser_b2;

	
	// clock generation
	initial begin forever  #10 TxDDRClk = ~ TxDDRClk; end 
	initial begin forever  #40 TxByteClk = ~ TxByteClk; end 


	// Make instance of the DUT (LP_TX module) 
	Serializer_8b2b #(.WIDTH(8))ser(.TxDDRClk(TxDDRClk), .TxByteClk(TxByteClk), .TxRst(TxRst), .DataIn(DataIn), .serializer_enable(serializer_enable), .ser_b1(ser_b1), .ser_b2(ser_b2));
	
	
	initial begin 
		$monitor (" Rest = %b, \n serializer_enable = %b, \n ser_b1 = %b, \n ser_b2 = %b, \n DataIn = %b ", TxRst, serializer_enable, ser_b1, ser_b2, DataIn);
		
		// Assert initial signals 
			TxRst 	= 0;
			serializer_enable = 0;
			DataIn = 8'b00000000;
			
			#100 TxRst = 1;
			serializer_enable = 1;
			DataIn = 8'b10101010;
			#80 DataIn = 8'b01010101;
			#80 DataIn = 8'b00110011;
			#80 DataIn = 8'b00001111;
			#80 DataIn = 8'b11001100;
			#80 DataIn = 8'b00110011;
			#80 DataIn = 8'b11111111;
			#80 DataIn = 8'b00000000;
			#80 DataIn = 8'b10101010;
			#80 DataIn = 8'b01010101;
			#80 DataIn = 8'b11110000;
			#80 DataIn = 8'b00001111;
			#80 DataIn = 8'b11001100;
			#80 DataIn = 8'b00110011;
			#80 DataIn = 8'b11111111;
			#80 DataIn = 8'b00000000;
			#80 DataIn = 8'b10101010;
			#80 DataIn = 8'b01010101;
			#100 DataIn = 8'b11110000;
			#100 DataIn = 8'b00001111;
			#100 DataIn = 8'b11001100;
			#150 DataIn = 8'b00110011;
			#150 DataIn = 8'b11111111;
			#150 DataIn = 8'b00000000;
			#70 DataIn = 8'b10101010;
			#70 DataIn = 8'b01010101;
			#40 DataIn = 8'b11110000;
			#40 DataIn = 8'b00001111;
			#40 DataIn = 8'b11001100;
			#40 DataIn = 8'b00110011;

		
	
	end
	

endmodule  */ // Delete this comment to use the TestBench