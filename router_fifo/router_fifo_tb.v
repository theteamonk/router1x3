/********************************************************************************************
Filename    :	    router_fifo_tb.v   

Description :      FIFO 16x9 sublock TestBench

Author Name :      Chaitra

Version     :      1.0
********************************************************************************************/

module router_fifo_tb();
reg lfd_state;
reg [7:0] data_in;
reg clock, resetn, read_enb, write_enb, soft_reset;
wire[7:0] data_out;
wire full, empty;

integer i;

parameter cycle = 10;

router_fifo DUT (clock, resetn, data_in, read_enb, write_enb, 
			data_out, full, empty, lfd_state, soft_reset);
			
/*clock*/
always
   begin
      #(cycle/2) clock = 1'b0;
      #(cycle/2) clock = 1'b1;
   end
   
/*soft reset*/
task soft_rst();
   begin
      @(negedge clock);
      soft_reset = 1'b1;
      @(negedge clock);
      soft_reset = 1'b0;
   end
endtask

/*initialization*/
task initialize();
   begin
      read_enb = 0;
      write_enb = 0;
   end
endtask

/*reset*/
task resetf();
   begin
      @(negedge clock);
      resetn = 1'b0;
      @(negedge clock);
      resetn = 1'b1;
   end
endtask   

/*read enable*/
task read_enable();
   begin
      @(negedge clock)
      read_enb = 1;
      write_enb = 0;
   end
endtask

/*packet generation*/
task pkt_gen();

reg [7:0] payload_data, parity, header;
reg [5:0] payload_length;
reg [1:0] addr;

   begin
      /*header*/
      @(negedge clock)
      payload_length = 6'd14;
      addr = 2'b01;
      header = {payload_length, addr};
      data_in = header;
      lfd_state = 1'b1;
      
      
      @(negedge clock)
      lfd_state = 1'b0;			//as other than for Header, lfd_state is 0
      write_enb = 1;
      
      /*payload*/
      for(i = 0; i < payload_length; i = i+1)	//iterates for all the locations
        begin
           @(negedge clock);
           lfd_state = 0;
           payload_data = {$random}%256;	//2^8  = 256 | range for random number 0 to 255
           data_in = payload_data;
        end
        
      /*parity*/
      @(negedge clock)
      parity = {$random}%256;			//random number from 0 to 255
      data_in = parity;
   end
endtask

initial
   begin
      initialize();
      resetf();
      soft_rst();
      pkt_gen();
      read_enable();
      
      #200 $finish;
   end
      
initial
   $monitor("soft_reset = %b, lfd_state = %b, full = %b,  empty = %b, data_in = %b, data_out +%b, resetn = %b, read_enb = %b, write_enb = %b, read_ptr = %b, write_ptr = %b, count = %b", soft_reset, lfd_state, full, empty, data_in, data_out, resetn, read_enb, write_enb, DUT.rd_ptr, DUT.wr_ptr, DUT.count);
   
endmodule
