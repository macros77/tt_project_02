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
    
    reg [3:0] state = 0;
    reg [7:0] PC = 0;
    reg [7:0] addrA = 0;
    reg [7:0] addrB = 0;
    reg [7:0] addrC = 0;
    reg [7:0] valA = 0;
    reg [7:0] valB = 0;

    assign uo_out[7:3] = 0;

    reg LE = 1;
    reg MOE = 0;
    reg MWE = 0;
    assign uo_out[0] = LE;
    assign uo_out[1] = MOE;
    assign uo_out[2] = MWE;

    reg [7:0] bus_dir = 1;
    assign uio_oe  = bus_dir;
    reg [7:0] bus_data_out = 0;
    assign uio_out = bus_data_out;
    reg [7:0] bus_data_in;
    assign bus_data_in = uio_in;
    
    always@(posedge clk) begin
      if (reset) begin
        PC <= 0;
        state <= 0;      
      end
      case (state)
        0: begin
            bus_data_out <= PC;
            bus_dir <= 1;
            LE <= 1;
            MOE <= 0;
            MWE <= 0;
            state <= 1;
        end
        1: begin
            LE <= 0;
            MOE <= 1;
            MWE <= 0;
            state <= 2;
        end
        2: begin
            addrA <= bus_data_in;
            state <= 3;
        end          
        3: begin
//            if (addrB==21) display <= (valB - valA); 
//            else memory[addrB] <= (valB - valA);           
            if (valA>valB) PC <= addrC;
            else PC <= PC + 3;
            state <= 0;
        end            
      endcase
    end    

endmodule
