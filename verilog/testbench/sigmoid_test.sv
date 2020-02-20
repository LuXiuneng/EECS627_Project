`timescale 1ns/100ps
module testbench;
	logic clock,reset;
	SIGMOID_INPUT_PACKET packet_in;
	SIGMOID_OUTPUT_PACKET packet_out;

	real real_input;
	real real_output;
	real verilog_result;
	real actual_result;
	real error_percentage;

	sigmoid DUT (
		.clock(clock),
		.reset(reset),
		.packet_in(packet_in),
		.packet_out(packet_out)
		);

	function real be_realistic;
		input [15:0] a;
		logic [15:0] neg_a;
		be_realistic = 0;
		if (!a[15]) begin
			for (int i = 0; i < 14; i++) begin
				be_realistic += a[i]*2^(i-8);
			end
		end else begin
			neg_a = -a;
			for (int i = 0; i < 14; i++) begin
				be_realistic += neg_a[i]*2^(i-8);
			end
			be_realistic = -be_realistic;
		end
	endfunction

	function real get_real_sigmoid;
		input real b;
		if (b<-6) begin
			get_real_sigmoid = 0;
		end else if (b<-3 && b>= -6) begin
			get_real_sigmoid = 0.20323428+0.0717631*b+0.00642858*b*b;
		end else if (b>= -3 && b<0) begin
			get_real_sigmoid = 0.50195831+0.27269294*b+0.04059181*b*b;
		end else if (b>= 0 && b<3) begin
			get_real_sigmoid = 0.49805785+0.27266221*b-0.04058115*b*b;
		end else if (b>=3 && b<6) begin
			get_real_sigmoid = 0.7967568+0.07175359*b-0.00642671*b*b;
		end else begin
			get_real_sigmoid = 1;
		end
	endfunction 
	
	function real get_percentage_error;
		input real a,b;
		get_percentage_error = (a-b)/a*100;
		if (get_percentage_error<0) begin
			get_percentage_error = get_percentage_error*(-1);
		end
	endfunction

	task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

	initial begin
		clock           = 0;
        reset           = 1;
        packet_in 		= 0;
        #6
        reset 			= 0;
        for (int i = 0; i < 5; i++) begin
        	@(negedge clock) 
        	packet_in.data = {$random};
        	real_input = be_realistic(packet_in.data);
        	actual_result = get_real_sigmoid(real_input);
        	@(negedge clock) 
        	@(negedge clock) 
        	@(negedge clock) 
        	@(negedge clock) 
        	@(negedge clock) 
        	real_output = be_realistic(packet_out.data);
        	verilog_result = get_real_sigmoid(real_output);
        	error_percentage = get_percentage_error(actual_result, verilog_result);
        	$display("packet_in:%h, packet_out:%h\nverilog_output:%f, real_output:%f, error_percentage:%f",packet_in.data, packet_out.data,verilog_result, actual_result, error_percentage);
        end
        $display("@@@ passed");
       	$finish;
	end

	always
        #5 clock=~clock;
endmodule