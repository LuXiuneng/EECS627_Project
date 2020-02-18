`ifndef __LSTM_VH__
`define __LSTM_VH__

`define 	LSTM_INPUT_BITS 16
`define 	NUM_LSTM_MULT_STAGE 2
typedef struct packed {
	logic [`LSTM_INPUT_BITS-1:0] data;
} TANH_INPUT_PACKET;

typedef struct packed {
	logic [`LSTM_INPUT_BITS-1:0] data;
} TANH_OUTPUT_PACKET;

typedef struct packed {
	logic [`LSTM_INPUT_BITS-1:0] data;
} SIGMOID_INPUT_PACKET;

typedef struct packed {
	logic [`LSTM_INPUT_BITS-1:0] data;
} SIGMOID_OUTPUT_PACKET;

`endif // __LSTM_VH__