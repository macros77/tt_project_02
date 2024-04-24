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
    reg [7:0] addr_A = 0;
    reg [7:0] addr_B = 0;
    reg [7:0] addr_C = 0;
    reg [7:0] val_A = 0;
    reg [7:0] val_B = 0;

    assign uo_out[7:4] = state[3:0];

    // Latch outout
    reg out_CLK = 0;
    assign uo_out[3] = out_CLK;
    
    // Latch memory address
    reg latch_CLK = 0;
    assign uo_out[0] = latch_CLK; 
       
    // SRAM output
    reg mem_OE = 1;
    assign uo_out[1] = mem_OE;  

    // SRAM write
    reg mem_WE = 1;
    assign uo_out[2] = mem_WE; 

    // Bus direction
    assign uio_oe  =  (mem_OE) ? 8'b11111111 : 8'b00000000;
    
    reg [7:0] data_bus = 0;
    assign uio_out = data_bus;
    
    always@(posedge clk) begin

          if (reset) begin
            PC <= 0;
            state <= 0;
            out_CLK <= 0;
          end

          case (state)

            // addr_A            
            0: begin   
                out_CLK <= 0;
                mem_WE <= 1;
                mem_OE <= 1;
                latch_CLK <= 0;
                data_bus <= PC;
                state <= state + 1;
            end 
            1: begin
                latch_CLK <= 1;
                state <= state + 1;
            end 
            2: begin
                mem_OE <= 0;
                state <= state + 1;
            end                            
            3: begin
              addr_A <= uio_in;
              state <= state + 1;              
            end

            // addr_B            
            4: begin   
                mem_WE <= 1;
                mem_OE <= 1;
                latch_CLK <= 0;
                data_bus <= PC+1;
                state <= state + 1;
            end 
            5: begin
                latch_CLK <= 1;
                state <= state + 1;
            end 
            6: begin
                mem_OE <= 0;
                state <= state + 1;
            end                            
            7: begin
              addr_B <= uio_in;
              state <= state + 1;              
            end         

            // addr_C            
            8: begin   
                mem_WE <= 1;
                mem_OE <= 1;
                latch_CLK <= 0;
                data_bus <= PC+2;
                state <= state + 1;
            end 
            9: begin
                latch_CLK <= 1;
                state <= state + 1;
            end 
            10: begin
                mem_OE <= 0;
                state <= state + 1;
            end                            
            11: begin
              addr_C <= uio_in;
              state <= state + 1;             
            end     

            // val_A            
            12: begin   
                mem_WE <= 1;
                mem_OE <= 1;
                latch_CLK <= 0;
                data_bus <= addr_A;
                state <= state + 1;
            end 
            13: begin
                latch_CLK <= 1;
                state <= state + 1;
            end 
            14: begin
                mem_OE <= 0;
                state <= state + 1;
            end                            
            15: begin
              val_A <= uio_in;
              state <= state + 1;             
            end            

            // val_B           
            16: begin   
                mem_WE <= 1;
                mem_OE <= 1;
                latch_CLK <= 0;
                data_bus <= addr_B;
                state <= state + 1;
            end 
            17: begin
                latch_CLK <= 1;
                state <= state + 1;
            end 
            18: begin
                mem_OE <= 0;
                state <= state + 1;
            end                            
            19: begin
              val_B <= uio_in;
              state <= state + 1;              
            end      

            // SUBNEG logic                
            20: begin
                mem_WE <= 1;
                mem_OE <= 1;
                latch_CLK <= 0;
                data_bus <= addr_B;
                state <= state + 1;
            end
            21: begin
                latch_CLK <= 1;       
                state <= state + 1;
            end
            22: begin
                data_bus <= val_B - val_A;
                state <= state + 1;
            end            
            23: begin
                if (val_A>val_B) PC <= addr_C;
                else PC <= PC + 3;
                if (addr_B != 255) mem_WE <= 0;   
                else out_CLK <= 1;
                state <= state + 1;               
            end                         
            24: begin
                state <= 0;
            end 
              
          endcase
          
    end    

endmodule
