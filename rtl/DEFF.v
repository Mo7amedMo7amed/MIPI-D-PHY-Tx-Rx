// Description : Dual Edge Flip Flop
// Date : 23/9/2024
// Revision :
// Designer : Mohamed Ruby

module DEFF (
    input ser_b1,
    input ser_b2,
    input TxDDRClk,
    input TxRst,
    input SOT,
    output Mux_Out
);

    reg FF1_Out;
    reg FF2_Out;

    always @(posedge TxDDRClk or negedge TxRst)begin
        if (!TxRst)begin 
            FF1_Out <= 1'b0;
        end else begin
        //if (rising_edge)begin 
            FF1_Out <= ser_b1;
        end
    end
    
    always @(negedge TxDDRClk or negedge TxRst)begin
        if (!TxRst)begin 
            FF2_Out <= 1'b0;
        end else begin
       // if (falling_edge)begin 
            FF2_Out <= ser_b2;
        end
    end
    
    // output multiplexer
    assign  Mux_Out = SOT ? (FF1_Out & FF2_Out | TxDDRClk & FF2_Out | (~TxDDRClk & FF1_Out)) : (1'bz);



endmodule

/////////////////////////////////////////////////////////////////////////////////////////////
//
//							Direct TestBench for this Dual Edge Flip Flop 
//
/////////////////////////////////////////////////////////////////////////////////////////////

/*module DEFF_TB (); // Uncomment this if u wanna use the below TestBench 
	// Define the inputs and outputs signals
	reg TxDDRClk  = 1'b1; 
	reg TxRst  ;
	reg ser_b1;  
    reg ser_b2;
    reg SOT;
	wire Mux_Out;


	
	// clock generation
	initial begin forever  #10 TxDDRClk = ~ TxDDRClk; end 

	// Make instance of the DUT (LP_TX module) 
    DEFF deff(.ser_b1(ser_b1), .ser_b2(ser_b2), .TxDDRClk(TxDDRClk), .TxRst(TxRst), .SOT(SOT), .Mux_Out(Mux_Out));	
	
	initial begin 
        $monitor (" Rest = %b, \n ser_b1 = %b, \n ser_b2 = %b, \n Mux_Out = %b ", TxRst, ser_b1, ser_b2, Mux_Out);
		// Assert initial signals 
            TxRst 	= 0;
            ser_b1 = 0;
            ser_b2 = 0;
            SOT = 0;
            
            #100 TxRst = 1;
            ser_b1 = 1;
            ser_b2 = 1;
            SOT = 1;
            #80 ser_b1 = 0;
            ser_b2 = 0;
            SOT = 0;
            #80 ser_b1 = 0;
            ser_b2 = 1;
            SOT = 1;
            #80 ser_b1 = 1;
            ser_b2 = 0;
            SOT = 0;
            #80 ser_b1 = 1;
            ser_b2 = 1;
            SOT = 1;
            #80 ser_b1 = 0;
            ser_b2 = 0;
            SOT = 0;
            #80 ser_b1 = 0;
            ser_b2 = 1;
            SOT = 1;
            #80 ser_b1 = 1;
            ser_b2 = 0;
            SOT = 0;
            #80 ser_b1 = 1;
            ser_b2 = 1;
            SOT = 1;
            #80 ser_b1 = 0;
            ser_b2 = 0;
            SOT = 0;
            #80 ser_b1 = 0;
            ser_b2 = 1;
            SOT = 1;
            #80 ser_b1 = 1;
            ser_b2 = 0;
            SOT = 0;
            #80 ser_b1 = 1;
            ser_b2 = 1;
            SOT = 1;
            #80 ser_b1 = 0;
            ser_b2 = 0;
            SOT = 0;
            #80 ser_b1 = 0;
            ser_b2 = 1;
            SOT = 1;
            #80 ser_b1 = 1;
            ser_b2 = 0;
            SOT = 0;
            #80 ser_b1 = 1;
            ser_b2 = 1;
		
	
	end
	

endmodule*/  // Delete this comment to use the TestBench