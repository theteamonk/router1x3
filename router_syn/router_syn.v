/********************************************************************************************
Filename    :	    router_syn.v   

Description :      Synchronizer sublock Design

Author Name :      Chaitra

Version     :      1.0

-> A 2-bit temporary internal register is required to store 2-bit data_in
-> to generate a soft reset - to count 30 clock cycles a 5-bit internal counter is required
********************************************************************************************/

module router_syn(

input detect_add,
input [1:0] data_in,
input write_enb_reg,
input clock, resetn,
output vld_out_0,
       vld_out_1,
       vld_out_2,
input  read_enb_0,
       read_enb_1,
       read_enb_2,
output reg [2:0] write_enb,
output reg fifo_full,
input empty_0,
      empty_1,
      empty_2,
output reg soft_reset_0,
           soft_reset_1,
           soft_reset_2,
input full_0,
      full_1,
      full_2
);
      
reg [1:0] temp;
reg [4:0] count_0,
          count_1,
          count_2;      
       
/**********generating valid out signal if FIFO is empty and it can accept data**************/
//can full_x signal be considered here?
//no, because the logic of how empty and full works are different, check the code in FIFO block
assign vld_out_0 = ~empty_0;	
assign vld_out_1 = ~empty_1;
assign vld_out_2 = ~empty_2;

/***************fetching the address and storing into a temporary variable******************/
always@(posedge clock)
   begin
      if(!resetn)
         temp <= 0;
         
      else if (detect_add)
         temp <= data_in;
   end
   
/*************logic for fifo_full signal based on which of the FIFO is full****************/
always@(*)
   begin
      case(temp)
         2'b00 : fifo_full = full_0;	//FIFO fifo_full takes the value of full of fifo_0
         2'b01 : fifo_full = full_1;
         2'b10 : fifo_full = full_2;
         default fifo_full = 0;
      endcase
   end

/*if write_enb_reg is high, then generate appropriate write enable signal (one hot encoding) for that FIFO*/
always@(*)
   begin
      if(write_enb_reg)
         begin
            case(temp)
               2'b00 : write_enb = 3'b001;
               2'b01 : write_enb = 3'b010;
               2'b10 : write_enb = 3'b100;
               default write_enb = 3'b000;
            endcase
         end
         
         else
            write_enb = 3'b000;
   end


/*************once read enable is asserted, reset the counter to 0****************/
/*for FIFO 0*/
always@(posedge clock)
   begin
      if(!resetn)
         count_0 <= 0;
      
      else if(vld_out_0)
         begin
         
            if(!read_enb_0)
               begin
                  if(count_0 == 29)			//within 30 clock cycles of vld_out_0
                     begin
                        soft_reset_0 <= 1'b1;
                        count_0 <= 5'b0;
                     end
                     
                  else
                     begin
                        count_0 <= count_0 + 5'b1;
                        soft_reset_0 <= 1'b0;
                     end
                     
               end
                  else
                     count_0 <= 5'b0;			//if vld_out_0 = 1 and read_enb_0 = 1, there is no counting
         end
            else
               count_0 <= 5'b0;			//if vld_out_0 = 0, there is no counting
   end
                     
/*for FIFO 1*/                                      
always@(posedge clock)
   begin
      if(!resetn)
         count_1 <= 0;
      
      else if(vld_out_1)
         begin
         
            if(!read_enb_1)
               begin
                  if(count_1 == 29)			//within 30 clock cycles of vld_out_1
                     begin
                        soft_reset_1 <= 1'b1;
                        count_1 <= 5'b0;
                     end
                     
                  else
                     begin
                        count_1 <= count_1 + 5'b1;
                        soft_reset_1 <= 1'b0;
                     end
                     
               end
                  else
                     count_1 <= 5'b0;			//if vld_out_1 = 1 and read_enb_1 = 1, there is no counting
         end
            else
               count_1 <= 5'b0;			//if vld_out_1 = 0, there is no counting
   end                    

/*for FIFO 2*/                                      
always@(posedge clock)
   begin
      if(!resetn)
         count_2 <= 0;
      
      else if(vld_out_2)
         begin
         
            if(!read_enb_2)
               begin
                  if(count_2 == 29)			//within 30 clock cycles of vld_out_2
                     begin
                        soft_reset_2 <= 1'b1;
                        count_2 <= 5'b0;
                     end
                     
                  else
                     begin
                        count_2 <= count_2 + 5'b1;
                        soft_reset_2 <= 1'b0;
                     end
                     
               end
                  else
                     count_2 <= 5'b0;			//if vld_out_2 = 1 and read_enb_2 = 1, there is no counting
         end
            else
               count_2 <= 5'b0;			//if vld_out_2 = 0, there is no counting
   end  
       
endmodule
       
         
