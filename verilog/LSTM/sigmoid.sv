/*
	sigmoid(x) = 	0 										(x<-6)
					0.20323428+0.0717631x+0.00642858x2 		(-6<x<-3)
					0.50195831+0.27269294x+0.04059181x2		(-3<x<0)
					0.49805785+0.27266221x-0.04058115x2 	(0<x<3)
					0.7967568+0.07175359x-0.00642671x2		(3<x<6)
					1										(x>6)
*/

// currently, computing a sigmiod would take 5 cycles
`timescale 1ns/100ps
module sigmoid (
	input clock, reset,
	input SIGMOID_INPUT_PACKET packet_in,

	output SIGMOID_OUTPUT_PACKET packet_out
	);
	// define intermedia
	logic [2*`LSTM_INPUT_BITS-1:0]	x_square, x_result, x_square_result;
	logic xquare_done, x_done, xsquare_const_done;
	logic [4:0] next_compare_flag, compare_flag;
	logic [`LSTM_INPUT_BITS-1:0] next_result;

	// define the coefficient
	logic [15:0] coeff_1, coeff_2, coeff_3, coeff_4, coeff_5, coeff_6, coeff_7, coeff_8, coeff_9, coeff_10, coeff_11, coeff_12;
	logic [15:0] next_coeff_x, next_coeff_x_square, next_coeff_const, coeff_x, coeff_const, coeff_x_square, coeff_const_delay_1, coeff_const_delay_2;
	assign coeff_1 	= {8'b0,8'b00110100}; //0.20323428
	assign coeff_2 	= {8'b0,8'b00010010}; //0.0717631
	assign coeff_3 	= {8'b0,8'b00000001}; //0.00642858
	assign coeff_4 	= {8'b0,8'b10000000}; //0.50195831
	assign coeff_5 	= {8'b0,8'b01000101}; //0.27269294
	assign coeff_6 	= {8'b0,8'b00001010}; //0.04059181
	assign coeff_7 	= {8'b0,8'b01111111}; //0.49805785
	assign coeff_8 	= {8'b0,8'b01000101}; //0.27266221
	assign coeff_9 	= {8'hFF,8'b11110110}; //-0.04058115
	assign coeff_10 = {8'b0,8'b11001011}; //0.7967568
	assign coeff_11 = {8'b0,8'b00010010}; //0.07175359
	assign coeff_12 = 16'hFFFF; //-0.00642671

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
	assign next_compare_flag[4] = $signed(packet_in.data)>$signed({8'b11111010,8'b0});
	assign next_compare_flag[3] = $signed(packet_in.data)>$signed({8'b11111101,8'b0}); // x>-3
	assign next_compare_flag[2] = $signed(packet_in.data)>$signed({16'b0}); // x>0
	assign next_compare_flag[1] = $signed(packet_in.data)>$signed({8'b00000011,8'b0}); // x>3
	assign next_compare_flag[0] = $signed(packet_in.data)>$signed({8'b00000110,8'b0}); // x>6

	always_comb begin
		next_coeff_x 			= 0;
		next_coeff_x_square 	= 0;
		next_coeff_const 		= 0;
		if (compare_flag[0]) begin // x>6
			next_coeff_const 	= {8'b00000001,8'b0};
		end 
		else if (compare_flag[1]) begin // 3<x<6
			next_coeff_x 		= coeff_11;
			next_coeff_x_square = coeff_12;
			next_coeff_const 	= coeff_10;
		end 
		else if (compare_flag[2]) begin // 0<x<3
			next_coeff_x 		= coeff_8;
			next_coeff_x_square = coeff_9;
			next_coeff_const 	= coeff_7;
		end 
		else if (compare_flag[3]) begin // -3<x<0
			next_coeff_x 		= coeff_5;
			next_coeff_x_square = coeff_6;
			next_coeff_const 	= coeff_4;
			end 
		else if (compare_flag[4]) begin // -6<x<-3
			next_coeff_x 		= coeff_2;
			next_coeff_x_square = coeff_3;
			next_coeff_const 	= coeff_1;
		end
		else begin
			
			end
	end

	// compute the other term
		mult #(.XLEN(`LSTM_INPUT_BITS), .NUM_STAGE(`NUM_LSTM_MULT_STAGE)) mult_x_result (
		.clock(clock),
		.reset(reset),
		.sign({2'b11}),
		.mcand(packet_in.data),
		.mplier(coeff_x),
		.product(x_result),
		.done(x_done)
		);

		mult #(.XLEN(`LSTM_INPUT_BITS), .NUM_STAGE(`NUM_LSTM_MULT_STAGE)) mult_x_square_result (
		.clock(clock),
		.reset(reset),
		.sign({2'b11}),
		.mcand(x_square[23:8]), // only take the internal part
		.mplier(coeff_x_square),
		.product(x_square_result),
		.done(xsquare_const_done)
		);

	// sum all the result
	assign next_result = coeff_const_delay_2 + x_result[23:8] + x_square_result[23:8];

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