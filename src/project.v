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

    wire reset = ! rst_n;
    
    reg [4:0] state = 4;
    reg [7:0] PC = 0;
    reg [7:0] addrA = 0;
    reg [7:0] addrB = 0;
    reg [7:0] addrC = 0;
    reg [7:0] valA = 0;
    reg [7:0] valB = 0;
    reg [7:0] valC = 0;

    assign uo_out[7:3] = 0;

    // Latch input
    reg latchLE = 1;
    assign uo_out[0] = latchLE; 
       
    // SRAM output
    reg memOE = 1;
    assign uo_out[1] = memOE;  

    // SRAM write
    reg memWE = 1;
    assign uo_out[2] = memWE; 

    // Bus direction
    assign uio_oe  =  (memOE) ? 8'b11111111 : 8'b00000000;
    
    reg [7:0] dataDB = 0;
    assign uio_out = dataDB;
    
    always@(posedge clk) begin
          if (reset) begin
            PC <= 0;
            state <= 4;      
          end
          case (state)
            // addrA            
            4: begin   
                memWE <= 1;
                memOE <= 1;
                latchLE <= 1;
                dataDB <= PC;
                state <= state + 1;
            end 
            5: begin
                latchLE <= 0;
                state <= state + 1;
            end 
            6: begin
                memOE <= 0;
                state <= state + 1;
            end                            
            7: begin
              addrA <= uio_in;
              state <= state + 1;              
            end
            // addrB            
            8: begin   
                memWE <= 1;
                memOE <= 1;
                latchLE <= 1;
                dataDB <= PC+1;
                state <= state + 1;
            end 
            9: begin
                latchLE <= 0;
                state <= state + 1;
            end 
            10: begin
                memOE <= 0;
                state <= state + 1;
            end                            
            11: begin
              addrB <= uio_in;
              state <= state + 1;              
            end           
            // addrC            
            12: begin   
                memWE <= 1;
                memOE <= 1;
                latchLE <= 1;
                dataDB <= PC+2;
                state <= state + 1;
            end 
            13: begin
                latchLE <= 0;
                state <= state + 1;
            end 
            14: begin
                memOE <= 0;
                state <= state + 1;
            end                            
            15: begin
              addrC <= uio_in;
              state <= state + 1;             
            end             
            // valA            
            16: begin   
                memWE <= 1;
                memOE <= 1;
                latchLE <= 1;
                dataDB <= addrA;
                state <= state + 1;
            end 
            17: begin
                latchLE <= 0;
                state <= state + 1;
            end 
            18: begin
                memOE <= 0;
                state <= state + 1;
            end                            
            19: begin
              valA <= uio_in;
              state <= state + 1;             
            end             
            // valB           
            20: begin   
                memWE <= 1;
                memOE <= 1;
                latchLE <= 1;
                dataDB <= addrB;
                state <= state + 1;
            end 
            21: begin
                latchLE <= 0;
                state <= state + 1;
            end 
            22: begin
                memOE <= 0;
                state <= state + 1;
            end                            
            23: begin
              valB <= uio_in;
              state <= state + 1;              
            end            
            // SUBNEG logic                
            24: begin
                valC <= valB - valA;
                memWE <= 1;
                memOE <= 1;
                latchLE <= 1;
                dataDB <= addrB;
                state <= state + 1;
            end
            25: begin
                latchLE <= 0;       
                state <= state + 1;
            end
            26: begin
                dataDB <= valC;
                state <= state + 1;
            end            
            27: begin
                if (valA>valB) PC <= addrC;
                else PC <= PC + 3;
                if (addrB!=255) memWE <= 0;                                  
                state <= 4;                
            end              
          endcase
    end    

endmodule
