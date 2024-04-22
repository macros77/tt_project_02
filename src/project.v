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
    
    reg [4:0] state = 0;
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

    reg [7:0] bus_dir = 1;
    assign uio_oe  = bus_dir;
    
    reg [7:0] dataDB = 0;
    assign uio_out = dataDB;
    
    always@(posedge clk) begin
      if (reset) begin
        PC <= 0;
        state <= 0;      
      end
          case (state)
            0: begin
                memWE <= 1;
                latchLE <= 1;
                dataDB <= PC;
                state <= 1;
            end
            1: begin
                latchLE <= 0;       
                state <= 2;
            end
            2: begin
                dataDB <= memory[PC];
                state <= 3;
            end            
            3: begin
                memWE <= 0;
                if (PC==255) begin
                  PC <= 0;
                  state <= 4;
                end
                else begin
                  PC <= PC + 1;
                  state <= 0;
                end
            end   
            // addrA            
            4: begin   
                memWE <= 1;
                memOE <= 1;
                latchLE <= 1;
                dataDB <= PC;
                state <= 5;
            end 
            5: begin
                latchLE <= 0;
                state <= 6;
            end 
            6: begin
                memOE <= 0;
                state <= 7;
            end                            
            7: begin
              addrA <= uio_in;
              state <= 8;              
            end
            // addrB            
            8: begin   
                memWE <= 1;
                memOE <= 1;
                latchLE <= 1;
                dataDB <= PC+1;
                state <= 9;
            end 
            9: begin
                latchLE <= 0;
                state <= 10;
            end 
            10: begin
                memOE <= 0;
                state <= 11;
            end                            
            11: begin
              addrB <= uio_in;
              state <= 12;              
            end           
            // addrC            
            12: begin   
                memWE <= 1;
                memOE <= 1;
                latchLE <= 1;
                dataDB <= PC+2;
                state <= 13;
            end 
            13: begin
                latchLE <= 0;
                state <= 14;
            end 
            14: begin
                memOE <= 0;
                state <= 15;
            end                            
            15: begin
              addrC <= uio_in;
              state <= 16;              
            end             
            // valA            
            16: begin   
                memWE <= 1;
                memOE <= 1;
                latchLE <= 1;
                dataDB <= addrA;
                state <= 17;
            end 
            17: begin
                latchLE <= 0;
                state <= 18;
            end 
            18: begin
                memOE <= 0;
                state <= 19;
            end                            
            19: begin
              valA <= uio_in;
              state <= 20;              
            end             
            // valB           
            20: begin   
                memWE <= 1;
                memOE <= 1;
                latchLE <= 1;
                dataDB <= addrB;
                state <= 21;
            end 
            21: begin
                latchLE <= 0;
                state <= 22;
            end 
            22: begin
                memOE <= 0;
                state <= 23;
            end                            
            23: begin
              valB <= uio_in;
              state <= 24;              
            end            
            // SUBNEG logic                
            24: begin
                valC <= valB - valA;
                memWE <= 1;
                memOE <= 1;
                latchLE <= 1;
                dataDB <= addrB;
                state <= 25;
            end
            25: begin
                latchLE <= 0;       
                state <= 26;
            end
            26: begin
                dataDB <= valC;
                state <= 27;
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
