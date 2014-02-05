--
-- Jakub Kramarz <jakub.kramarz@uj.edu.pl>, February 2014
-- based on ipbus_ram.vhd by Dave Newbold, March 2011
--
-- $Id: ipbus_ram_patterns.vhd 1201 2012-09-28 08:49:12Z phdmn $

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;

entity ipbus_ram_patterns is

	generic(
		--
		-- As IPBus address consists of 32-bits this component uses upper
		-- addr_prefix_width bits as instance prefix and lower addr_width
		-- bits as block address
		--
		addr_width : positive := 8;
		size : positive := 32
	);
	port(
		clk: in STD_LOGIC;
		reset: in STD_LOGIC;
		ipbus_in: in ipb_wbus;
		ipbus_out: out ipb_rbus;
		output_enabled: in STD_LOGIC;
		output_clk: in STD_LOGIC;
		
		data: out STD_LOGIC_VECTOR(128 downto 0) -- first bit is for trigger

	);
	
end ipbus_ram_patterns;

architecture rtl of ipbus_ram_patterns is

	type reg_array is array(2**addr_width-1 downto 0) of std_logic_vector(size-1 downto 0);
	signal reg: reg_array;
	signal ack: std_logic;
	signal act: integer := 0;
	
	signal sel: integer;
	
begin
	sel <= to_integer(
		unsigned(
			ipbus_in.ipb_addr(
				31 downto 31-addr_width+1
			)
		)
	);
	
	process(clk, ipbus_in.ipb_strobe, ipbus_in.ipb_write)
	begin
		if rising_edge(clk) then
			if ipbus_in.ipb_strobe='1' and ipbus_in.ipb_write='1' then
				reg(sel) <= ipbus_in.ipb_wdata;
			end if;
			
			ipbus_out.ipb_rdata <= reg(sel);
			ack <= ipbus_in.ipb_strobe and not ack;
			
		end if;
	end process;
	
	ipbus_out.ipb_ack <= ack;
	ipbus_out.ipb_err <= '0';

	process(output_clk, output_enabled, reset)
	begin
		if rising_edge(output_clk) then
			if reset = '1' then
				act <= 0;
			elsif output_enabled = '1' then
				if act = (size-1) then
					act <= 0;
				else
					act <= act + 1;
				end if;
			end if;
		end if;
	end process;
	--
	-- output block is built from 4 consecutive memory blocks
	-- 1. bit of 5. block is used as trigger bit 
	--  
	process(output_enabled)
	begin
		if output_enabled = '1' then
			data <= reg(5*act+4)(0) & reg(5*act) & reg(5*act + 1) & reg(5*act + 2)  & reg(5*act + 3);
		else
			data <= (others => '0');
		end if;
	end process;

end rtl;
