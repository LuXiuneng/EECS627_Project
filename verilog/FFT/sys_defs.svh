`ifndef __SYS_DEFS_VH__
`define __SYS_DEFS_VH__

`define WORD_BITS 32
`define BUTTERFLY_MULT_STAGE 4
`define NUM_FFT_POINT 8
`define SD #1

typedef struct packed {
	logic [`WORD_BITS-1:0] real_part;
	logic [`WORD_BITS-1:0] imag_part;
} COMPLEX_NUMBER;

typedef struct packed {
	COMPLEX_NUMBER data;
} FFT_INPUT_PACKET;

typedef struct packed {
	COMPLEX_NUMBER data;
} FFT_OUTPUT_PACKET;

`endif // __SYS_DEFS_VH__