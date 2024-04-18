/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_macros77_subneg (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    assign uio_out = 0;
    assign uio_oe  = 0;

    wire reset = ! rst_n;

    reg [7:0] memory[21:0];
   
    reg [1:0] state = 0;
    reg [4:0] PC = 0;
    reg [4:0] addrA = 0;
    reg [4:0] addrB = 0;
    reg [4:0] addrC = 0;
    reg [7:0] valA = 0;
    reg [7:0] valB = 0;

    reg [7:0] display = 0;
    assign uo_out = display;
    
    always@(posedge clk) begin
      if (reset) begin
        PC <= 0;
        state <= 0;
        memory[0] <=	18;
        memory[1] <=	18;
        memory[2] <=	3;
        memory[3] <=	19;
        memory[4] <=	20;
        memory[5] <=	0;
        memory[6] <=	20;
        memory[7] <=	18;
        memory[8] <=	9;
        memory[9] <=	18;
        memory[10] <=	21;
        memory[11] <=	12;
        memory[12] <=	18;
        memory[13] <=	18;
        memory[14] <=	15;
        memory[15] <=	19;
        memory[16] <=	18;
        memory[17] <=	0;
        memory[18] <=	0;
        memory[19] <=	1;
        memory[20] <=	255;
        memory[21] <=	255;       
      end
      case (state)
        0: begin
            addrA <= memory[PC];
            addrB <= memory[PC+1];
            addrC <= memory[PC+2];
            state <= 1;
        end
        1: begin
            valA <= memory[addrA];
            valB <= memory[addrB];         
            state <= 2;
        end
        2: begin
            if (addrB==21) display <= (valB - valA); 
            else memory[addrB] <= (valB - valA);           
            if (valA>valB) PC <= addrC;
            else PC <= PC + 3;
            state <= 0;
        end            
      endcase
    end    

endmodule
