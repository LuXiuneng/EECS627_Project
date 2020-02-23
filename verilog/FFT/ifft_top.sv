module ifft_top(
	input clock, reset,
	input FFT_INPUT_PACKET [`NUM_FFT_POINT-1:0] 	data_input,

	output FFT_OUTPUT_PACKET [`NUM_FFT_POINT-1:0]	data_output
	);

	COMPLEX_NUMBER W_8_0, W_8_1, W_8_2, W_8_3;
	COMPLEX_NUMBER [`NUM_FFT_POINT-1:0] stage1_out, stage2_out;

	// define the W constant
	assign W_8_0.real_part = {16'h0001,16'h0};
	assign W_8_0.imag_part = 0;
	assign W_8_1.real_part = {16'b0,16'b1011_0101_0000_0100};
	assign W_8_1.imag_part = {16'b0,16'b1011_0101_0000_0100};
	assign W_8_2.real_part = 0;
	assign W_8_2.imag_part = 32'hFFFF0000;
	assign W_8_3.real_part = {16'hFFFF,16'b0100_1010_1111_1100};
	assign W_8_3.imag_part = {16'b0,16'b1011_0101_0000_0100};

	// stage 1
	butterfly_8 stage1_1 (
		.clock(clock),
		.reset(reset),
		.in_1(data_input[0]),
		.in_2(data_input[4]),
		.weight_1(W_8_0),
		.weight_2(W_8_0),
		.out_1(stage1_out[0]),
		.out_2(stage1_out[4])
		);

	butterfly_8 stage1_2 (
		.clock(clock),
		.reset(reset),
		.in_1(data_input[1]),
		.in_2(data_input[5]),
		.weight_1(W_8_0),
		.weight_2(W_8_1),
		.out_1(stage1_out[1]),
		.out_2(stage1_out[5])
		);

	butterfly_8 stage1_3 (
		.clock(clock),
		.reset(reset),
		.in_1(data_input[2]),
		.in_2(data_input[6]),
		.weight_1(W_8_0),
		.weight_2(W_8_2),
		.out_1(stage1_out[2]),
		.out_2(stage1_out[6])
		);

	butterfly_8 stage1_4 (
		.clock(clock),
		.reset(reset),
		.in_1(data_input[3]),
		.in_2(data_input[7]),
		.weight_1(W_8_0),
		.weight_2(W_8_3),
		.out_1(stage1_out[3]),
		.out_2(stage1_out[7])
		);

	// stage 2
	butterfly_8 stage2_1 (
		.clock(clock),
		.reset(reset),
		.in_1(stage1_out[0]),
		.in_2(stage1_out[2]),
		.weight_1(W_8_0),
		.weight_2(W_8_0),
		.out_1(stage2_out[0]),
		.out_2(stage2_out[2])
		);

	butterfly_8 stage2_2 (
		.clock(clock),
		.reset(reset),
		.in_1(stage1_out[1]),
		.in_2(stage1_out[3]),
		.weight_1(W_8_0),
		.weight_2(W_8_2),
		.out_1(stage2_out[1]),
		.out_2(stage2_out[3])
		);

	butterfly_8 stage2_3 (
		.clock(clock),
		.reset(reset),
		.in_1(stage1_out[4]),
		.in_2(stage1_out[6]),
		.weight_1(W_8_0),
		.weight_2(W_8_0),
		.out_1(stage2_out[4]),
		.out_2(stage2_out[6])
		);

	butterfly_8 stage2_4 (
		.clock(clock),
		.reset(reset),
		.in_1(stage1_out[5]),
		.in_2(stage1_out[7]),
		.weight_1(W_8_0),
		.weight_2(W_8_2),
		.out_1(stage2_out[5]),
		.out_2(stage2_out[7])
		);
	
	// stage 3
	butterfly_8 stage3_1 (
		.clock(clock),
		.reset(reset),
		.in_1(stage2_out[0]),
		.in_2(stage2_out[1]),
		.weight_1(W_8_0),
		.weight_2(W_8_0),
		.out_1(data_output[0]),
		.out_2(data_output[4])
		);

	butterfly_8 stage3_2 (
		.clock(clock),
		.reset(reset),
		.in_1(stage2_out[2]),
		.in_2(stage2_out[3]),
		.weight_1(W_8_0),
		.weight_2(W_8_0),
		.out_1(data_output[2]),
		.out_2(data_output[6])
		);

	butterfly_8 stage3_3 (
		.clock(clock),
		.reset(reset),
		.in_1(stage2_out[4]),
		.in_2(stage2_out[5]),
		.weight_1(W_8_0),
		.weight_2(W_8_0),
		.out_1(data_output[1]),
		.out_2(data_output[5])
		);

	butterfly_8 stage3_4 (
		.clock(clock),
		.reset(reset),
		.in_1(stage2_out[6]),
		.in_2(stage2_out[7]),
		.weight_1(W_8_0),
		.weight_2(W_8_0),
		.out_1(data_output[3]),
		.out_2(data_output[7])
		);
	
	// shfift the result
	always_comb begin
		for (int i = 0; i < 8; i++) begin
			data_output[i] = data_output[i]>>>3;
		end
	end
endmodule