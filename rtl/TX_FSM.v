//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
// Description: Transmitter state machine
// Date: 27/09/2024
// Release:	
// Designers : Mohamed Ruby
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------




module Tx_FSM(TxByteClk, TxRst, TxRequest,DphyTxState, LPTX_EN, TxReadyHS , TxValid);


// Inputs and Outputs
input TxRst;
input TxByteClk;
input TxReadyHS;
input [2:0]DphyTxState;
input TxRequest;
input LPTX_EN;
output TxValid;
// DphyTxState is the state of the HS FSM
/*	 TX_HS_STOP = 3'b000;
     TX_HS_GO = 3'b001;        // Transmit HS-0
     TX_HS_SYNC = 3'b011;
     TX_HS_DATA = 3'b010;
     TX_HS_TRAIL = 3'b110;*/

// States of the FSM
parameter TX_IDLE 	= 2'b00;   
parameter TX_SEND_DATA 	= 2'b01; // Transmit data bytes
parameter TX_EOT 	= 2'b10; 
parameter TX_WAIT_ACK 	= 2'b11; // Wait Acknowledge

// Timing parameters
parameter ACK_TIME    	  = 8'h0A;

reg  TxValid_reg;
reg [1:0] tx_state;
reg [1:0] nxt_state;
reg [7:0] ack_timer;


always @ (posedge TxDDRClk, negedge TxRst)
	begin
		if (!TxRst)
			begin
				//reset registers and timers to zero
				TxValid_reg  	<= 1'b0;	
				tx_state       		<= TX_IDLE;
				ack_timer      		<= 8'h00;
				
			end
		else 
			begin
				//next state logic
				tx_state <= nxt_state;
			end
	end


always @ (*) begin
				case (tx_state)
					TX_IDLE : //stop state
						begin
							if (TxRequest)
								begin
									nxt_state 	<= TX_SEND_DATA;
									TxValid_reg  	<= 1'b1;
									ack_timer   	<= 8'h00;
								end
							else 
								begin
									TxValid_reg    <= 1'b0;
									ack_timer      <= 8'h00;	
								end
						end	
					TX_SEND_DATA : 
				
						begin
							if (TxRequest == 1'b0)
								begin
									nxt_state          <= TX_EOT;
								end
							else 
								begin
									nxt_state <= TX_SEND_DATA;
								end
						end
					TX_EOT : // EOT state
						begin
							if (ack_timer == ACK_TIME or Ack_Rcvd) 	// Ack_Rcvd ????
								begin
									TxValid_reg     <= 1'b0;
									ack_timer	  <= 8'h00;
									nxt_state 	  <= TX_IDLE;    // stop state
								end
							else
								begin
									ack_timer   	<= ack_timer + 1;
								end
						end
					default : 
						begin
							TxValid_reg    <= 1'b0;
							ack_timer      <= 8'h00;
							nxt_state      <= TX_IDLE;
						end	
				endcase
end			

	



assign TxValid       = TxValid_reg;


endmodule
