// ************************* Description ************************** //
//  This module is implemented to:-                                 //
//  -- obtain packet sending for the msg phases                     //
//  -- supporting NC parameter                                      //
// **************************************************************** //

module UCIE_ctl_sb_tx_packet_sender #(
    parameter NC = 8
)(
    input                    i_clk,
    input                    i_rst,
    input       [1:0]        i_shift_load,
    input       [31:0]       i_phase_sent,
    output reg  [NC-1 : 0]   o_rdi_lp_cfg,
    output reg               o_done_shift 
);
    localparam COUNT = 32 / NC - 1;
    reg [31:0] r_oper_register;
    reg [$clog2(COUNT + 1) - 1 : 0] counter;

    always @(posedge i_clk or negedge i_rst) begin
        if (!i_rst) begin
            r_oper_register <= 0;
            counter         <= 0;
        end else begin
            // MSB = shift, LSB = load
            case (i_shift_load)
                2'b00: begin
                    r_oper_register <= r_oper_register;
                end
                2'b01: begin
                    r_oper_register <= i_phase_sent;
                    counter         <= 0;
                end
                2'b10: begin
                  if(counter == COUNT) begin
                    r_oper_register <= r_oper_register;
                    counter         <= counter;
                  end else begin
                    r_oper_register <= r_oper_register >> NC;
                    counter         <= counter + 1'd1;
                  end
                end
                2'b11: begin
                    r_oper_register <= i_phase_sent >> NC;
                end
            endcase
        end
    end

    always @(*) begin
      o_rdi_lp_cfg = r_oper_register[NC-1 : 0];
		  if (i_shift_load == 2'b10) begin
        case (NC)
          // handling edged 32 bit NC case
          'd32 : begin
            o_done_shift    = 1'b1;
          end
          // otherwise for the 8 and 16 bit NC
          default : begin
            if (counter == COUNT - 1) begin
		          o_done_shift = 1'b1;
		        end else begin
		          o_done_shift = 1'b0;
		        end
          end  
        endcase  
		    end else begin
		      o_done_shift    = 1'b0;
		  end
    end

endmodule
