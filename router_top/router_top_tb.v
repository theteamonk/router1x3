/********************************************************************************************
Filename    :	    router_top_tb.v   

Description :      Register sublock Test Bench

Author Name :      Chaitra

Version     :      1.0
********************************************************************************************/

module router_top_tb;

reg    clock, resetn, 
       read_enb_0,
       read_enb_1,
       read_enb_2,
       pkt_valid;
reg    [7:0] data_in;
wire   err, busy,
       vld_out_0,
       vld_out_1,
       vld_out_2;
wire   [7:0] data_out_0,
             data_out_1,
             data_out_2;
             
integer i;

parameter cycle = 10;

router_top DUT (.clock(clock), 
					 .resetn(resetn), 
					 .read_enb_0(read_enb_0), 
					 .read_enb_1(read_enb_1), 
					 .read_enb_2(read_enb_2), 
					 .pkt_valid(pkt_valid), 
					 .data_in(data_in), 
					 .err(err), 
					 .vld_out_0(vld_out_0), 
					 .vld_out_1(vld_out_1), 
					 .vld_out_2(vld_out_2),
					 .data_out_0(data_out_0), 
					 .data_out_1(data_out_1), 
					 .data_out_2(data_out_2), 
					 .busy(busy));
		 
always
   begin
      #(cycle/2) clock = 1'b0;
      #(cycle/2) clock = 1'b1;
   end
   
task resetf();
   begin
      @(negedge clock);
      resetn = 1'b0;
      @(negedge clock);
      resetn = 1'b1;
   end
endtask

task initialize;
   begin
      {pkt_valid, read_enb_0, read_enb_1, read_enb_2, data_in} = 12'd0;
   end
endtask

task pkt_gen_14;
reg [7:0] header, payload_data, parity;
reg [5:0] payloadlen;
reg [1:0] addr;
   begin
	   @(negedge clock);	//sending header byte with the information of destination address and payload length
	   payloadlen = 14;
		addr = 2'b01;
        wait(!busy)
		parity = 8'd0;
		header = {payloadlen, addr};
		
      @(negedge clock)   
			data_in = header;
		pkt_valid = 1'b1;		
         parity = parity ^ data_in;
            
      @(negedge clock)
         wait (!busy)	//waiting if busy is deasserted as the header byte that is 
								//already latched doesn't update to a new value for the current packet
            for(i = 0; i < payloadlen; i = i+1)
               begin
                  @(negedge clock)
                     wait (!busy)
                  payload_data = {$random}%256;
                  data_in = payload_data;
                  parity = parity ^ data_in;
               end
                 
      @(negedge clock)
         wait (!busy)
      pkt_valid = 1'b0;
      data_in = parity;
   end
endtask

task pkt_gen_10;
reg [7:0] header, payload_data, parity;
reg [5:0] payloadlen;
reg [1:0] addr;
   begin
	   @(negedge clock);
	   payloadlen = 10;
		addr = 2'b00;
         wait(!busy)
		parity = 8'd0;
		header = {payloadlen, addr};
      @(negedge clock)   
			data_in = header;
		pkt_valid = 1'b1;		
         parity = parity ^ data_in;
            
      @(negedge clock)
         wait (!busy)
            for(i = 0; i < payloadlen; i = i+1)
               begin
                  @(negedge clock)
                     wait (!busy)
                  payload_data = {$random}%256;
                  data_in = payload_data;
                  parity = parity ^ data_in;
               end
                 
      @(negedge clock)
         wait (!busy)
      pkt_valid = 1'b0;
      data_in = parity;
   end
endtask

task pkt_gen_16;
reg [7:0] header, payload_data, parity;
reg [5:0] payloadlen;
reg [1:0] addr;
   begin
	   @(negedge clock);
	   payloadlen = 16;
		addr = 2'b10;
         wait(!busy)
		parity = 8'd0;
		header = {payloadlen, addr};
      @(negedge clock)   
			data_in = header;
		pkt_valid = 1'b1;		
         parity = parity ^ data_in;
            
      @(negedge clock)
         wait (!busy)
            for(i = 0; i < payloadlen; i = i+1)
               begin
                  @(negedge clock)
                     wait (!busy)
                  payload_data = {$random}%256;
                  data_in = payload_data;
                  parity = parity ^ data_in;
               end
                 
      @(negedge clock)
         wait (!busy)
      pkt_valid = 1'b0;
      data_in = parity;
   end
endtask

initial
   begin
      initialize;
      resetf;
      
      pkt_gen_14;
         wait (!busy)
      read_enb_1 = 1'b1;
         wait (!vld_out_1)
      read_enb_1 = 1'b0;
      
      pkt_gen_10;
      @(negedge clock);
         wait (!busy)
      read_enb_0 = 1'b1;
         wait (!vld_out_0)
      read_enb_0 = 1'b0;
      
      fork
         pkt_gen_16;
            wait (!vld_out_2)
         @(negedge clock);
         read_enb_2 = 1'b1;
         #400;
      join
   end
   
endmodule












