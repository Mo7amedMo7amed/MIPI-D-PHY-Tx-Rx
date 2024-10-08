// Description : High Speed Transmitter module
// Date : 11/9/2024
// Revision :
// Designer : Mohamed Ruby

module HS_TX(
		input TxRst,
		input TxDDRClk,
		input TxByteClk,
		input HSTX_EN,		// Enable HS mode from LP_Tx
		input HSCLK_EN,		// Enable HS clock from LP_Tx 
		input [7:0] DataIn,
		output HS_Dp,
		output HS_Dn,
		output TxReadyHS,
		output [2:0]DphyTxState);
		
		// Clock gating logic
    	wire gated_TxByteClk;
		wire gated_TxDDRClk;
		assign gated_TxByteClk = TxByteClk & HSTX_EN;
		assign gated_TxDDRClk = TxDDRClk & HSTX_EN;

		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//
		//				8b-to-2b Seriallizer
		//
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		wire ser_b1;		// 1st bit of the output serialized data
		wire ser_b2;		// 2nd bit of the output serialized data
		wire serializer_enable;
		wire [7:0] DataOut;


		Serializer_8b2b #(.WIDTH(8)) ser8b_2b (.TxDDRClk(gated_TxDDRClk), .TxByteClk(gated_TxByteClk), .TxRst(TxRst), .DataIn(DataOut),
		 .serializer_enable(HSTX_EN), .ser_b1(ser_b1), .ser_b2(ser_b2));

		//--------------------------------------------------------------------------
		//--------------------------------------------------------------------------	
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//
		//						Dual Edge Flip Flop 
		//
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		wire SOT;
		wire Mux_Out;
		
		assign HS_Dp = Mux_Out;
		assign HS_Dn = ~Mux_Out;
		
		DEFF deff(.ser_b1(ser_b1), .ser_b2(ser_b2), .TxDDRClk(gated_TxDDRClk), .TxRst(TxRst), .SOT(HSTX_EN), .Mux_Out(Mux_Out));	
		
		//--------------------------------------------------------------------------
		//--------------------------------------------------------------------------	
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//
		//						Finite State Machine
		//
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		TX_HS_FSM tx_fsm(.TxDDRClk(gated_TxDDRClk), .TxRst(TxRst), .HSTX_EN(HSTX_EN), .DataIn(DataIn),
		 					.TxReadyHS(TxReadyHS), .DphyTxState(DphyTxState), .DataOut(DataOut));

endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//							Direct TestBench for this HS_TX module
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*module HS_TX_TB(); // Uncomment this if u wanna use the below TestBench
	reg TxDDRClk=0;
	reg TxByteClk=0;
	reg TxRst;
	reg HSTX_EN;
	reg [7:0] DataIn;
	wire TxReadyHS;
	wire [2:0] DphyTxState;
	wire HS_Dp;
	wire HS_Dn;

		// clock generation
	initial begin forever  #10 TxDDRClk = ~ TxDDRClk; end 
	initial begin forever  #40 TxByteClk = ~ TxByteClk; end 

	// Make instance of the DUT (HS_TX module) 
	HS_TX HS(.TxDDRClk(TxDDRClk),.TxByteClk(TxByteClk), .TxRst(TxRst), .HSTX_EN(HSTX_EN), .DataIn(DataIn), .TxReadyHS(TxReadyHS),
	 			.DphyTxState(DphyTxState), .HS_Dp(HS_Dp), .HS_Dn(HS_Dn));

	// TestBench
	initial begin
		// Reset
		TxRst = 1'b0;
		HSTX_EN = 1'b0;
		DataIn = 8'h00;

		#10 TxRst = 1'b1;
		#10 HSTX_EN = 1'b1;

	end

	// Stimulus random data
    always begin
    #50;
    @(negedge TxDDRClk) DataIn = $random & 8'hFF;
    end

endmodule*/