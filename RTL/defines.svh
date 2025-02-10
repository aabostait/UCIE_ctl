//------------------------------------------------------------------------------
// File: defines.v
// Project: UCIE_ctl
// Description: 
// This file contains global macro definitions for key parameters used in the 
// UCIe adapter design. These macros ensure consistency across different 
// modules and simplify design updates. 

// Macro Gaurd
`ifndef DEFINES_V   // Start of macro guard
`define DEFINES_V   

`define NBYTES 8    // Number of bytes determined by the data width for the RDI & FDI instance.
`define NC 32       // NC is the width of the Sideband interface

`define  CSR_WIDTH 8   // Control status register data width
`define  CSR_DEPTH 256   // Control status register data depth

`define RX_DEPTH 4       // RX FIFO Depth
`define TX_DEPTH 8       // TX FIFO Depth 
`define TX_WIDTH 64
`define TX_POINTER 4      // TX Pointer
`define NUM_OF_STAGES 2   // Number of flip-flops (stages) used for synchronization in the bit synchronization process.

`endif 				// End of macro guard



//------------------------------------------------------------------------------