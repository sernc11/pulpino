/******************************************************************************
 *                                                                            *
 *          ERC Multitherman Lab @ DEI - University of Bologna                *
 *                      Viale Pepoli 3/2 - 40136                              *
 *                     Bologna - phone 0512092759                             *
 *                                                                            *
 * Engineer:       Francesco Conti - f.conti@unibo.it                         *
 *                                                                            *
 * Project:        PULP FPGA emulator                                         *
 * File:           riscv_register_file.sv                                     *
 * Description:    Triple-port behavioral register file                       *
 *                                                                            *
 ******************************************************************************/

module riscv_register_file
#(
    parameter ADDR_WIDTH    = 5,
    parameter DATA_WIDTH    = 32
)
(
    // Clock and Reset
    input  logic         clk,
    input  logic         rst_n,

    input  logic                   test_en_i,

    //Read port R1
    input  logic [ADDR_WIDTH-1:0]  raddr_a_i,
    output logic [DATA_WIDTH-1:0]  rdata_a_o,

    //Read port R2
    input  logic [ADDR_WIDTH-1:0]  raddr_b_i,
    output logic [DATA_WIDTH-1:0]  rdata_b_o,

    //Read port R3
    input  logic [ADDR_WIDTH-1:0]  raddr_c_i,
    output logic [DATA_WIDTH-1:0]  rdata_c_o,

    // Write port W1
    input logic [ADDR_WIDTH-1:0]   waddr_a_i,
    input logic [DATA_WIDTH-1:0]   wdata_a_i,
    input logic                    we_a_i,

    // Write port W2
    input logic [ADDR_WIDTH-1:0]   waddr_b_i,
    input logic [DATA_WIDTH-1:0]   wdata_b_i,
    input logic                    we_b_i
);

  localparam    NUM_WORDS = 2**ADDR_WIDTH;

  logic [NUM_WORDS-1:0][DATA_WIDTH-1:0] rf_reg;
  logic [NUM_WORDS-1:0]                 we_a_dec;
  logic [NUM_WORDS-1:0]                 we_b_dec;

  always_comb
  begin : we_a_decoder
    for (int i = 0; i < NUM_WORDS; i++) begin
      if (waddr_a_i == i)
        we_a_dec[i] <= we_a_i;
      else
        we_a_dec[i] <= 1'b0;
    end
  end

  always_comb
  begin : we_b_decoder
    for (int i=0; i<NUM_WORDS; i++) begin
      if (waddr_b_i == i)
        we_b_dec[i] <= we_b_i;
      else
        we_b_dec[i] <= 1'b0;
    end
  end

  genvar i;
  generate

    // loop from 1 to NUM_WORDS-1 as R0 is nil
    for (i = 1; i < NUM_WORDS; i++)
    begin : rf_gen

      always_ff @(posedge clk or negedge rst_n)
      begin : register_write_behavioral
        if (rst_n==1'b0) begin
          rf_reg[i] <= 'b0;
        end
        else begin
          if(we_b_dec[i] == 1'b1)
            rf_reg[i] <= wdata_b_i;
          else if(we_a_dec[i] == 1'b1)
            rf_reg[i] <= wdata_a_i;
          else
            rf_reg[i] <= rf_reg[i];
        end
      end

    end

    // R0 is nil
    assign rf_reg[0] = '0;

  endgenerate

  always_comb
  begin : register_read_a_behavioral
    rdata_a_o <= rf_reg[raddr_a_i];
  end

  always_comb
  begin : register_read_b_behavioral
    rdata_b_o <= rf_reg[raddr_b_i];
  end

  always_comb
  begin : register_read_c_behavioral
    rdata_c_o <= rf_reg[raddr_c_i];
  end

endmodule
