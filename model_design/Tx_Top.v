// Description : 
// Date : 11/9/2024
// Revision :
// Designer :

module Tx_Top (
    input TxDDRClk,
    input TxByteClk,
    input TxRst,
    input  TxRequestHS,
    input [7:0] DataIn,	
    output Dp,
    output Dn,


);

    // Internal signals
    wire LP_Dp, LP_Dn, HS_Dp, HS_Dn;
    wire [2:0] DphyTxState;
    wire HSCLK_EN, HSTX_EN, LPTX_EN, TxReadyHS;


    // Instansiate the LP_TX module, HS_TX module and FSM module
    HS_TX HS(.TxDDRClk(TxDDRClk),.TxByteClk(TxByteClk), .TxRst(TxRst), .HSCLK_EN(HSCLK_EN), .HSTX_EN(HSTX_EN), .DataIn(DataIn), .TxReadyHS(TxReadyHS),
	 			.DphyTxState(DphyTxState), .HS_Dp(HS_Dp), .HS_Dn(HS_Dn));

    LP_TX LP(.LPTX_CLK(TxByteClk), .TxRSt(TxRst), .TxRequestHS(TxRequestHS), .LPTX_EN(LPTX_EN), .HSTX_EN(HSTX_EN),
                 .HSCLK_EN(HSCLK_EN), .Dp(LP_Dp), .Dn(LP_Dn));

    Tx_FSM FSM(.TxByteClk(TxByteClk), .TxRst(TxRst), .LPTX_EN(LPTX_EN), .TxRequestHS(TxRequestHS),
                 .DphyTxState(DphyTxState));                         

    // Drive the output data lines 
    assign Dp = (HSTX_EN) ? HS_Dp : LP_Dp;
    assign Dn = (HSTX_EN) ? HS_Dn : LP_Dn;
   

endmodule 