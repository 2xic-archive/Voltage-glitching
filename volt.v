`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:39:28 04/14/2019 
// Design Name: 
// Module Name:    volt 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////


module volt(
		clk,
		power,
		ANODE,
		CATODE,
		UP,
		DOWN,
		GLITCH
    );
	input clk;
	input UP;
	input DOWN;
	input GLITCH;
	
	output power;

	output reg [3:0] ANODE;
	output reg [6:0] CATODE;
	
	reg [26:0] time_counter = 0;
	
	reg power = 1'b1;
	reg [1:0] do_glitch = 0;
	reg [15:0] displayed_number = 0;
	
		
	localparam [26:0] button_delay = 19999999; 
	localparam [26:0] delay_voltage_drop = 999999;; 
	
	reg [26:0] current_max_count = button_delay;
	
	always @(posedge clk )
    begin
				
			if(time_counter >= current_max_count) begin
				time_counter <= 0;
				
				if(UP) begin
					if(displayed_number < 9999) begin
						displayed_number <= displayed_number + 1;
					end
				end
			
				if(DOWN) begin
					if(displayed_number > 0) begin
						displayed_number <= displayed_number - 1;
					end				
				end
				
				if(do_glitch[0] == 1) begin
					if(displayed_number > 0) begin
						displayed_number <= displayed_number - 1;
					end
					else begin
						do_glitch[0] = 0;
						current_max_count = button_delay;
						power=1'b1;
					end
				end
			end
			else begin
				time_counter <= time_counter + 1;
			end
		
		if(GLITCH) begin
			current_max_count = delay_voltage_drop;
			do_glitch[0] = 1;
			power=1'b0;
		end
		
    end    
	
	
	/*
		Count display
	*/
	
	reg [19:0] refresh_counter;
	wire [1:0] LED_activating_counter; 
	assign LED_activating_counter = refresh_counter[19:18];
	
	always @(posedge clk)
    begin 
        refresh_counter <= refresh_counter + 1;
    end 
	assign LED_activating_counter = refresh_counter[19:18];

	reg [3:0] LED_BCD;
	always @(*)
    begin
        case(LED_activating_counter)
        2'b00: begin
            ANODE = 4'b0111; 
            LED_BCD = displayed_number/1000;
              end
        2'b01: begin
            ANODE = 4'b1011; 
            LED_BCD = (displayed_number % 1000)/100;
              end
        2'b10: begin
            ANODE = 4'b1101; 
            LED_BCD = ((displayed_number % 1000)%100)/10;
                end
        2'b11: begin
            ANODE = 4'b1110; 
            LED_BCD = ((displayed_number % 1000)%100)%10;
               end
        endcase
    end
	
	always @(*)
    begin
        case(LED_BCD)
        4'b0000: CATODE = 7'b0000001; // "0"     
        4'b0001: CATODE = 7'b1001111; // "1" 
        4'b0010: CATODE = 7'b0010010; // "2" 
        4'b0011: CATODE = 7'b0000110; // "3" 
        4'b0100: CATODE = 7'b1001100; // "4" 
        4'b0101: CATODE = 7'b0100100; // "5" 
        4'b0110: CATODE = 7'b0100000; // "6" 
        4'b0111: CATODE = 7'b0001111; // "7" 
        4'b1000: CATODE = 7'b0000000; // "8"     
        4'b1001: CATODE = 7'b0000100; // "9" 
        default: CATODE = 7'b0000001; // "0"
        endcase
    end
endmodule
