module control_carMovement(
    input clk,
    input reset_n,
    input wire switch_left,
    input wire switch_right,
	 output reg [7:0] erase_x,
	 output reg [6:0] erase_y,
	 output reg [7:0] ox_loc,
	 output reg [6:0] oy_loc
);

	parameter X_SCREEN_PIXELS= 8'd160;
	parameter Y_SCREEN_PIXELS= 7'd120;
	
    reg[5:0] current_state, next_state, prev_state;

    localparam TRACK_1        = 6'd0,
					TRACK_1_WAIT 	= 6'd1,
					TRACK_2        = 6'd2,
					TRACK_3        = 6'd3,
					TRACK_3_WAIT	= 6'd4;
					
	// Define next-state logic
	always @(*) 
	begin:state_table
		case (current_state)
			TRACK_1: begin
			next_state = switch_right ? TRACK_1_WAIT : TRACK_1;
			prev_state = TRACK_1;
			end
			TRACK_1_WAIT: next_state = switch_right? TRACK_1_WAIT : TRACK_2;
			
			TRACK_2: begin
			next_state = switch_left ? TRACK_1 : (switch_right ? TRACK_3 : TRACK_2);
			prev_state = TRACK_2;
			end
			
			TRACK_3: begin
			next_state = switch_left ? TRACK_3_WAIT : TRACK_3;
			prev_state = TRACK_3;
			end
			
			TRACK_3_WAIT: next_state = switch_left? TRACK_3_WAIT : TRACK_2;
			default: next_state = TRACK_2;
		endcase
	end

	//current state registers
	always @(posedge clk) begin
		if (!reset_n)
			current_state <= TRACK_2;  // Initial state
		else
			current_state <= next_state;
	end
	
	// Define output logic
	always @(*) 
	begin:output_logic
		case (current_state)
			TRACK_1: //track_output = 2'b00;
			begin
			erase_x<= 8'd70;
			erase_y<= 8'd85;
			
			ox_loc<=8'd30;
			oy_loc<=7'd85;
			end
			TRACK_1_WAIT:
			begin
			ox_loc<=8'd30;
			oy_loc<=7'd85;
			end
			
			TRACK_2: //track_output = 2'b01;
			begin
			if(prev_state==TRACK_1) begin
			erase_x<=8'd30;
			erase_y<=7'd85;
			end
			if(prev_state==TRACK_3) begin
			erase_x<=8'd110;
			erase_y<=7'd85;
			end
			
			ox_loc<=8'd70;
			oy_loc<=7'd85;
			end
			
			TRACK_3: //track_output = 2'b10;
			begin
			erase_x<= 8'd70;
			erase_y<= 8'd85;
			ox_loc<=8'd110;
			oy_loc<=7'd85;
			end
			
			TRACK_3_WAIT:
			begin
			ox_loc<=8'd110;
			oy_loc<=7'd85;
			end
			
			default:
			begin//track_output = 2'b00;
			ox_loc<=8'd0;
			oy_loc<=7'd0;
			end
			
		endcase
	end
	
endmodule