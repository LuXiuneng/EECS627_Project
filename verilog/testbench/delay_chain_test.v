`timescale 1ns/100ps
module testbench;
	logic clock, reset;
	logic [15:0]	data_in, data_out;

	delay_chain #(.INPUT_BITS_NUM(16), .NUM_DELAY_CYCLE(4)) DUT (
		.clock(clock),
		.reset(reset),
		.data_in(data_in),
		.data_out(data_out)
		);

	task exit_on_error;
		begin
			#1;
			$display("data_in:%b, data_out:%b",data_in,data_out);
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

	initial begin
		clock           = 0;
        reset           = 1;
        data_in 		= 0;
        #6
        reset 			= 0;
        for (int i = 0; i < 100; i++) begin
        	@(negedge clock) 
        	data_in = {$random};
        	@(negedge clock)
        	@(negedge clock)
        	@(negedge clock)
        	@(negedge clock)
        	assert((data_out==data_in)) else #1 exit_on_error;
        end

		$display("@@@ passed");
       	$finish;
	end

	always
        #5 clock=~clock;
endmodule