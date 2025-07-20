/********************************************************************************************
Filename    :	    router_fsm_tb.v   

Description :      FSM sublock Design

Author Name :      Chaitra

Version     :      1.0

DA  -> DECODE_ADDRESS     
WTE -> WAIT_TILL_EMPTY    
LFD -> LOAD_FIRST_DATA    
LD  -> LOAD_DATA         
LP  -> LOAD_PARITY        
FFS -> FIFO_FULL_STATE    
LAF -> LOAD_AFTER_FULL    
CPE -> CHECK_PARITY_ERROR

There are 4 tasks that are considered here:
TASK1: DA -> LFD -> LD -> LP -> CPE -> DA
TASK2: DA -> LFD -> LD -> FFS -> LAF -> LP -> CPE -> DA
TASK3: DA -> LFD -> LD -> FFS -> LAF -> LD -> LP -> CPE -> DA
TASK4: DA -> LFD -> LD -> LP -> CPE -> FFS -> LAF -> DA
********************************************************************************************/

module router_fsm_tb;

reg  clock, resetn, pkt_valid, parity_done, low_pkt_valid, fifo_full,
     soft_reset_0, soft_reset_1, soft_reset_2,
     fifo_empty_0, fifo_empty_1, fifo_empty_2;
reg  [1:0] data_in;
wire detect_add, ld_state, busy, laf_state, full_state,
     write_enb_reg, rst_int_reg, lfd_state;
       
parameter cycle = 10;
       
router_fsm DUT (.clock(clock), .resetn(resetn), .pkt_valid(pkt_valid), .parity_done(parity_done), .low_pkt_valid(low_pkt_valid), 
                .fifo_full(fifo_full), .soft_reset_0(soft_reset_0), .soft_reset_1(soft_reset_1), .soft_reset_2(soft_reset_2),
                .fifo_empty_0(fifo_empty_0), .fifo_empty_1(fifo_empty_1), .fifo_empty_2(fifo_empty_2), .data_in(data_in), 
					 .detect_add(detect_add), .ld_state(ld_state), .busy(busy), .laf_state(laf_state), .full_state(full_state),
                .write_enb_reg(write_enb_reg), .rst_int_reg(rst_int_reg), .lfd_state(lfd_state));
              
parameter DECODE_ADDRESS     = 3'b000;
parameter WAIT_TILL_EMPTY    = 3'b001;
parameter LOAD_FIRST_DATA    = 3'b010;
parameter LOAD_DATA          = 3'b011;
parameter LOAD_PARITY        = 3'b100;
parameter FIFO_FULL_STATE    = 3'b101;
parameter LOAD_AFTER_FULL    = 3'b110;
parameter CHECK_PARITY_ERROR = 3'b111;

reg [3*8 : 0] string;		//each character in the string takes up 8-bits (1-byte)

always@(DUT.present_state)
   begin
	   case(DUT.present_state)
		   DECODE_ADDRESS     : string = "DA";
			WAIT_TILL_EMPTY    : string = "WTE";
			LOAD_FIRST_DATA    : string = "LFD";
			LOAD_DATA          : string = "LD";
			LOAD_PARITY        : string = "LP";
			FIFO_FULL_STATE    : string = "FFS";
			LOAD_AFTER_FULL    : string = "LAF";
			CHECK_PARITY_ERROR : string = "CPE";
		endcase
	end

always
   begin
      #(cycle/2) clock = 1'b0;
      #(cycle/2) clock = 1'b1;
   end

task initialize;
   begin
      {pkt_valid, fifo_empty_0, fifo_empty_1, fifo_empty_2, fifo_full, parity_done, low_pkt_valid,
		data_in, soft_reset_0, soft_reset_1, soft_reset_2} = 12'd0;
   end
endtask

task resetf();
   begin
      @(negedge clock);
      resetn = 1'b0;
      @(negedge clock);
      resetn = 1'b1;
   end
endtask

task t1;
   begin
      @(negedge clock)  	//DA -> LFD
         begin
            pkt_valid = 1'b1;
            data_in = 2'b01;		//00,01,10
            fifo_empty_1 = 1'b1;
         end              
      @(negedge clock) 	//LFD -> LD
      @(negedge clock) 	//LD -> LP
         begin
            fifo_full = 1'b0;
            pkt_valid = 1'b0;
         end
      @(negedge clock) 	// LP -> CPE
      @(negedge clock) 	// CPE -> DA
      fifo_full = 1'b0; 	
   end
   endtask
   
task t2;
   begin
      @(negedge clock) 				//DA -> LFD
         begin
            pkt_valid = 1'b1;
            data_in = 2'b01;		//00,01,10
            fifo_empty_1 = 1'b1;
         end              
      @(negedge clock) 	//LFD -> LD
      @(negedge clock)		//LP -> FFS
         fifo_full = 1'b1;
      @(negedge clock)		//FFS -> LAF
         fifo_full = 1'b0;
      @(negedge clock) 	//LAF -> LP
         begin
            parity_done = 1'b0;
            low_pkt_valid = 1'b1;
         end
      @(negedge clock) 	// LP -> CPE
      @(negedge clock) 	//CPE -> DA
         fifo_full = 1'b0;
   end
endtask

task t3;
   begin
      @(negedge clock) 	//DA -> LFD
         begin
            pkt_valid = 1'b1;
            data_in = 2'b01;		//00,01,10
            fifo_empty_1 = 1'b1;
         end              
      @(negedge clock) 	//LFD -> LD
      @(negedge clock)		//LD -> FFS
         fifo_full = 1'b1;
      @(negedge clock)		//FFS -> LAF
         fifo_full = 1'b0;
      @(negedge clock) 	//LAF -> LD
         begin
            parity_done = 1'b0;
            low_pkt_valid = 1'b0;
         end
      @(negedge clock) 	//LD -> LP
         begin
            fifo_full = 1'b0;
            pkt_valid = 1'b0;
         end
      @(negedge clock) 	// LP -> CPE
      @(negedge clock) 	// CPE -> DA
      fifo_full = 1'b0; 	
   end
endtask
   
task t4;
   begin
      @(negedge clock)  	//DA -> LFD
         begin
            pkt_valid = 1'b1;
            data_in = 2'b01;		//00,01,10
            fifo_empty_1 = 1'b1;
         end              
      @(negedge clock) 	//LFD -> LD
      @(negedge clock) 	//LD -> LP
         begin
            fifo_full = 1'b0;
            pkt_valid = 1'b0;
         end
      @(negedge clock) 	// LP -> CPE
      @(negedge clock) 	// CPE -> FFS
         fifo_full = 1'b1;
      @(negedge clock)		//FFS -> LAF
         fifo_full = 1'b0;
      @(negedge clock)		//LAF -> DA
         parity_done = 1'b1;
   end
endtask
   
initial
   begin
      initialize;
      resetf;
      
      t1;
      resetf;
      #20;
   
      t2;
      resetf;
      #20;
      
      t3;
      resetf;
      #20;
      
      t4;
      resetf;
		#20;
		$finish;
   end

   
endmodule  
   
   
