IPbus pattern
----

This project consists of two cooperating VHDL components connected as IPbus slaves:
- ipbus_ram_outputenable - 128-bit register used for enabling outputs 
- ipbus_ram_pattern - 32-element 129-bit cyclic "buffer"

Each of these modules is using 16-bit long adress (mask 0x00072700).
- 1st instance of outputenable has been assigned with address 0x00070100
- 1st instance of pattern has been assigned with address 0x00072100

Other (upper) 16 bits of IPbus address are used to access specific cell of its memory.

----
ipbus_ram_outputenable
----
This component provides 128 outputs connected to separate, addressable 1-bit registers. When accessed over IPbus, only the first bit (LSB) of data is used.
State of an output can be changed using provided setOutput.py script.

----
ipbus_ram_pattern
----
After providing with positive state on output_enable input and proper clock signal on output_clock input, module starts to increment internal counter and iterate over each of 32 blocks. Output of this modules is a concatenation of 4 consecutive memory cells followed by trigger bit.  The last (128) bit of output (the one designed to be used as trigger output) can be accessed over IPBus as 1st bit of 5th cell of each block.
Output pattern can be uploaded to the component using provided setPattern.py script. Example of pattern format has been provided as file named "patterns".
