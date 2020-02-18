/*
	tanh (x) 	= 	-1 (x<-3)
				=	-0.39814608+0.46527859x+0.09007576x2	(-3<x<-1)
				=	0.0031444+1.08381219x+0.31592922x2		(-1<x<0)
				=	-0.00349517+1.08538355x-0.31676793x2	(0<x<1)
				=	0.39878032+0.46509003x-0.09013554x2		(1<x<3)
				=	1										(x>3)
*/

// it takes 5 cycles to compute the tanh function
module tanh (
	input clock, reset,
	input TANH_INPUT_PACKET packet_in,

	output TANH_OUTPUT_PACKET packet_out
	);

	// define intermedia
	logic [2*`LSTM_INPUT_BITS-1:0]	x_square, x_result, x_square_result;
	logic xquare_done, x_done, xsquare_const_done;
	logic [4:0] next_compare_flag, compare_flag;
	logic [`LSTM_INPUT_BITS-1:0] next_result;

	// define the coefficient
	logic [15:0] coeff_1, coeff_2, coeff_3, coeff_4, coeff_5, coeff_6, coeff_7, coeff_8, coeff_9, coeff_10, coeff_11, coeff_12;
	logic [15:0] next_coeff_x, next_coeff_x_square, next_coeff_const, coeff_x, coeff_const, coeff_x_square, coeff_const_delay_1, coeff_const_delayed_2;
	assign coeff_1 	= {8'hFF,8'b10011011}; //-0.39814608
	assign coeff_2 	= {8'b0,8'b01110111}; //0.46527859
	assign coeff_3 	= {8'b0,8'b00010111}; //0.09007576
	assign coeff_4 	= {8'b0,8'b00000000}; //0.0031444
	assign coeff_5 	= {8'b00000001,8'b00010101}; //1.08381219
	assign coeff_6 	= {8'b0,8'b01010000}; //0.31592922
	assign coeff_7 	= {8'b0,8'b00000000}; //-0.00349517
	assign coeff_8 	= {8'b00000001,8'b00010101}; //1.08538355
	assign coeff_9 	= {8'hFF,8'b10101111}; //-0.31676793
	assign coeff_10 = {8'b0,8'b01100110}; //0.39878032
	assign coeff_11 = {8'b0,8'b01110111}; //0.46509003
	assign coeff_12 = {8'hFF,8'b11101001}; //-0.09013554

	// pre_compute x^2
	mult #(.XLEN(`LSTM_INPUT_BITS), .NUM_STAGE(`NUM_LSTM_MULT_STAGE)) mult_square (
		.clock(clock),
		.reset(reset),
		.sign({2'b11}),
		.mcand(packet_in.data),
		.mplier(packet_in.data),
		.product(x_square),
		.done(xsquare_done)
		);

	// determine coefficient
	assign next_compare_flag[4] = $signed(packet_in.data)>$signed({8'b11111101,8'b0}); // x>-3
	assign next_compare_flag[3] = $signed(packet_in.data)>$signed({8'b11111111,8'b0}); // x>-1
	assign next_compare_flag[2] = $signed(packet_in.data)>$signed({16'b0}); // x>0
	assign next_compare_flag[1] = $signed(packet_in.data)>$signed({8'b00000001,8'b0}); // x>1
	assign next_compare_flag[0] = $signed(packet_in.data)>$signed({8'b00000011,8'b0}); // x>3

	always_comb begin
		next_coeff_x 			= 0;
		next_coeff_x_square 	= 0;
		next_coeff_const 		= 0;
		if (compare_flag[0]) begin // x>3
			next_coeff_const 	= {8'b00000001,8'b0};
		end 
		else if (compare_flag[1]) begin // 1<x<3
			next_coeff_x 		= coeff_11;
			next_coeff_x_square = coeff_12;
			next_coeff_const 	= coeff_10;
		end 
		else if (compare_flag[2]) begin // 0<x<1
			next_coeff_x 		= coeff_8;
			next_coeff_x_square = coeff_9;
			next_coeff_const 	= coeff_7;
		end 
		else if (compare_flag[3]) begin // -1<x<0
			next_coeff_x 		= coeff_5;
			next_coeff_x_square = coeff_6;
			next_coeff_const 	= coeff_4;
			end 
		else if (compare_flag[4]) begin // -3<x<-1
			next_coeff_x 		= coeff_2;
			next_coeff_x_square = coeff_3;
			next_coeff_const 	= coeff_1;
		else begin
			next_coeff_const 	= {8'b11111111,8'b0};
			end
	end

	// compute the other term
		mult #(.XLEN(`LSTM_INPUT_BITS), .NUM_STAGE(`NUM_LSTM_MULT_STAGE)) mult_square (
		.clock(clock),
		.reset(reset),
		.sign({2'b11}),
		.mcand(packet_in.data),
		.mplier(coeff_x),
		.product(x_result),
		.done(x_done)
		);

		mult #(.XLEN(`LSTM_INPUT_BITS), .NUM_STAGE(`NUM_LSTM_MULT_STAGE)) mult_square (
		.clock(clock),
		.reset(reset),
		.sign({2'b11}),
		.mcand(x_square[23:8]), // only take the internal part
		.mplier(coeff_x_square),
		.product(x_square_result),
		.done(xsquare_const_done)
		);

	// sum all the result
	next_result = coeff_const_delay_2 + x_result[23:8] + x_square_result[23:8];

	//synopsys sync_set_reset "reset"
	always_ff @(posedge clock) begin 
		if (reset) begin
			compare_flag 			<=	`SD 0;
			coeff_const 			<=	`SD 0;
			coeff_x 				<= 	`SD 0;
			coeff_x_square 			<=	`SD 0;
			coeff_const_delay_1 	<=	`SD 0;
			coeff_const_delay_2 	<=	`SD 0;
			packet_out.data 		<=	`SD 0;
		end
		else begin
			compare_flag 			<= 	`SD next_compare_flag;
			coeff_const 			<=	`SD next_coeff_const;
			coeff_x 				<= 	`SD next_coeff_x;
			coeff_x_square 			<=	`SD next_coeff_x_square;
			coeff_const_delay_1 	<=	`SD coeff_const;
			coeff_const_delay_2 	<=	`SD coeff_const_delay_1;
			packet_out.data 		<=	`SD next_result;
		end
	end

endmodule