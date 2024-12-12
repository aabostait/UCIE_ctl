module UCIE_ctl_RX_FSM(
  
  input wire        i_clk,
  input wire        i_rst,
  input wire [2:0]  i_state_request,
  input wire        i_overflow_detected,
  output reg        o_buffer_enable,
  output reg        o_overflow_detected
  );
  
  reg [2:0] r_current_state                  ;
  reg [2:0] r_next_state                     ;
  
  localparam IDEL     =3'b1,
             ACTIVE   =3'b10,
             OVERFLOW =3'b100                ;

always @(posedge i_clk or negedge i_rst)
begin
  if(!i_rst)begin
    r_current_state<=IDEL                    ;
  end else begin
    r_current_state<=r_next_state            ;
  end
end


always @(*)begin
  case(r_current_state)
    IDEL    : begin
               if(i_state_request)begin
                  r_next_state  = ACTIVE   ;
                end else begin
                  r_next_state  = IDEL     ;
               end
             end
    ACTIVE  : begin
               if(!i_state_request)begin
                  r_next_state  = IDEL     ;
                end else if(i_overflow_detected)begin
                  r_next_state  = OVERFLOW ;
               end
              end
            
    OVERFLOW : begin
                r_next_state  = IDEL  ;
              end
              
              
    default : begin
                r_next_state  = IDEL  ;
              end
   endcase
 end
      
                     
always @(*) begin
  case (r_current_state)
   IDEL       : begin 
               o_overflow_detected   = 1'b0  ;
               o_buffer_enable       = 1'b0  ; 
              end
    ACTIVE     : begin
               o_buffer_enable       = 1'b1  ;
               o_overflow_detected   = 1'b0  ;
              end
    OVERFLOW   : begin
                o_overflow_detected  = 1'b1  ;
              end
    default    : begin
               o_overflow_detected   = 1'b0  ;
               o_buffer_enable       = 1'b0  ;
             end
             

  endcase
end
endmodule