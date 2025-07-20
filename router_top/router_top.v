/********************************************************************************************
Filename    :	    router_top.v   

Description :      Register sublock Design

Author Name :      Chaitra

Version     :      1.0
********************************************************************************************/

module router_top(
input  clock, resetn, 
       read_enb_0,
       read_enb_1,
       read_enb_2,
       pkt_valid,
input  [7:0] data_in,
output err, busy,
       vld_out_0,
       vld_out_1,
       vld_out_2,
output [7:0] data_out_0,
             data_out_1,
             data_out_2
);

wire lfd_state_w,
	  fifo_empty_w_0, 
	  fifo_empty_w_1, 
	  fifo_empty_w_2;

//going to FIFO 0, 1, 2 
wire [2:0] write_enb;
wire [7:0] data_out_w;

//other internal one bit ports can also be declared or can be directly instantiated

router_fsm fsm(.clock(clock), 
					.resetn(resetn), 
					.pkt_valid(pkt_valid), 
					.data_in(data_in[1:0]),
					.busy(busy),
					
					.parity_done(parity_done),
					.soft_reset_0(soft_reset_0), 
					.soft_reset_1(soft_reset_1), 
					.soft_reset_2(soft_reset_2),
					.fifo_full(fifo_full),
					.low_pkt_valid(low_pkt_valid),
					.detect_add(detect_add),
					.ld_state(ld_state),
					.laf_state(laf_state),
					.full_state(full_state),
					.write_enb_reg(write_enb_reg),
					.rst_int_reg(rst_int_reg),
					
					.fifo_empty_0(fifo_empty_w_0), 
					.fifo_empty_1(fifo_empty_w_1), 
					.fifo_empty_2(fifo_empty_w_2), 
					.lfd_state(lfd_state_w));
       	 
router_syn synchronizer(.clock(clock), 
								.resetn(resetn),
								.data_in (data_in [1:0]), 
								.vld_out_0(vld_out_0), 
								.vld_out_1(vld_out_1), 
								.vld_out_2(vld_out_2), 
								.read_enb_0(read_enb_0), 
								.read_enb_1(read_enb_1), 
								.read_enb_2(read_enb_2), 
								
								.soft_reset_0(soft_reset_0), 
								.soft_reset_1(soft_reset_1), 
								.soft_reset_2(soft_reset_2),
								.fifo_full(fifo_full),
								.detect_add(detect_add),
								.write_enb_reg(write_enb_reg),
								.full_0(full_0), 
								.full_1(full_1), 
								.full_2(full_2),
								 
								.write_enb (write_enb), 
								.empty_0(fifo_empty_w_0), 
								.empty_1(fifo_empty_w_1), 
								.empty_2(fifo_empty_w_2));
			 
router_register register(.clock(clock), 
								 .resetn(resetn), 
								 .pkt_valid(pkt_valid), 
								 .data_in(data_in),
								 .err(err),
								 
								 .parity_done(parity_done),
								 .fifo_full(fifo_full),
								 .low_pkt_valid(low_pkt_valid),
								 .detect_add(detect_add),
								 .ld_state(ld_state), 
								 .laf_state(laf_state),
								 .full_state(full_state),
								 .rst_int_reg(rst_int_reg),
								 
								 .data_out(data_out_w),
								 .lfd_state(lfd_state_w));
			 
router_fifo fifo_0(.clock(clock), 
					  .resetn(resetn), 
					  .data_in(data_out_w), 
					  .read_enb(read_enb_0),
					  .data_out(data_out_0),
					  
					  .soft_reset(soft_reset_0),
					  .full(full_0),
					  .write_enb(write_enb[0]),
					  
					  .empty(fifo_empty_w_0), 
					  .lfd_state(lfd_state_w));
					  
router_fifo fifo_1(.clock(clock), 
					  .resetn(resetn), 
					  .data_in(data_out_w), 
					  .read_enb(read_enb_1), 
					  .data_out(data_out_1),
					  
					  .soft_reset(soft_reset_1),
					  .full(full_1),
					  .write_enb(write_enb[1]),  
					  
					  .empty(fifo_empty_w_1), 
					  .lfd_state(lfd_state_w));
					  
router_fifo fifo_2(.clock(clock), 
					  .resetn(resetn), 
					  .data_in(data_out_w), 
					  .read_enb(read_enb_2),
					  .data_out(data_out_2),
					  
					  .soft_reset(soft_reset_2),
					  .full(full_2), 
					  .write_enb(write_enb[2]),  
					  
					  .empty(fifo_empty_w_2), 
					  .lfd_state(lfd_state_w));

endmodule
