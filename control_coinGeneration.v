module control_coinGeneration(
	input clk,
	input reset_n,
	input go,
	output reg [7:0] ox_loc,
	output reg [6:0] oy_loc
);

	reg[3:0] previous_track, current_state, next_state;

   localparam TRACK_1        = 6'd0,
				  TRACK_1_WAIT   = 6'd1,
				  TRACK_2        = 6'd2,
				  TRACK_2_WAIT   = 6'd3,
				  TRACK_3        = 6'd4,
				  TRACK_3_WAIT   = 6'd5;
	always @(*) 
	begin:state_table
		case (current_state)
		TRACK_1: 
		begin
		next_state=(go)?TRACK_1_WAIT:TRACK_1;
		previous_track<=TRACK_1;
		end
		
		TRACK_1_WAIT:
		begin
		next_state=(go)?TRACK_1_WAIT:TRACK_2;
		end
		
		TRACK_2: 
		begin
		next_state=(go)?TRACK_2_WAIT:TRACK_2;
		end
		
		TRACK_2_WAIT:
		begin
		if(go)
		next_state=TRACK_2_WAIT;
		else
		next_state=(previous_track==TRACK_1)?TRACK_3:TRACK_1;
		end
		
		TRACK_3: 
		begin
		next_state=(go)?TRACK_3_WAIT:TRACK_3;
		previous_track=TRACK_3;
		end
		
		TRACK_3_WAIT:
		begin
		next_state=(go)?TRACK_3_WAIT:TRACK_2;
		end
		
		default:
		next_state=TRACK_1;
		
		endcase
	end
	
	always @(posedge clk) begin
		if(!reset_n)
		current_state<=TRACK_1;
		else
		current_state<=next_state;
	end
	always @(*) 
	begin:output_logic
		case (current_state)
			TRACK_1: //track_output = 2'b00;
			begin
			ox_loc<= 8'd30;
			oy_loc<= 7'd0;
			end
			TRACK_1_WAIT:
			begin
			ox_loc<= 8'd30;
			oy_loc<= 7'd0;
			end
			TRACK_2: //track_output = 2'b01;
			begin
			ox_loc<= 8'd70;
			oy_loc<= 7'd0;
			end
			TRACK_2_WAIT:
			begin
			ox_loc<= 8'd70;
			oy_loc<= 7'd0;
			end
			TRACK_3: //track_output = 2'b10;
			begin
			ox_loc<=8'd110;
			oy_loc<=7'd0;
			end
			TRACK_3_WAIT:
			begin
			ox_loc<=8'd110;
			oy_loc<=7'd0;
			end
			default: 
			begin//track_output = 2'b00;
			ox_loc<=8'd0;
			oy_loc<=7'd0;
			end
		endcase
	
	end
endmodule
