// Description : FSM for the high speed module in transmitter
// Date : 27/9/2024
// Revision :
// Designer : Mohamed Ruby


module TX_HS_FSM (
    input TxDDRClk,
    input TxRst,
    input HSTX_EN,          // SOT 
   // input HSCLK_EN,
    input [7:0] DataIn,
    output TxReadyHS,
    output [2:0] DphyTxState,
    output [7:0] DataOut
);
    // FSM states
    parameter TX_HS_STOP = 3'b000;
    parameter TX_HS_GO = 3'b001;        // Transmit HS-0
    parameter TX_HS_SYNC = 3'b011;
    parameter TX_HS_DATA = 3'b010;
    parameter TX_HS_TRAIL = 3'b110;

    // Timing parameters
    parameter HSZERO_TIME = 8'h0A;
    parameter HSTRAIL_TIME = 8'h0F;

    // Internal signals
    reg [2:0] tx_state;
    reg [2:0] next_state;
    reg [7:0] timer;
    reg TxValidHS_reg;
    reg TxReadyHS_reg;
    reg [7:0] TxByteHS_reg;
    wire SOT;
    reg Data_begin;     // This indicate the begining of the burst data input 

    // Output signals
    assign TxReadyHS = TxReadyHS_reg;
    assign DphyTxState = tx_state;
    assign SOT = HSTX_EN;



    always @(posedge TxDDRClk or negedge TxRst) begin 
    if (!TxRst)
        begin
            TxValidHS_reg <= 1'b0;
            TxReadyHS_reg <= 1'b0;
            TxByteHS_reg <= 8'hzz;
            tx_state <= TX_HS_STOP;
            timer <= 8'h00;
            Data_begin <= 1'b0;
        end
    else 
        begin
             tx_state <= next_state;
           if (tx_state == (TX_HS_GO))begin           // Update the timer  HS-0 PRE SYNC
               timer <= timer + 1;        
           end
           else if (tx_state ==TX_HS_TRAIL) begin
                timer <= timer + 1;  
           end else begin
            timer <= 8'h00;
              end 
        end
    end

    always @(*) begin
            case (tx_state)
            TX_HS_STOP:
                begin
                if (SOT)     // SOT = 1    
                begin
                   // TxValidHS_reg <= 1'b0;
                    TxReadyHS_reg <= 1'b1;
                    TxByteHS_reg <= 8'hzz;
                    next_state <= TX_HS_GO;
                    timer <= 8'h00;
                    Data_begin <= 1'b0;
                end
                else         // SOT = 0
                begin
                   // TxValidHS_reg <= 1'b0;
                    TxReadyHS_reg  <= 1'b0;
                    TxByteHS_reg  <= 8'hzz;
                    next_state <= TX_HS_STOP;
                    timer <= 8'h00;
                    Data_begin <= 1'b0;
                end
                end
            TX_HS_GO : // Send ZEOROS at start of transmission.
                begin
                    if (timer == HSZERO_TIME)
                    begin
                        next_state <= TX_HS_SYNC;
                        TxByteHS_reg <= 8'h00; // Send HS-0 PRE SYNC
                        timer <= 8'h00;
                end
                else
                    begin
                    TxByteHS_reg <= 8'h00;
                    end
                end     
            TX_HS_SYNC : // Send SYNC Symbol 'h1D (SOT symbol)
                    begin
                        Data_begin <= 1'b0;
                        TxByteHS_reg <= 8'h1D;
                        next_state <= TX_HS_DATA;
                    end           

            TX_HS_DATA : // Send the data
                    begin
                        Data_begin <= 1'b1;
                        TxByteHS_reg <= 8'h00;
                        if (!SOT) begin
                        Data_begin <= 1'b0; 
                        timer <= 8'h00;                           
                        next_state <= TX_HS_TRAIL;
                          end
                    end 
            TX_HS_TRAIL : // Send the trail
                    begin
                        if (timer == HSTRAIL_TIME)
                        begin
                            TxReadyHS_reg <= 1'b0;
                            TxByteHS_reg <= 8'h00;
                            timer <= 8'h00;
                            next_state <= TX_HS_STOP;
                        end
                        else
                        begin
                            TxByteHS_reg <= 8'h00;
                        end
                    end
           default: next_state <= TX_HS_STOP;         

        endcase  
    end  


    assign DataOut = Data_begin ? DataIn : TxByteHS_reg;

endmodule 


/////////////////////////////////////////////////////////////////////////////////////////////
//
//							Direct TestBench for this FSM
//
/////////////////////////////////////////////////////////////////////////////////////////////

/*module TX_HS_FSM_TB(); // Uncomment this if u wanna use the below TestBench
    reg TxDDRClk=0;
    reg TxRst;
    reg HSTX_EN;
    wire TxReadyHS;
    wire [2:0] DphyTxState;
    reg [7:0] DataIn;
    wire [7:0] DataOut;
    
    // Clock generation
    always
    begin
        #5 TxDDRClk = ~TxDDRClk;
    end

    // Instantiate the module
    TX_HS_FSM TX_HS_FSM_inst(
        .TxDDRClk(TxDDRClk),
        .TxRst(TxRst),
        .HSTX_EN(HSTX_EN),
        .TxReadyHS(TxReadyHS),
        .DphyTxState(DphyTxState),
        .DataIn(DataIn),
        .DataOut(DataOut)
    );

    // Initial values
    initial begin

    TxRst = 1'b0;
    HSTX_EN = 1'b0;
    DataIn = 8'h00;

    #100 TxRst = 1'b1;
    #110 HSTX_EN = 1'b1;

    #1000 HSTX_EN = 1'b0;
    end


    // Stimulus random data
    always begin
    #50;
    @(negedge TxDDRClk) DataIn = $random & 8'hFF;
    end


endmodule */