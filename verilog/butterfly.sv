module butterfly_8(
	input 								clock,
	input 								reset,
	input 	COMPLEX_NUMBER 				in_1, in_2, weight_1, weight_2,
	output	COMPLEX_NUMBER 				out_1, out_2

	/*
	input 			[`WORD_BITS-1:0]	real_in_1,
	input 			[`WORD_BITS-1:0]	real_in_2,
	input			[`WORD_BITS-1:0]	real_out_weight_1,
	input			[`WORD_BITS-1:0]	real_out_weight_2,
	input 			[`WORD_BITS-1:0]	imag_in_1,
	input 			[`WORD_BITS-1:0]	imag_in_2,
	input			[`WORD_BITS-1:0]	imag_out_weight_1,
	input			[`WORD_BITS-1:0]	imag_out_weight_2,

	output 	logic 	[`WORD_BITS-1:0] 	real_out_1,
	output	logic	[`WORD_BITS-1:0] 	real_out_2,
	output 	logic 	[`WORD_BITS-1:0] 	imag_out_1,
	output	logic	[`WORD_BITS-1:0] 	imag_out_2
	*/
	);
	
	COMPLEX_NUMBER input_sum, next_out_1, next_out_2, next_input_sum;
	/*
	logic [`WORD_BITS-1:0] 		real_input_sum,	real_next_out_1, real_next_out_2;
	logic [`WORD_BITS-1:0]		imag_input_sum, imag_next_out_1, imag_next_out_2;
	logic [`WORD_BITS-1:0]		next_real_input_sum, next_imag_input_sum;
	*/
	logic [2*`WORD_BITS-1:0]	real_real_1, real_real_2, real_imag_1, real_imag_2, imag_real_1, imag_real_2, imag_imag_1, imag_imag_2;

	// this part may be optimized/modified depend on ISA
	logic 		start, done;
	logic [1:0]	sign;
	assign start	= 1'b1;
	assign sign 	= 2'b00; // assume unsigned

	// this part defined the intermidia node
	assign	next_input_sum.real_part 	= 	in_1.real_part + in_2.real_part;
	assign 	next_input_sum.imag_part	=	in_1.imag_part + in_2.imag_part;

	// this part is the pipelined multiplication for intermedia variable
	mult #(`WORD_BITS,`BUTTERFLY_MULT_STAGE) mt1 (
		.clock(clock),
		.reset(reset),
		.start(start),
		.sign(sign),
		.mcand(input_sum.real_part),
		.mplier(weight_1.real_part),
		.product(real_real_1),
		.done(done)
		);

	mult #(`WORD_BITS,`BUTTERFLY_MULT_STAGE) mt2 (
		.clock(clock),
		.reset(reset),
		.start(start),
		.sign(sign),
		.mcand(input_sum.real_part),
		.mplier(weight_2.real_part),
		.product(real_real_2),
		.done(done)
		);

	mult #(`WORD_BITS,`BUTTERFLY_MULT_STAGE) mt3 (
		.clock(clock),
		.reset(reset),
		.start(start),
		.sign(sign),
		.mcand(input_sum.real_part),
		.mplier(weight_1.imag_part),
		.product(real_imag_1),
		.done(done)
		);

	mult #(`WORD_BITS,`BUTTERFLY_MULT_STAGE) mt4 (
		.clock(clock),
		.reset(reset),
		.start(start),
		.sign(sign),
		.mcand(input_sum.real_part),
		.mplier(weight_2.imag_part),
		.product(real_imag_2),
		.done(done)
		);

	mult #(`WORD_BITS,`BUTTERFLY_MULT_STAGE) mt5 (
		.clock(clock),
		.reset(reset),
		.start(start),
		.sign(sign),
		.mcand(input_sum.imag_part),
		.mplier(weight_1.real_part),
		.product(imag_real_1),
		.done(done)
		);

	mult #(`WORD_BITS,`BUTTERFLY_MULT_STAGE) mt6 (
		.clock(clock),
		.reset(reset),
		.start(start),
		.sign(sign),
		.mcand(input_sum.imag_part),
		.mplier(weight_2.real_part),
		.product(imag_real_2),
		.done(done)
		);

	mult #(`WORD_BITS,`BUTTERFLY_MULT_STAGE) mt7 (
		.clock(clock),
		.reset(reset),
		.start(start),
		.sign(sign),
		.mcand(input_sum.imag_part),
		.mplier(weight_1.imag_part),
		.product(imag_imag_1),
		.done(done)
		);

	mult #(`WORD_BITS,`BUTTERFLY_MULT_STAGE) mt8 (
		.clock(clock),
		.reset(reset),
		.start(start),
		.sign(sign),
		.mcand(input_sum.imag_part),
		.mplier(weight_2.imag_part),
		.product(imag_imag_2),
		.done(done)
		);

	// this multiplication could be optimized using pipelined logic
	assign 	next_out_1.real_part 	= 	real_real_1[`WORD_BITS + `WORD_BITS>>1 -1:`WORD_BITS>>1]-imag_imag_1[`WORD_BITS + `WORD_BITS>>1 -1:`WORD_BITS>>1];
	assign 	next_out_1.imag_part	=	real_imag_1[`WORD_BITS + `WORD_BITS>>1 -1:`WORD_BITS>>1]+imag_real_1[`WORD_BITS + `WORD_BITS>>1 -1:`WORD_BITS>>1];
	assign	next_out_2.real_part	=	real_real_2[`WORD_BITS + `WORD_BITS>>1 -1:`WORD_BITS>>1]-imag_imag_2[`WORD_BITS + `WORD_BITS>>1 -1:`WORD_BITS>>1];
	assign	next_out_2.imag_part	=	real_imag_2[`WORD_BITS + `WORD_BITS>>1 -1:`WORD_BITS>>1]+imag_real_2[`WORD_BITS + `WORD_BITS>>1 -1:`WORD_BITS>>1];
	


	//synopsys sync_set_reset "reset"
	always_ff (posedge clock) begin
		if (reset) begin
			out_1.real_part 		<=	`SD 0;
			out_1.imag_part 		<=	`SD 0;
			out_2.real_part 		<=	`SD 0;
			out_2.imag_part 		<=	`SD 0;
			input_sum.real_part 	<=	`SD 0;
			input_sum.imag_part 	<=	`SD 0;
		end
		else begin
			out_1.real_part 		<=	`SD next_out_1.real_part;
			out_1.imag_part 		<=	`SD next_out_1.imag_part;
			out_2.real_part 		<=	`SD next_out_2.real_part;
			out_2.imag_part 		<=	`SD next_out_2.imag_part;
			input_sum.real_part 	<=	`SD next_input_sum.real_part;
			input_sum.imag_part 	<=	`SD next_input_sum.imag_part;
		end
	end
endmodule