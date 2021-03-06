`ifndef __LSTM_VH__
`define __LSTM_VH__

`define 	LSTM_INPUT_BITS 16
`define  	LSTM_OUTPUT_BITS 8
`define 	NUM_LSTM_MULT_STAGE 2
`define 	SD #1
typedef struct packed {
	logic [`LSTM_INPUT_BITS-1:0] data;
} TANH_INPUT_PACKET;

typedef struct packed {
	logic [`LSTM_OUTPUT_BITS-1:0] data;
} TANH_OUTPUT_PACKET;

typedef struct packed {
	logic [`LSTM_INPUT_BITS-1:0] data;
} SIGMOID_INPUT_PACKET;

typedef struct packed {
	logic [`LSTM_OUTPUT_BITS-1:0] data;
} SIGMOID_OUTPUT_PACKET;

typedef struct packed {
	logic [`LSTM_INPUT_BITS-1:0] data;
} CMVU_COMPUTE_PACKET;

typedef struct packed {
	logic [`LSTM_INPUT_BITS-1:0] data;
} COMPUTE_OUTPUT_PACKET;

typedef struct packed {
	logic [`LSTM_INPUT_BITS-1:0] data;
} COMPUTE_CRAM_PACKET;

typedef struct packed {
	logic [`LSTM_INPUT_BITS-1:0] data;
} CRAM_COMPUTE_PACKET;

`endif // __LSTM_VH__