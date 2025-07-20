/********************************************************************************************
Filename    :	    router_syn_tb.v  

Description :      Synchronizer sublock TestBench

Author Name :      Chaitra

Version     :      1.0
********************************************************************************************/
module router_syn_tb;

reg detect_add;
reg [1:0] data_in;
reg write_enb_reg;
reg clock, resetn;
wire vld_out_0,
     vld_out_1,
     vld_out_2;
reg  read_enb_0,
     read_enb_1,
     read_enb_2;
wire [2:0] write_enb;
wire fifo_full;
reg empty_0,
    empty_1,
    empty_2;
wire soft_reset_0,
     soft_reset_1,
     soft_reset_2;  
reg full_0,
    full_1,
    full_2;
    
parameter cycle = 10;
      
router_syn DUT(detect_add, data_in, write_enb_reg, clock, resetn, vld_out_0, vld_out_1, vld_out_2, read_enb_0, 
               read_enb_1, read_enb_2, write_enb, fifo_full, empty_0, empty_1, empty_2, soft_reset_0, soft_reset_1, 
               soft_reset_2, full_0, full_1, full_2);
               
/*clock*/
always
   begin
      #(cycle/2) clock = 1'b0;
      #(cycle/2) clock = 1'b1;
   end    
   
task initialize;
   begin
      {detect_add, write_enb_reg, read_enb_0, read_enb_1, read_enb_2, full_0, full_1, full_2} = 8'd0;	
      //empty should not be initialized to 0, as it's not is assigned to valid_out_x and the soft_rest_x might get enabled after 30 clock cycles without any data_in
		//but does it matter?
		//check for data_in as well
   end
endtask

task reset();
   begin
      @(negedge clock)
      resetn = 1'b0;
      @(negedge clock)
      resetn = 1'b1;
   end
endtask

task delay;
   begin
      #20;
   end
endtask

task detect_address(input i);
   begin
      detect_add = i;
   end
endtask

task address(input [1:0]rx_address);
   begin
      @(negedge clock) data_in = rx_address;
   end
endtask

task read_signal(input r0, r1, r2);
   begin
      {read_enb_0, read_enb_1, read_enb_2} = {r0, r1, r2};
   end
endtask

task empty_status(input e0, e1, e2);
   begin
      {empty_0, empty_1, empty_2} = {e0, e1, e2};
   end
endtask

task full_status(input f0, f1, f2);
   begin
      {full_0, full_1, full_2} = {f0, f1, f2};
   end
endtask

task write_signal;
   begin
      write_enb_reg = 1'b1;
   end
endtask

initial
   begin
      initialize;
      delay;
      reset;
      address(2'b10);
		delay;
      detect_address(1);
      delay;
		write_signal;
      empty_status(1, 1, 0);
      repeat(40)
      delay;
      read_signal(0,0,1);
      #1000;
   end

endmodule
      
