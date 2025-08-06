# router1x3

<p align="center">
<img width="680" height="442" alt="RouterTopBlock drawio" src="https://github.com/user-attachments/assets/1514ea33-d076-4b04-b2de-fc398db186d4" />
</p>

ROUTER is a device that connects two or more networks (or computer LANs) and forwards data packets between computer networks (or from Source Server Network to Destination Client Network). It is an OSI layer 3 routing device. Router 1x3 has one ingress and three egress . As the definition suggests, the packet from a source network is routed to one of the destination networks.<br/>
## Router-Packet
### Packet Format
The Packet consists of 3 parts i.e. Header, Payload and Parity such that each ID of 8 bits width and the length of the payload can be extended between 1 byte to 63 bytes.<br/>

<p align="center">
<img width="404" height="315" alt="Project-Page-4 drawio" src="https://github.com/user-attachments/assets/8bcba9f0-f5b1-4011-8cea-765b03d19b2e" />
</p>

#### <ins>Header</ins>
The packet header contains two fields Destination Address and Payload Length.<br/>
- *Destination Address*: The destination address of the packet is of 2 bits. The router drives the packets to respective ports based on the destination address of the packets. Each output port has 2-bit unique port address. If the destination address of the packet matches the port address, then the router drives the packet to the output port. The address "**3**" is invalid.<br/>
- *Payload Length*: The length of the data is 6 bits. It specifies the number of data bytes. A packet can have a minimum data size of 1 byte and a maximum size of 63 bytes.<br/>
  - If Length = 1, it means the data length is 1 byte.<br/>
  - If Length = 63, it means the data length is 63 bytes.<br/>
#### <ins>Payload</ins>
Payload is the data information. Data should be in terms of bytes.<br/>
#### <ins>Parity</ins>
This field contains the security check of the packet. It is calculated as bitwise parity over the header and payload bytes of the packet.<br/>
## Router-Input Protocol

<p align="center">
<img width="604" height="515" alt="Input protocol" src="https://github.com/user-attachments/assets/c26a220e-0baf-454a-a935-b9e79b2d3aa3" />
</p>

**Characteristics**:<br/>
  - *TestBench Note*:
    - All input signals are active high except active low reset and are synchronized to the falling edge of the `clock`. This is because the DUT router is sensitive to the rising edge of the clock. Therefore, in the testbench, driving input signals on the falling edge ensure adequate setup and hold time. But in the SystemVerilog/UVM-based testbench, the clocking block can be used to drive the signals on the positive edge of the clock itself and thus avoids metastability.<br/>
    - The `packet_valid` signal is asserted on the same clock edge when the header byte is driven onto the input data bus.<br/>
    - Since the header byte contains the address, this tells the router to which output channel the packet should be routed (`data_out_0`, `data_out_1`, `data_out_2`).<br/>
    - Each subsequent byte of the payload after the header byte should be driven on the input data bus for every new falling edge of clock.<br/>
    - After the last payload byte has been driven, on the next falling clock, the `packet_valid` signal must be de-asserted, and the packet parity byte should be driven. This signals the completion of the packet.<br/>
    - The testbench shouldn't drive any bytes when a busy signal is detected instead it should hold the last driven value.<br/>
    - The `busy` signal when asserted drops any incoming byte of data.<br/>
    - The `err` signal is asserted when a packet parity mismatch is detected.<br/>
## Router-Output Protocol

<p align="center">
<img width="2987" height="1166" alt="Project-Output Protocol drawio" src="https://github.com/user-attachments/assets/e220b064-bd2d-4661-b1d8-1269c93fc5da" />
</p>

**Characteristics**:<br/>
- *TestBench Note*:
  - All output signals are active high and are synchronized to the rising edge of the clock.<br/>
  - Each output port `data_out_x` (`data_out_0`, `data_out_1`, `data_out_2`) is internally buffered by a FIFO of size 16x9.<br/>
  - The router asserts the `vld_out_x` (`vld_out_0`, `vld_out_1`, `vld_out_2`) signal when valid data appears on the `data_out_x` (`data_out_0`, `data_out_1`, `data_out_2`) output bus. This is a signal to the receiver's client which indicates that data is available on a particular output data bus.<br/>
  - The packet receiver will then wait until it has enough space to hold the bytes of the packet and then respond with the assertion of the `read_enb_x` ( `read_enb_0`, `read_enb_1`, `read_enb_2`) signal.<br/>
  - The `read_enb_x` (`read_enb_0`, `read_enb_1`, `read_enb_2`) input signal can be asserted on the falling clock edge in which data are read from the `data_out_x` (`data_out_0`, `data_out_1`, `data_out_2`) bus.<br/>
  - The `read_enb_x` (`read_enb_0`, `read_enb_1`, `read_enb_2`) must be asserted within 30 clock cycles of `vld_out_x` (`vld_out_0`, `vld_out_1`, `vld_out_2`) being asserted else time-out occurs, which resets the FIFO.<br/>
  - The  `data_out_x` bus will be tri-ststed during a scenario when a packet's byte is lost due to time-out condition.<br/>

##
> [!IMPORTANT]
> This Specification is provided by Maven-Silicon under their [Terms and Conditions](https://www.maven-silicon.com/terms-and-conditions/)
