module UART_TX #(parameter W = 8)(    // W: parallel data width param
    input wire [W-1:0] P_INPUT,      // parallel input bus (of data width W)
    input wire V_INPUT,              // valid input signal (NOTE: assumed to be active for 1 clk cycle only)
    input wire CLK,                  // system clock i/p
    input wire RST,                  // reset input (active-low)
    input wire P_EN,                 // parity enable input
    input wire P_BIT,                // parity type input (either even or odd)
    output wire TX_OUTPUT,           // final transmitted bit (serial out bit) 
    output wire BUSY);               // high while UART is transmitting
    wire LOAD;                       // load control signal for serializer
    wire SHIFT_EN;                   // shift enabl control signal for serializer
    wire [1:0] MUX_SEL;              // mux select signal
    wire S_DATA;                     // serial data (serializer's out)
    wire CALC_PARITY;                // parity output before being saved
    reg saved_parity;                // saved parity bit for the current frame
    main_controller #(.W(W)) control_unit(.CLK(CLK), .RST(RST), .V_INPUT(V_INPUT), .P_EN(P_EN), .LOAD(LOAD), .SHIFT_EN(SHIFT_EN), .BUSY(BUSY), .MUX_SEL(MUX_SEL));
    serializer #(.W(W)) ser(.CLK(CLK), .RST(RST), .LOAD(LOAD), .SHIFT_EN(SHIFT_EN), .P_DATA(P_INPUT), .S_DATA(S_DATA));
    parity_calc #(.W(W)) parity_unit(.P_INPUT(P_INPUT), .P_BIT(P_BIT), .PARITY_BIT(CALC_PARITY));
    always@(posedge CLK or negedge RST) begin    // save parity when serializer loads a new input
        if(!RST)
            saved_parity <= 1'b0;                // clear saved parity if reset ( active-low)
        else if(LOAD)
            saved_parity <= CALC_PARITY;         // keep parity stable for the complete frame
    end
    mux output_mux(.S_DATA(S_DATA), .PARITY_BIT(saved_parity), .MUX_SEL(MUX_SEL), .TX_OUTPUT(TX_OUTPUT));
endmodule
