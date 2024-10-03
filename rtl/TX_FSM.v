//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
// Description: Transmitter state machine
// Date: 27/09/2024
// Release:	
// Designers : Mohamed Ruby
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------




module tx_fsm(TxDDRClk, TxRst, TxRequest, TxByteHS, TxValid,TxDataOut);

// Inputs and Outputs
input TxRst;
input TxDDRClk;
input [7:0] TxByteHS;
input TxRequest;
output TxValid;
output [7:0] TxDataOut;


// States of the FSM
parameter TX_IDLE 	= 2'b00;   
parameter TX_SEND_DATA 	= 2'b01; // Transmit data bytes
parameter TX_EOT 	= 2'b10; 
parameter TX_WAIT_ACK 	= 2'b11; // Wait Acknowledge

// Timing parameters
parameter ACK_TIME    	  = 8'h0A;

reg  TxValid_reg;
reg [7:0] TxByte_reg;
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
									TxByte_reg      <= 8'h00;	
									ack_timer   	<= 8'h00;
								end
							else 
								begin
									TxValid_reg    <= 1'b0;
									TxByte_reg     <= 8'h11;
									ack_timer      <= 8'h00;	
								end
						end	
					TX_SEND_DATA : 
				
						begin
							if (TxRequest == 1'b0)
								begin
									TxByte_reg        <= 8'h00;	
									nxt_state          <= TX_EOT;
								end
							else 
								begin
									TxByte_reg     <= TxByteHS;	
									nxt_state <= TX_SEND_DATA;
								end
						end
					TX_EOT : // EOT state
						begin
							if (ack_timer == ACK_TIME or Ack_Rcvd) 	// Ack_Rcvd ????
								begin
									TxValid_reg     <= 1'b0;
									TxByte_reg      <= 8'h00;	// send zeros
									ack_timer	  <= 8'h00;
									nxt_state 	  <= TX_IDLE;    // stop state
								end
							else
								begin

									TxByte_reg      <= 8'h00;	// send zeros
									ack_timer   	<= ack_timer + 1;
								end
						end
					default : 
						begin
							TxValid_reg    <= 1'b0;
							TxByte_reg     <= 8'h00;
							ack_timer      <= 8'h00;
							nxt_state      <= TX_IDLE;
						end	
				endcase
end			

	



assign TxDataOut    = TxByte_reg;
assign TxValid       = TxValid_reg;


endmodule
