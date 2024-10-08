// Description : D-PHY LP-TX module which consists HighSpeed, LowPower and Escape modes 
// Date : 11/9/2024
// Revision notes : 
// Designer : Mohamed Ruby 


module LP_TX (
		input  TxRequestHS,	     // Upper layer contorls the lane module {SOT and EOT }
						       	//also the clk lane {HS clk , LP clk} and indicates that there is a valid data on TxByteHS
		input  LPTX_EN,        // if enable low, Dp_reg and Dn_reg set to high impedance
		input  TxRSt, 
		input  LPTX_CLK,          // LP clock = 10 Mb/sec
		output reg HSTX_EN, 
		output reg HSCLK_EN,	 
		output  Dp, 
		output  Dn);

	// Internal signals
	reg Dp_reg ;
	reg Dn_reg ;
	wire gated_LPTX_CLK;

	// Clock gating
	assign gated_LPTX_CLK = LPTX_CLK & LPTX_EN;

	// Time Configuration Parameters. LP-TIME = 10, HSPREPARE_TIME = 15, HSEXIT_TIME = 20 
	parameter LPX_TIME = 10;		// HS Request state driving LP-01 
	parameter HSPREPARE_TIME = 15;	// HS-Prepare (or bridge) state driving LP-00
	parameter HSEXIT_TIME = 20;		// 
	
	// FSM states
	localparam  TX_STOP    = 2'b00;
	localparam  TX_HS_Rqst = 2'b01;
	localparam  TX_HS_Prpr = 2'b10;
	localparam  TX_HS_Exit = 2'b11;
	
	reg [1:0] cnt_state;
	reg [1:0] nxt_state;
	reg [4:0] timer;
	
	always @ (posedge gated_LPTX_CLK or negedge TxRSt) begin 
		if (!TxRSt ) begin		// Sync rest active low 
			cnt_state <= TX_STOP;
			nxt_state <= TX_STOP;
			timer <= 0;
			Dp_reg <= 1'bz;
			Dn_reg <= 1'bz;
			HSTX_EN <= 1'bz;
			HSCLK_EN <= 1'bz;
		end
		
		else if (LPTX_EN) begin
			cnt_state <= nxt_state;
			if (cnt_state != TX_STOP)begin
				timer <= timer + 1;
			end else begin 
				timer <= 0;
			end
			
		end
	end 

	always @(*)begin
		if (LPTX_EN && TxRSt == 1'b1)begin	
		case (cnt_state)
			TX_STOP: begin 
						// IDLE state set LP11 untill TxRequestHS high for upper layer to request HS mode
						Dp_reg = 1'bz;
						Dn_reg = 1'bz;
						  if (TxRequestHS)begin 
							nxt_state <= TX_HS_Rqst;
							
						 end else begin 	// TX_STOP (IDLE) state, assert LP-11 
							nxt_state <= TX_STOP;
						 end
						end	
			
			TX_HS_Rqst: begin 
						Dp_reg <= 1'b0;
						Dn_reg <= 1'b1;
						//repeat (LPX_TIME) @(posedge LPTX_CLK); // pre-configured time before entering HS
						if (timer >= LPX_TIME)begin		   // go to  the bridge state after 10 clk cycles 
						nxt_state <= TX_HS_Prpr; timer <= 0;  end
					end 
			
			TX_HS_Prpr: begin
						Dp_reg 	 <= 1'b0;		   
						Dn_reg 	 <= 1'b0;

						if (timer >= HSPREPARE_TIME)begin
							HSTX_EN	 <= 1'b1;  // Enable high speed transmision
							HSCLK_EN <= 1'b1;  // Enable high speed clock
							//repeat (HSPREPARE_TIME) @(posedge LPTX_CLK); 
					
							if (!TxRequestHS)begin	// check if TxRequestHS goes low to exit the HS mode
								HSTX_EN	 <= 1'b0;  // Disable high speed transmision
								HSCLK_EN <= 1'b0;  // Disable high speed clock
								timer <= 0;
								nxt_state <= TX_HS_Exit;
							end
						end	
					end
					
			TX_HS_Exit: begin 
						// LP-TX transmits sequence of ONES for THS-EXIT time
						// and returns to Tx-STOP state
						Dp_reg <= 1'b1;
						Dn_reg <= 1'b1;
						//repeat  (HSEXIT_TIME) @(posedge LPTX_CLK);
						if (timer >= HSEXIT_TIME)begin	// HSEXIT_TIME = 20 
						nxt_state <= TX_STOP; timer <= 0; end
					end
			default : begin 
						Dp_reg <= 1'bz;
						Dn_reg <= 1'bz;
						nxt_state <= TX_STOP;
					end
						 
		endcase
		end 
	
	end

	// Upper Layer Enable. If LPTX_EN = zero, Dp_reg,Dn_reg set to high impedence.
	assign Dp = Dp_reg;
	assign Dn = Dn_reg;
	
endmodule // End of LP_TX module 




///////////////////////////////////////////////////////////////////////////////
//
//							Direct TestBench for this LP_TX module
//
//////////////////////////////////////////////////////////////////////////////

/*module LP_TX_TB (); // uncomment this if u wanna use the below tb 
	// Define the inputs and outputs signals
	reg LPTX_CLK = 1'b0; 
	reg TxRSt  ;
	reg LPTX_EN  ;
	reg TxRequestHS ;
	wire HSTX_EN;
	wire HSCLK_EN;
	wire Dp;
	wire Dn;
	
	// clock generation
	initial begin forever  #10 LPTX_CLK = ~ LPTX_CLK; end 
	
	// Make instance of the DUT (LP_TX module) 
	LP_TX LP(.LPTX_CLK(LPTX_CLK), .TxRSt(TxRSt), .LPTX_EN(LPTX_EN), .HSTX_EN(HSTX_EN), .HSCLK_EN(HSCLK_EN), .Dp(Dp), .Dn(Dn));
	
	
	initial begin 
		$monitor (" Rest = %b, \n LPTX_EN = %b, \n HSTX_EN = %b, \n HSCLK_EN = %b, \
 Dp_reg = %b, \n Dn_reg = %b ", TxRSt, LPTX_EN, HSTX_EN, HSCLK_EN, Dp,Dn );
		
		// Assert initial signals 
			TxRSt 	= 0;
			LPTX_EN = 0;
			TxRequestHS = 0;

		// After 500 ns request HS 	
		#500  TxRSt = 1;			
			  LPTX_EN = 1;
			  TxRequestHS = 1;


		// check the Tx-STOP state
		//TxRequestHS <= 0;
		//$display ("IDLE state .......");
		
		
	
	end
	

endmodule */// for tb