/********************************************************************************************
Filename    :	    router_register.v   

Description :      Register sublock Design

Author Name :      Chaitra

Version     :      1.0

-> 4 internal registers sre implemented to hold the 
   header byte, 		(header_byte)
   FIFO full state byte, 	(fifo_full_state)
   internal parity,		(internal_parity)
   packet parity byte		(pkt_parity)
********************************************************************************************/

module router_register(
input clock, resetn, pkt_valid, 	
      fifo_full, 			//coming from synchronizer
      rst_int_reg,			//coming from FSM 	used to reset low_pkt_valid signal
      detect_add,			//coming from FSM	used to reset parity_done signal
      ld_state,			//coming from FSM	LOAD_DATA
      laf_state,			//coming from FSM	LOAD_AFTER_FULL
      full_state,			//coming from FSM	to calculate internal parity
      lfd_state,			//coming from FSM	LOAD_FIRST_DATA
input [7:0] data_in,
output reg parity_done,			//to check if parity byte is loaded
           err,
           low_pkt_valid,			//as parity_byte cannot be sent randomly, whenever low_pkt_valid = 1 parity byte is sent
       
output reg [7:0] data_out		// if (!resetn): data_out, err, parity_done and low_pkt_valid are made 0
);

reg [7:0] header_byte, fifo_full_state, internal_parity, pkt_parity;

/************************************data output logic*************************************************************************
-> when lfd_state is high, 
   loads the header_byte and is sent to FIFO based on the last two bits of address [1:0]
-> parallely when write_enb_reg is high from FSM to Synchronizer, the selected FIFO is loaded with header_byte when lfd_state = 1
-> here, there is one clock pulse delay b/w what header address is received & which FIFO to send the data, as the data is first 
   stored in an internal register and the sent when lfd_state is high
-> From FSM w.k.t whenever lfd_state is high, busy signal is asserted. When looked at input protocol of Router, the header byte 
   is extended for one clock cycle and only when busy signal is desserted, payload data is sent
   
-> if ld_state is high, the payload data is directly sent to the selected FIFO if it is not full (!full_state), else full_x flag 
   of the selected FIFO is sent to the Synchronizer and Synchronizer asserts fifo_full to the Register
-> So when ld_state and fifo_full are high, Register has an internal register fifo_full_state that stores the data_in and sent 
   out at laf_state is high (data_in -> fifo_full_state -> data_out)
*******************************************************************************************************************************/
always@(posedge clock)
   begin
      if(!resetn)
         data_out <= 8'd0;
         
      else if(lfd_state)			
         data_out <= header_byte;					
 
      else if(ld_state && !fifo_full)
		   data_out <= data_in;
			
      else if(laf_state)
         data_out <= fifo_full_state;
			
     else
         data_out <= data_out;
   end

/************************************************Error logic***************************************************************/
/*The err is calculated only after packet parity is loaded
err = 1 if pkt_parity != internal_parity */

always@(posedge clock)
   begin
      if(!resetn)
         err <= 1'b0;
      
      else if((parity_done) && (pkt_parity != internal_parity))
         err <= 1'b1;
         
      else
         err <= err;
   end
   
/**************************************Parity done logic********************************************************************/
always@(posedge clock)
   begin
      if((!resetn) || (detect_add))		//detect_add resets parity_done
         parity_done <= 1'b0;
         
      else if(((ld_state) && (!fifo_full) && (!pkt_valid)) || ((laf_state) && (!parity_done) && (!rst_int_reg)))
         parity_done <= 1'b1;
         
      else
         parity_done <= parity_done;
   end
	
/**************************************Low packet valid logic********************************************************************/
//can these be given in an always block? whats the difference?*/
//shows that pkt_valid for current packet has been deasserted

always@(posedge clock)
   begin
      if((!resetn) || (rst_int_reg))
         low_pkt_valid <= 1'b0;
	   
      else if(ld_state && (!pkt_valid))
         low_pkt_valid <= 1'b1;
			
      else
         low_pkt_valid <= low_pkt_valid;
   end
	
/*************************************Header byte & Fifo full state*********************************************************/
/*The first data byte i.e., header is latched inside an internal register when detect_add = 1 and pkt_valid = 1.
This data is latched to the output d_out when lfd_state = 1*/

always@(posedge clock)
   begin
      if(!resetn)
         {header_byte, fifo_full_state} <= 16'd0;
      
      else 
         begin
            if((detect_add) && (pkt_valid) && (data_in[1:0] != 2'b11))
               header_byte <= data_in;
         
            else if(ld_state && fifo_full)
               fifo_full_state <= data_in;
					
            else
            begin
               header_byte <= header_byte;
               fifo_full_state <= fifo_full_state;
            end
         end
   end
   

/**********************************Parity calculation logic*****************************************************************/
always@(posedge clock)
   begin
      if(!resetn)
         internal_parity <= 8'd0;
         
      else if(detect_add)		//address is detected that means header byte is only sent, parity is not done, no parity
	 internal_parity <= 8'd0;
		
      else if(lfd_state)
         internal_parity <= header_byte;	//storing the header_bye to xor with payload0 with ld_state = 1
         
      else if((ld_state) && (pkt_valid) && (!full_state))
         internal_parity <= internal_parity ^ data_in;	//stored header_byte data in internal_parity is xor with data_in(payload byte)
			
      else if((!pkt_valid) && (rst_int_reg))			//if pkt_valid is low, the low_pkt_valid should be high, here the condition is: 
         internal_parity <= 8'd0;			//low_pkt_valid is made 0 by using rst_int_reg, meaning: either packet is not sent or packet sending is finished 
         
      else
         internal_parity <= internal_parity;
   end
   
/************************************Packet parity logic*******************************************************************/
always@(posedge clock)
   begin
      if(!resetn)
         pkt_parity <= 8'd0;
         
      else if(((ld_state) && (!pkt_valid) && (!fifo_full)) || ((laf_state) && (!rst_int_reg) && (!parity_done))) 
         pkt_parity <= data_in;
         
      else if(((!pkt_valid) && (rst_int_reg)) || (detect_add)) //pkt_valid and low_pkt_valid are both low, then either pkt parity is not sent or 
         pkt_parity <= 8'd0;
			
      else
         pkt_parity <= pkt_parity;
   end



endmodule

