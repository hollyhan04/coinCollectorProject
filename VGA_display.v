module VGA_display
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		KEY,							// On Board Keys
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   						//	VGA Blue[9:0]
		
		SW
	);

	input			CLOCK_50;				//	50 MHz
	input	[3:0]	KEY;
	input	[3:0] SW;
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn = 1'b1;
	
	wire drawStartEN;
	wire gameOverEN;
	wire backgroundEN;
	wire drawcoinEN;
	wire eraseCoinEN;
	wire drawCarEN;
	wire eraseCarEN;
	wire moveCoinEN;
	
	wire doneDrawStart;
	wire doneDrawCoin;
	wire doneEraseCoin;
	wire doneDrawBackground;
	wire doneDrawCar;
	wire doneEraseCar;
	wire doneDrawGameOver;
	
	wire [7:0]icoinX;
	wire [6:0]icoinY;
	wire [7:0]icarX;
	wire [6:0]icarY;
	
	
	
	control u1(
	 .clock(CLOCK_50),
	 .resetn(resetn),
	 .speed(SW[0]),
	 .switchLeft(KEY[2]),
	 .switchRight(KEY[1]),
	 .go(KEY[3]),
	 
	 .start(SW[1]),
	 .finish(SW[2]),
	 
	 .drawStartEN(drawStartEN),
	 .gameOverEN(gameOverEN),
	 .backgroundEN(backgroundEN),
	 .drawCoinEN(drawcoinEN),
	 .eraseCoinEN(eraseCoinEN),
	 .drawCarEN(drawCarEN),
	 .eraseCarEN(eraseCarEN),
	 .moveCoinEN(moveCoinEN),
	 .plot(writeEn),
	 
	 .doneDrawStart(doneDrawStart),
	 .doneDrawCoin(doneDrawCoin),
	 .doneEraseCoin(doneEraseCoin),
	 .doneDrawBackground(doneDrawBackground),
	 .doneDrawCar(doneDrawCar),
	 .doneEraseCar(doneEraseCar),
	 .doneDrawGameOver(doneDrawGameOver),
	
	 .coinXPosition(icoinX),
	 .coinYPosition(icoinY),
	 .carXPosition(icarX),
	 .carYPosition(icarY)
);
	
	wire hitcoin;
	datapath u0(
		.clock(CLOCK_50),
		.resetn(resetn),
		.coin_x_loc(icoinX),
		.coin_y_loc(icoinY),
		.car_x_loc(icarX),
		.car_y_loc(icarY),
		.drawStartEN(drawStartEN),
		.drawCoinEN(drawcoinEN),
		.eraseCoinEN(eraseCoinEN),
		.drawBackgroundEN(backgroundEN),
		.drawGameOverEN(gameOverEN),
		.drawCarEN(drawCarEN),
		.eraseCarEN(eraseCarEN),
		.moveCoinEN(moveCoinEN),
		
		.doneDrawStart(doneDrawStart),
		.doneDrawCoin(doneDrawCoin),
	   .doneEraseCoin(doneEraseCoin),
	   .doneDrawBackground(doneDrawBackground),
	   .doneDrawCar(doneDrawCar),
	   .doneEraseCar(doneEraseCar),
	   .doneDrawGameOver(doneDrawGameOver),
		
		.xout(x),
		.yout(y),
		.colourOut(colour)

	);
	
	//Instantiate gameState
	/*gameState g0(
		.clock(CLOCK_50),
		.reset(resetn),
		.car_x(ocarX),
		.car_y(ocarY),
		.coin_x(ocoinX),
		.coin_y(ocoinY),
		.hitCoin(hitcoin),
		.game_state(gameState),
		.left_pressed(left),
		.right_pressed(right),
		.generate_coin_enable(go)
		);*/

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK)
			);
			
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "gameStartNew.mif";

endmodule	
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	module datapath(
		input clock,
		input resetn,
		input [7:0]coin_x_loc,
		input [6:0]coin_y_loc,
		input [7:0]car_x_loc,
		input [6:0]car_y_loc,
		input drawStartEN,
		input drawCoinEN,
		input eraseCoinEN,
		input drawBackgroundEN,
		input drawGameOverEN,
		input drawCarEN,
		input eraseCarEN,
		input moveCoinEN,
		
		output reg [7:0]xout,
		output reg [6:0]yout,
		output reg [2:0]colourOut,
		
		
		output reg doneDrawStart,
		output reg doneDrawCoin,
		output reg doneEraseCoin,
		output reg doneDrawBackground,
		output reg doneDrawCar,
		output reg doneEraseCar,
		output reg doneDrawGameOver
	
	);
	
	//--------------------RAM-------------------------------
	wire [2:0] startScreenColourtoDisplay;
	wire [2:0] gameOverColourtoDisplay;
	wire [2:0] backgroundColourtoDisplay;
	wire [2:0] coinColourtoDisplay;
	wire [2:0] carColourtoDisplay;
	reg [14:0] startScreenAddress = 15'b0;
	reg [14:0] backgroundAddress = 15'b0;
	reg [14:0] gameOverAddress = 15'b0;
	reg [11:0] carAddress =12'b0;
	reg [11:0] coinAddress = 12'b0;
	
	reg [7:0]car_x;
	reg [6:0]car_y;
	reg [7:0]coin_x;
	reg [6:0]coin_y;
	
	
	gameStart game0(
		.address(startScreenAddress),
		.clock(clock),
		.data(3'b0),
		.wren(1'b0),
		.q(startScreenColourtoDisplay)
	);
	
	TrackbackgroundMemory T1(
		.address(backgroundAddress),
		.clock(clock),
		.data(3'b0),
		.wren(1'b0),
		.q(backgroundColourtoDisplay)
	);
	
	gameOverMemory p1(
		.address(gameOverAddress),
		.clock(clock),
		.data(3'b0),
		.wren(1'b0),
		.q(gameOverColourtoDisplay)
	);
	
	coinMemory CM1(
		.address(coinAddress),
		.clock(clock),
		.data(3'b0),
		.wren(1'b0),
		.q(coinColourtoDisplay)
	);
	carMemory carM1(
		.address(carAddress),
		.clock(clock),
		.data(3'b0),
		.wren(1'b0),
		.q(carColourtoDisplay)
	);
		
	reg [7:0]currentXPosition;
	reg [6:0]currentYPosition;
	reg [7:0]xCount;
	reg [6:0]yCount;
	
	reg [6:0] yCountertoMove;
	
	reg [7:0]currentCoinXPosition;
	reg [6:0]currentCoinYPosition;
	reg [4:0]coinXcount;
	reg [4:0]coinYcount;
	
	reg [7:0]currentCarXPosition;
	reg [6:0]currentCarYPosition;
	reg [4:0]carXcount;
	reg [5:0]carYcount;

	
always@(posedge clock)begin
		if(!reset_n）
			xCount <= 8'd0;
		else if(xCount==8'd159 || backgroundAddress==15'd19199 || (xout==8'd159 && yout == 7'd119) )
			xCount<=8'd0;
		else
			xCount<=xCount+1;
end
		
always@(posedge clock)begin
		if(!reset_n)
			yCount <= 7'd0
		else if(backgroundAddress==15'd19199 ||(xout==8'd159 && yout == 7'd119))
			yCount <= 7'd0;
		else if(xCount==8'd159)
			yCount <= yCount + 1;
		else
			yCount <= yCount;
end
			
always@(posedge clock)begin
		  if(reset_n)
			colorOut <= 3'b0;
		  else if((eraseCoinEN& !doneEraseCoin)||(eraseCarEN&&!doneEraseCar))
			colorOut <= 3'b0;
		  else if(drawBackgroundEN&&!doneDrawBackground)
			colourOut<= backgroundColourtoDisplay;
	      else if(drawGameOverEN&&!doneDrawGameOver)
			colourOut<= gameOverColourtoDisplay;
		  else if(drawCoinEN&&!doneDrawCoin)
			colourOut<= coinColourtoDisplay;
		 else if(drawCarEN&&!doneDrawCar)
			colourOut<= carColourtoDisplay;
		  else if(!(drawStartEN&&!doneDrawStart))
			colourOut<= startScreenColourtoDisplay;
		 else
			colorOut <= colorOut
end
		
always @(posedge clock) begin
    if (!resetn)
        coinXcount <= 5'd0;
	else if(coinAddress==12'd399)
		coinXcount <= 5'd0;
    else if (coinXcount == 5'd19)
        coinXcount <= 5'd0;
    else
        coinXcount <= coinXcount + 1;
end

always @(posedge clock) begin
		if (!resetn)
			coinYcount <= 5'd0;
		else if(coinAddress==12'd399)
			coinYcount<=5'd0;
		else if (coinXcount == 5'd19)
			coinYcount <= coinYcount + 1;
		else
			coinYcount <= coinYcount;
end

 always @(posedge clock) begin
     if (!resetn)
        carXcount <= 5'd0;
     else if ((carXcount == 5'd19) || (carAddress==12'd799))
        carXcount <= 5'd0;
     else
        carXcount <= carXcount + 1;
 end

always @(posedge clock) begin
    if (!resetn)
        carYcount <= 6'd0;
	else if((carAddress==12'd799) || (carYcount == 6'd39)
		carYcount<=5'd0;
    else if (carXcount == 5'd19)
        carYcount <= carYcount + 1;
    else
        carYcount <= carYcount;
end
	
	
always @(posedge clock) begin
    if (!resetn)
        doneDrawStart <= 1'b0;
    else if (drawStartEN && startScreenAddress == 15'd19199)
        doneDrawStart <= 1'b1;
    else
        doneDrawStart <= 1'b0;
end
	
always @(posedge clock) begin
    if (!resetn)
        doneDrawBackground <= 1'b0;
    else if (drawBackgroundEN && backgroundAddress == 15'd19199)
        doneDrawBackground <= 1'b1;
    else
        doneDrawBackground <= 1'b0;
end
	
always @(posedge clock) begin
    if (!resetn)
        doneDrawGameOver <= 1'b0;
    else if (drawGameOverEN && gameOverAddress == 15'd19199)
        doneDrawGameOver <= 1'b1;
    else
        doneDrawGameOver <= 1'b0;
end
	
always @(posedge clock) begin
    if (!resetn)
        doneDrawCoin <= 1'b0;
    else if (drawCoinEN && coinAddress == 12'd399)
        doneDrawCoin <= 1'b1;
    else
        doneDrawCoin <= 1'b0;
end
	
always @(posedge clock) begin
    if (!resetn)
        doneEraseCoin <= 1'b0;
    else if (eraseCoinEN && coinXcount == 5'd19 && coinYcount == 5'd19)
        doneEraseCoin <= 1'b1;
    else
        doneEraseCoin <= 1'b0;
end
	
always @(posedge clock) begin
    if (!resetn)
        doneDrawCar <= 1'b0;
    else if (drawCarEN && carAddress == 12'd799)
        doneDrawCar <= 1'b1;
    else
        doneDrawCar <= 1'b0;
end
	
always @(posedge clock) begin
    if (!resetn)
        doneEraseCar <= 1'b0;
    else if (eraseCarEN && carXcount == 5'd19 && carYcount == 6'd39)
        doneEraseCar <= 1'b1;
    else
        doneEraseCar <= 1'b0;
end
	
always @(posedge clock) begin
    if (!resetn)
        startScreenAddress <= 15'b0;
    else if (drawStartEN && !doneDrawStart)
		if(xCount==8'd0&&yCount==7'd0)
			startScreenAddress<=15'b0;
		else
			startScreenAddress <= startScreenAddress + 1;
    else if(backgroundAddress==15'd19199)
		startScreenAddress<=15'b0;
	else
        startScreenAddress <= startScreenAddress;
end
	
	always @(posedge clock) begin
    if (!resetn)
        backgroundAddress <= 15'b0;
    else if (drawBackgroundEN && !doneDrawBackground)
        backgroundAddress <= backgroundAddress + 1;
	else if(backgroundAddress==15'd19199)
		backgroundAddress<=15'b0;
    else
        backgroundAddress <= backgroundAddress;
	end
	
	always @(posedge clock ) begin
    if (!resetn)
        gameOverAddress <= 15'b0;
    else if (drawGameOverEN && !doneDrawGameOver)
        gameOverAddress <= gameOverAddress + 1;
	else if(xout==8'd159 && yout == 7'd119)
		gameOverAddress <= 15'b0;
    else
        gameOverAddress <= gameOverAddress;
	end
	
	always @(posedge clock) begin
    if (!resetn)
        coinAddress <= 12'b0;
	else if(coinAddress==12'd399)
		coinAddress <= 12'b0;
    else if (drawCoinEN && !doneDrawCoin)
        coinAddress <= coinAddress + 1;
    else
        coinAddress <= coinAddress;
	end
	
	always @(posedge clock or negedge resetn) begin
    if (!resetn)
        carAddress <= 12'b0;
	else if(carAddress==12'd799)
		carAddress <= 12'b0
	else if (drawCarEN && !doneDrawCar)
        carAddress <= carAddress + 1;
    else
        carAddress <= carAddress;
	end
	
	always @(posedge clock) begin
    if (!resetn)
        xout <= 8'b0;
    else if (drawCoinEN && !doneDrawCoin)
        xout <= coin_x_loc + coinXcount;
    else if (drawCarEN && !doneDrawCar)
        xout <= car_x_loc + carXcount;
    else if (eraseCoinEN && !doneEraseCoin)
        xout <= coin_x + coinXcount;
    else if (eraseCarEN && !doneEraseCar)
        xout <= car_x + carXcount;
	else
		xout <= xout;
end

always @(posedge clock) begin
    if (!resetn)
        yout <= 7'b0;
    else if (drawCoinEN && !doneDrawCoin)
        yout <= coin_y_loc + yCountertoMove + coinYcount;
    else if (drawCarEN && !doneDrawCar)
        yout <= car_y_loc + carYcount;
    else if (eraseCoinEN && !doneEraseCoin)
        yout <= coin_y + yCountertoMove + coinYcount;
    else if (eraseCarEN && !doneEraseCar)
        yout <= car_y + carYcount;
	else
		yout <= yout;
end
	
always @(posedge clock) begin
    if (!resetn)
        yCountertoMove <= 7'b0;
    else if (moveCoinEN)
        yCountertoMove <= yCountertoMove + 5'd1;
	else 
		yCountertoMove <= yCountertoMove ;
end
	
always @(posedge clock) begin
    if (!resetn)
        coin_x <= 8'b0;
    else if (drawCoinEN && !doneDrawCoin)
        coin_x <= coin_x_loc;
	else
		coin_x <= coin_x;
end

always @(posedge clock) begin
    if (!resetn)
        coin_y <= 7'b0;
    else if (drawCoinEN && !doneDrawCoin)
        coin_y <= coin_y_loc + yCountertoMove;
	else
		coin_y <= coin_y;	
end

always @(posedge clock or negedge resetn) begin
    if (!resetn)
        car_x <= 8'b0;
    else if (drawCarEN && !doneDrawCar)
        car_x <= car_x_loc;
	else
		car_x <= car_x;
end

always @(posedge clock or negedge resetn) begin
    if (!resetn)
        car_y <= 7'b0;
    else if (drawCarEN && !doneDrawCar)
        car_y <= car_y_loc;
	else
		car_y <= car_y;
end

endmodule


module control(
	input clock,
	input resetn,
	input speed,
	input wire switchLeft,
	input wire switchRight,
	input wire go,

	
	input wire start,
	input wire finish,
	
	input doneDrawStart,
	input doneDrawCoin,
	input doneEraseCoin,
	input doneDrawBackground,
	input doneDrawCar,
	input doneEraseCar,
	input doneDrawGameOver,
	
	output reg drawStartEN,
	output reg gameOverEN,
	output reg backgroundEN,
	output reg drawCoinEN,
	output reg eraseCoinEN,
	output reg drawCarEN,
	output reg eraseCarEN,
	output reg moveCoinEN,
	output reg plot,
	
	output [7:0] coinXPosition,
	output [6:0] coinYPosition,
	output [7:0] carXPosition,
	output [6:0] carYPosition
);
	wire moveCoin;
	wire DelayCounterOut;
	reg [3:0]current_state, next_state;
	
	localparam DRAW_START_SCREEN=4'd0,
				  START            =4'd1,
				  DRAW_BACKGROUND  =4'd2,
				  DRAW_CAR         =4'd3,
				  DRAW_COIN        =4'd4,
				  ERASE_CAR        =4'd5,
				  FINISH           =4'd6,
				  ERASE_COIN       =4'd7;
				 

	control_coinGeneration coin1(
	.clk(clock),
	.reset_n(resetn),
	.go(go),
	.ox_loc(coinXPosition),
	.oy_loc(coinYPosition)
	);
	
	control_carMovement car1(
    	.clk(clock),
    	.reset_n(resetn),
    	.switch_left(switchLeft),
    	.switch_right(switchRight),
	 .ox_loc(carXPosition),
	 .oy_loc(carYPosition)
	);
	
	Ratedivider R1(
		.clk(clock), 
		.Resetn(resetn), 
		.Enable(DelayCounterOut)
		);
	
	FrameCounter F1(
		.clk(clock), 
		.resetn(resetn),
		.speed(speed),
		.iEN(DelayCounterOut),
		.plotEN(moveCoin)
		);

		
   always @(posedge clock) begin
	if (!resetn) begin
		next_state = DRAW_START_SCREEN;
	end else begin
		case (current_state)
			DRAW_START_SCREEN: begin
				if (doneDrawStart && start) begin
						next_state = START;
				else
					next_state = DRAW_START_SCREEN;
				end
			end

			START: 
				next_state = DRAW_BACKGROUND;

			DRAW_BACKGROUND: 
				next_state = doneDrawBackground ? DRAW_CAR : DRAW_BACKGROUND;

			ERASE_CAR: begin
				if (doneEraseCar)
					next_state = DRAW_CAR;
				else
					next_state = ERASE_CAR;
			end

			DRAW_CAR: begin
				if (doneDrawCar) begin
					if (!finish)
						next_state = FINISH;
					else if (switchLeft || switchRight)
						next_state = ERASE_CAR;
					else if (go)
						next_state = ERASE_COIN;
					else
						next_state = DRAW_COIN;
				end else begin
					next_state = DRAW_CAR;
				end
			end

			DRAW_COIN: begin
				if (doneDrawCoin) begin
					if (finish)
						next_state = FINISH;
					else if (switchLeft || switchRight)
						next_state = ERASE_CAR;
					else
						next_state = DRAW_COIN;
				end else begin
					next_state = DRAW_COIN;
				end
			end

			ERASE_COIN: begin
				if (doneEraseCoin)
					next_state = DRAW_COIN;
				else
					next_state = ERASE_COIN;
			end

			FINISH: begin
				if (doneDrawGameOver && start)
					next_state = DRAW_BACKGROUND;
				else
					next_state = FINISH;
			end

			default: 
				next_state = DRAW_START_SCREEN;
		endcase
	  end
    end

	always@(posedge clock)
		begin
			if(!resetn)
				current_state<=DRAW_START_SCREEN;
			else
				current_state<= next_state;
		end
		
	always @(*) begin
		if (!resetn) begin
		drawStartEN <= 1'b0;
		gameOverEN  <= 1'b0;
		backgroundEN <= 1'b0;
		drawCoinEN  <= 1'b0;
		eraseCoinEN <= 1'b0;
		drawCarEN   <= 1'b0;
		eraseCarEN  <= 1'b0;
		plot        <= 1'b0;
	end else begin
		case (current_state)
			DRAW_START_SCREEN: begin
				drawStartEN <= 1'b1;
				plot       <= 1'b1;
			end

			DRAW_BACKGROUND: begin
				backgroundEN <= 1'b1;
				plot         <= 1'b1;
			end

			DRAW_CAR: begin
				drawCarEN <= 1'b1;
				plot      <= 1'b1;
			end

			ERASE_CAR: begin
				eraseCarEN <= 1'b1;
				plot       <= 1'b1;
			end

			DRAW_COIN: begin
				drawCoinEN <= 1'b1;
				plot       <= 1'b1;
			end

			ERASE_COIN: begin
				eraseCoinEN <= 1'b1;
				plot        <= 1'b1;
			end

			FINISH: begin
				gameOverEN <= 1'b1;
				plot       <= 1'b1;
			end
			
			default: 
				drawStartEN <= 1'b0;
				gameOverEN  <= 1'b0;
				backgroundEN <= 1'b0;
				drawCoinEN  <= 1'b0;
				eraseCoinEN <= 1'b0;
				drawCarEN   <= 1'b0;
				eraseCarEN  <= 1'b0;
				plot        <= 1'b0;
				
		endcase
	end
end

	
	always@(*)begin
	 moveCoinEN = moveCoin;
	end
		
		
		
endmodule
