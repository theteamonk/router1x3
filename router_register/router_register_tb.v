/********************************************************************************************
Filename    :	    router_register_tb.v   

Description :      Register sublock Testbench

Author Name :      Chaitra

Version     :      1.0
********************************************************************************************/

module router_register_tb;

reg clock, resetn, pkt_valid, 	
    fifo_full, 			
    rst_int_reg,			
    detect_add,			
    ld_state,			
    laf_state,			
    full_state,			
    lfd_state;			
reg [7:0] data_in;
wire parity_done,			
     low_pkt_valid,			
     err;
wire [7:0] data_out;

parameter cycle = 10;

integer i;

router_register DUT (.clock(clock), .resetn(resetn), .pkt_valid(pkt_valid), .fifo_full(fifo_full), .rst_int_reg(rst_int_reg), 
                     .detect_add(detect_add), .ld_state(ld_state), .laf_state(laf_state), .full_state(full_state), 
							.lfd_state(lfd_state), .data_in(data_in), .parity_done(parity_done), .err(err), .low_pkt_valid(low_pkt_valid),			
                     .data_out(data_out));
                     
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
   
task initialize();
   begin
      {pkt_valid, 	
      fifo_full, 			
      rst_int_reg,			
      detect_add,			
      ld_state,			
      laf_state,			
      full_state,			
      lfd_state, data_in} = 16'd0;
   end
endtask

task good_packet();				//good packet: internal_parity == packet_parity and err = 0 
   reg [7:0] header, payload_data, parity;
   reg [5:0] payloadlen;
   reg [1:0] addr;
      begin
         @(negedge clock);
         payloadlen = 6'd8;
         addr = 2'b10;
			   detect_add = 1'b1;
				pkt_valid = 1'b1;
		   header = {payloadlen, addr};
			   data_in = header;
         parity = 8'd0;
			parity = parity ^ data_in;		//parity = 0 ^ data_in = data_in
         
         @(negedge clock);
         detect_add = 1'b0;
         lfd_state = 1'b1;			//here, in the design the header_byte is loaded and 
										   //internal_parity takes and stores the header_byte data
											//unconditionally goes to ld_state
         for(i = 0; i < payloadlen; i = i+1)
            begin
               @(negedge clock)
               lfd_state = 1'b0;
               ld_state = 1'b1;
               fifo_full = 1'b0;
               payload_data = {$random}%256;
               data_in = payload_data;
               parity = parity ^ data_in;
            end
         
         @(negedge clock);
         pkt_valid = 1'b0;
			//rst_int_reg = 1'b1;
         ld_state = 1'b1;
         data_in = parity;
      end
endtask

initial
   begin
	   initialize;
      resetf;
      good_packet;
      #30 $finish;
   end

/*
task bad_packet();				//bad packet: internal_parity != packet_parity and err = 1
   reg [7:0] header, payload_data, parity;
   reg [5:0] payloadlen;
   reg [1:0] addr;
      begin
         @(negedge clock);
         payloadlen = 6'd8;
         addr = 2'b10;
			   detect_add = 1'b1;
				pkt_valid = 1'b1;
		   header = {payloadlen, addr};
			  // data_in = header;
         parity = 8'd0;
			parity = parity ^ data_in;		//parity = 0 ^ data_in
         
         @(negedge clock);
         detect_add = 1'b0;
         lfd_state = 1'b1;			//here, in the design the header_byte is loaded and 
										   //internal_parity takes and stores the header_byte data
											//unconditionally goes to ld_state
         for(i = 0; i < payloadlen; i = i+1)
            begin
               @(negedge clock)
               lfd_state = 1'b0;
               ld_state = 1'b1;
               fifo_full = 1'b0;
               payload_data = {$random}%256;
               data_in = payload_data;
               parity = parity ^ data_in;
            end
         
         @(negedge clock);
         pkt_valid = 1'b0;
         ld_state = 1'b1;
         data_in = 80;
      end
endtask

initial
   begin
	   initialize;
      resetf;
      bad_packet;
      #20 $finish;
   end
*/

endmodule

