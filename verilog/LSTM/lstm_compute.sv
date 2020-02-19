
`timescale 1ns/100ps
module lstm_compute (
	input clock, reset,
	input CRAM_COMPUTE_PACKET  		cram_compute_packet_in,
	input CMVU_COMPUTE_PACKET [3:0] cmvu_compute_packet_in,

	output COMPUTE_OUTPUT_PACKET 	compute_packet_out,
	output COMPUTE_CRAM_PACKET 		compute_cram_packet_out
	);
	
	// define internal wire
	logic [`LSTM_INPUT_BITS-1:0]	i_t, c_wav_t, f_t, o_t, o_t_delayed;
	logic [2*`LSTM_INPUT_BITS-1:0]	upper_product, lower_product, final_product;
	logic [`LSTM_INPUT_BITS-1:0]	sum_product, next_sum_product, tanh_sum_product;
	logic 							upper_product_done, lower_product_done, computation_done;

// first compute the sigmoid/tanh function (5 cycles)
	sigmoid it_sigmoid (
		.clock(clock),
		.reset(reset),
		.packet_in(cmvu_compute_packet_in[0].data),
		.packet_out(i_t)
		);

	tanh c_wav_t_tanh (
		.clock(clock),
		.reset(reset),
		.packet_in(cmvu_compute_packet_in[1].data),
		.packet_out(c_wav_t)
		);

	sigmoid ft_sigmoid (
		.clock(clock),
		.reset(reset),
		.packet_in(cmvu_compute_packet_in[2].data),
		.packet_out(f_t)
		);

	sigmoid ot_sigmoid (
		.clock(clock),
		.reset(reset),
		.packet_in(cmvu_compute_packet_in[3].data),
		.packet_out(o_t)
		);

// then, compute the multiplication
	mult #(.XLEN(`LSTM_INPUT_BITS), .NUM_STAGE(`NUM_LSTM_MULT_STAGE)) top_mult(
		.clock(clock),
		.reset(reset),
		.sign({2'b11}),
		.mcand(i_t),
		.mplier(c_wav_t),
		.product(upper_product),
		.done(upper_product_done)
		);

	mult #(.XLEN(`LSTM_INPUT_BITS), .NUM_STAGE(`NUM_LSTM_MULT_STAGE)) bottem_mult(
		.clock(clock),
		.reset(reset),
		.sign({2'b11}),
		.mcand(f_t),
		.mplier(cram_compute_packet_in.data),
		.product(lower_product),
		.done(lower_product_done)
		);

	assign next_sum_product = upper_product[23:8] + lower_product[23:8];
	assign compute_cram_packet_out.data = sum_product;

//	next, compute tanh function for sum_product
	tanh final_tanh (
		.clock(clock), 
		.reset(reset),
		.packet_in(sum_product),
		.packet_out(tanh_sum_product)
		);

// Finally, compute multiplication for ot and tanh output
	delay_chain #(.INPUT_BITS_NUM(`LSTM_INPUT_BITS), .NUM_DELAY_CYCLE(8)) (
		.clock(clock),
		.reset(reset),
		.data_in(o_t),
		.data_out(o_t_delayed)
		);

	mult #(.XLEN(`LSTM_INPUT_BITS), .NUM_STAGE(`NUM_LSTM_MULT_STAGE)) final_mult(
		.clock(clock),
		.reset(reset),
		.sign({2'b11}),
		.mcand(tanh_sum_product),
		.mplier(o_t_delayed),
		.product(final_product),
		.done(computation_done)
		);

	assign compute_packet_out.data = final_product[23:8];

	//synopsys sync_set_reset "reset"
	always_ff @(posedge clock) begin
		if (reset) begin
			sum_product 	<= `SD 0;
		end
		else begin
			sum_product 	<=	`SD next_sum_product;
		end
	end
endmodule