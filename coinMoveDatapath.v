/*module Tester(clk, rst_n, speed, oplot);
	input clk, rst_n, speed;
	output oplot;
	
	wire enable;
	Ratedivider R1(.clk(clk), .Resetn(rst_n), .Enable(enable));
	FrameCounter F1(.clk(clk), .resetn(rst_n), .speed(speed), .iEN(enable), .plotEN(oplot));
endmodule*/



module Ratedivider (
    input clk, 
    input Resetn, 
    output reg Enable
);
    parameter CLOCK_FREQUENCY = 50000000;
    parameter COUNT_VALUE = 833332; 

    reg [$clog2(CLOCK_FREQUENCY)*4:0] counter=0;


    always@(posedge clk) begin
		if(!Resetn)
			counter<=0;
	   else if(counter==COUNT_VALUE) begin
	      Enable<=1'b1;
	      counter<=0;
			end
		else begin
			counter<=counter+1;
			Enable<=1'b0;
	    end
		end
endmodule

module FrameCounter(clk, resetn, speed, iEN, plotEN);
	input clk, resetn, speed, iEN;
	output reg plotEN;
	
	reg [3:0] FrameNumber;
	reg [3:0] Value;
	
	
	always @(posedge clk) begin
		if(iEN==1'b1) begin
		case(speed)
			1'b0 : FrameNumber=4'd6;
			1'b1 : FrameNumber=4'd15;
			default : FrameNumber =4'd0;
		endcase
		end
	
		if(!resetn) begin
			Value<=4'b0;
		end
		else if(Value==FrameNumber)
			begin
			Value<=4'b0;
			plotEN<=1'b1;
			end
		else if(iEN==1'b1)begin
			Value<=Value+1;
			plotEN<=1'b0;
			end
		else  plotEN<=1'b0;
	end
endmodule