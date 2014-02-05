--
-- Jakub Kramarz <jakub.kramarz@uj.edu.pl>, February 2014
-- based on ipbus_ram.vhd by Dave Newbold, March 2011
--
-- $Id: ipbus_ram_outputenable.vhd 1201 2012-09-28 08:49:12Z phdmn $

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;

entity ipbus_ram_outputenable is

	generic(
		--
		-- As IPBus address consists of 32-bits this component uses upper
		-- addr_prefix_width bits as instance prefix and lower addr_width
		-- bits as block address
		--
		addr_width : positive := 8
	);
	port(
		clk: in STD_LOGIC;
		reset: in STD_LOGIC;
		ipbus_in: in ipb_wbus;
		ipbus_out: out ipb_rbus;
		
		output_enabled: out STD_LOGIC_VECTOR(2**addr_width-1 downto 0)

	);
	
end ipbus_ram_outputenable;

architecture rtl of ipbus_ram_outputenable is
	signal reg: std_logic_vector(2**addr_width-1 downto 0);
	signal sel: integer;
	signal ack: std_logic;
begin
	sel <= to_integer(
		unsigned(
			ipbus_in.ipb_addr(
				31 downto 31-addr_width+1
			)
		)
	);
	process(clk, reset, ipbus_in.ipb_strobe, ipbus_in.ipb_write)
	begin
		if rising_edge(clk) then
			if ipbus_in.ipb_strobe='1' and ipbus_in.ipb_write='1' then
				if reset = '1' then
					reg <= (others=>'0');
				else
					reg(sel) <= ipbus_in.ipb_wdata(0);
				end if;
			end if;
			
			ipbus_out.ipb_rdata <= (0 => reg(sel), others=>'0');
			ack <= ipbus_in.ipb_strobe and not ack;
			
		end if;
	end process;
	
	ipbus_out.ipb_ack <= ack;
	ipbus_out.ipb_err <= '0';
	output_enabled <= reg;

end rtl;
