/********************************************************************************************
Filename    :	    router_fsm.v   

Description :      FSM sublock Design

Author Name :      Chaitra

Version     :      1.0

-> A 2-bit addr internal register is required to store 2-bit data_in
********************************************************************************************/

module router_fsm(
input  clock, resetn, pkt_valid,
input  parity_done, low_pkt_valid, fifo_full,
       soft_reset_0,
       soft_reset_1,
       soft_reset_2,
       fifo_empty_0,
       fifo_empty_1,
       fifo_empty_2,
input  [1:0] data_in,
output detect_add, ld_state, busy,
       laf_state, full_state,
       write_enb_reg, rst_int_reg,
       lfd_state
);

reg [1:0] addr;
reg [2:0] present_state, next_state;

//8 states, 3 bits required for binary state encoding
parameter DECODE_ADDRESS     = 3'b000;
parameter WAIT_TILL_EMPTY    = 3'b001;
parameter LOAD_FIRST_DATA    = 3'b010;
parameter LOAD_DATA          = 3'b011;
parameter LOAD_PARITY        = 3'b100;
parameter FIFO_FULL_STATE    = 3'b101;
parameter LOAD_AFTER_FULL    = 3'b110;
parameter CHECK_PARITY_ERROR = 3'b111;


always@(posedge clock)
   begin
      if(!resetn)
         addr <= 2'b0;
      else if (detect_add)	//decides the address of out channel
         addr <= data_in;
   end
         
//reset logic for states
//present state logic
always@(posedge clock)
   begin
      if(!resetn)
         present_state <= DECODE_ADDRESS;			//hard reset
         
      else if(((soft_reset_0) && (data_in == 2'b00)) || 
             ((soft_reset_1) && (data_in == 2'b01)) ||
             ((soft_reset_2) && (data_in == 2'b10)))		//if soft_reset and also using same channel
             
         present_state <= DECODE_ADDRESS;
         
      else
         present_state <= next_state;
   end
   
//next state logic
always@(*)
   begin
      next_state <= DECODE_ADDRESS;		//is this required?
      
      case(present_state)
      
         DECODE_ADDRESS:     begin
                                if((pkt_valid && data_in == 2'b00 && fifo_empty_0) ||      
                                  (pkt_valid && data_in == 2'b01 && fifo_empty_1) ||
                                  (pkt_valid && data_in == 2'b10 && fifo_empty_2))
                                
                                  next_state <= LOAD_FIRST_DATA;
                                
                                else if((pkt_valid && data_in == 2'b00 && (!fifo_empty_0)) ||      
                                       (pkt_valid && data_in == 2'b01 && (!fifo_empty_1)) ||
                                       (pkt_valid && data_in == 2'b10 && (!fifo_empty_2)))
                                     
                                       next_state <= WAIT_TILL_EMPTY;
                                 
                                else
                                   next_state <= DECODE_ADDRESS;
                             end
                           
         WAIT_TILL_EMPTY:    begin
                                if((fifo_empty_0 && (addr == 2'b00)) ||		//the chosen fifo is empty
                                  (fifo_empty_1 && (addr == 2'b01)) ||
                                  (fifo_empty_2 && (addr == 2'b10)))
                                
                                  next_state <= LOAD_FIRST_DATA;
                                
                              else
                                 next_state <= WAIT_TILL_EMPTY;
                             end
                                
         LOAD_FIRST_DATA:    begin
                                next_state <= LOAD_DATA;
                             end
                           
         LOAD_DATA:          begin
                                if(fifo_full)
                                   next_state <= FIFO_FULL_STATE;
                                 
                                else if((!fifo_full) && (!pkt_valid))
                                   next_state <= LOAD_PARITY;
                                 
                                else
                                   next_state <= LOAD_DATA;
                             end
         
         LOAD_PARITY:        begin
                                next_state <= CHECK_PARITY_ERROR;
                             end
         
         FIFO_FULL_STATE:    begin
                                if(!fifo_full)         
                                   next_state <= LOAD_AFTER_FULL;
                                 
                                else
                                   next_state <= FIFO_FULL_STATE;
                             end
                                 
         LOAD_AFTER_FULL:    begin
                                if((!parity_done) && low_pkt_valid)
                                   next_state <= LOAD_PARITY;
                                 
                                else if(parity_done)
                                   next_state <= DECODE_ADDRESS;
                                 
                                else if((!parity_done) && (!low_pkt_valid))
                                   next_state <= LOAD_DATA;
                                 
                                else
                                   next_state <= LOAD_AFTER_FULL;
                             end

         
         CHECK_PARITY_ERROR: begin
                                if(!fifo_full)
                                   next_state <= DECODE_ADDRESS;
                                   
                                else if(fifo_full)
                                   next_state <= FIFO_FULL_STATE;
                                else
                                   next_state <= CHECK_PARITY_ERROR;
                             end
                             
         default:   next_state <= DECODE_ADDRESS;
         
       endcase
    end
    
//output logic
assign busy = ((present_state == LOAD_FIRST_DATA) ||
               (present_state == LOAD_PARITY) ||
               (present_state == FIFO_FULL_STATE) ||
               (present_state == LOAD_AFTER_FULL) ||
               (present_state == WAIT_TILL_EMPTY) ||
               (present_state == CHECK_PARITY_ERROR)) ? 1'b1 : 1'b0;
               
assign detect_add = (present_state == DECODE_ADDRESS) ? 1'b1 : 1'b0;

assign lfd_state = (present_state == LOAD_FIRST_DATA) ? 1'b1 : 1'b0;
               
assign ld_state = (present_state == LOAD_DATA) ? 1'b1 : 1'b0;        
         
assign write_enb_reg = ((present_state == LOAD_DATA) ||
                        (present_state == LOAD_PARITY) || 
                        (present_state == LOAD_AFTER_FULL)) ? 1'b1 : 1'b0;
                        
assign full_state = (present_state == FIFO_FULL_STATE) ? 1'b1 : 1'b0;

assign laf_state = (present_state == LOAD_AFTER_FULL) ? 1'b1 : 1'b0;

assign rst_int_reg = (present_state == CHECK_PARITY_ERROR) ? 1'b1 : 1'b0;
         
endmodule
