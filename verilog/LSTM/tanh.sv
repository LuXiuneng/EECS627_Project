/*
	tanh(x) = 	-1 										(x<-6)
				0.20323428+0.0717631x+0.00642858x2 		(-6<x<-3)
				0.50195831+0.27269294x+0.04059181x2		(-3<x<0)
				0.49805785+0.27266221x-0.04058115x2 	(0<x<3)
				0.7967568+0.07175359x-0.00642671x2		(3<x<6)
				1										(x>6)
*/
module tanh (
	input clock, reset,
	input TANH_INPUT_PACKET packet_in,

	output TANH_OUTPUT_PACKET packet_out
	);
	// define intermedia
	logic [2*`LSTM_INPUT_BITS-1:0]	x_square;

	// define the coefficient
	logic [15:0] coeff_1, coeff_2, coeff_3, coeff_4, coeff_5, coeff_6, coeff_7, coeff_8, coeff_9, coeff_10, coeff_11, coeff_12;
	assign coeff_1 	= {8'b0,8'b00110100}; //0.20323428
	assign coeff_2 	= {8'b0,8'b00010010}; //0.0717631
	assign coeff_3 	= {8'b0,8'b00000001}; //0.00642858
	assign coeff_4 	= {8'b0,8'b10000000}; //0.50195831
	assign coeff_5 	= {8'b0,8'b01000101}; //0.27269294
	assign coeff_6 	= {8'b0,8'b00001010}; //0.04059181
	assign coeff_7 	= {8'b0,8'b01111111}; //0.49805785
	assign coeff_8 	= {8'b0,8'b01000101}; //0.27266221
	assign coeff_9 	= {8'b0,8'b00001010}; //0.04058115
	assign coeff_10 = {8'b0,8'b11001011}; //0.7967568
	assign coeff_11 = {8'b0,8'b00010010}; //0.07175359
	assign coeff_12 = {8'b0,8'b00000001}; //0.00642671

	// pre_compute x^2
	mult #(.XLEN(`LSTM_INPUT_BITS), .NUM_STAGE(`NUM_LSTM_MULT_STAGE)) mult_square (
		.clock(clock),
		.reset(reset),
		.sign({2'b11}),
		.mcand(packet_in.data),
		.mplier(packet_in.data),
		.product(x_square),
		.done()
		);

endmodule