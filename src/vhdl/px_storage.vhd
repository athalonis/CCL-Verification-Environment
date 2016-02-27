--------------------------------------------------------------------------------
--Copyright (c) 2014, Benjamin Bässler <ccl@xunit.de>
--All rights reserved.
--
--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:
--
--* Redistributions of source code must retain the above copyright notice, this
--  list of conditions and the following disclaimer.
--
--* Redistributions in binary form must reproduce the above copyright notice,
--  this list of conditions and the following disclaimer in the documentation
--  and/or other materials provided with the distribution.
--
--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
--AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
--IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
--FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
--DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
--SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
--CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
--OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
--OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--------------------------------------------------------------------------------
--! @file px_storage.vhd
--! @brief Stores Pixels of multiple pictures
--! @author Benjamin Bässler
--! @email ccl@xunit.de
--! @date 2013-08-12
--------------------------------------------------------------------------------

--! Use standard library
library ieee;
--! Use numeric std
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
use work.utils.all;
use work.types.all;

--! Stores a image (fifo)

entity px_storage is
	generic(
		--! Max image width
		G_MAX_IMG_WIDTH   : NATURAL := C_MAX_IMAGE_WIDTH;

		--! Max image height
		G_MAX_IMG_HEIGHT  : NATURAL := C_MAX_IMAGE_HEIGHT
	);

	port(
		--! Clock input
		clk_in            : in STD_LOGIC;
		--! Reset input
		rst_in            : in STD_LOGIC;

	  --! width of the image at the input
		img_width_in      : in UNSIGNED(log2_ceil(G_MAX_IMG_WIDTH) downto 0);

		--! height of the image 
		img_height_in     : in UNSIGNED(log2_ceil(G_MAX_IMG_HEIGHT) downto 0);

		--! Pixel input 0 => background, 1=> foreground
		wr_px_in          : in STD_LOGIC;

		--! input data are valid
		wr_valid_in       : in STD_LOGIC;

		--! read next pixel the next clock the output is valid
		rd_px_in          : in STD_LOGIC;

		--! read pixel
		rd_px_out         : out STD_LOGIC;

		--! output data are valid
		rd_valid_out      : out STD_LOGIC;

		--! last px out
		rd_last_px_out    : out STD_LOGIC;

		--! second last px out
		rd_slast_px_out   : out STD_LOGIC
	);
end entity px_storage;

architecture px_storage_arc of px_storage is
	constant C_SIZE           : NATURAL := G_MAX_IMG_WIDTH * G_MAX_IMG_HEIGHT;

	type T_IMG_BUFFER is array (0 to C_SIZE-1) of STD_LOGIC;
	Signal img_buffer         : T_IMG_BUFFER;
	Signal img_wptr           : UNSIGNED (log2_ceil(C_SIZE) - 1 downto 0);
	Signal img_rptr           : UNSIGNED (log2_ceil(C_SIZE) - 1 downto 0);
	Signal last_px_s          : std_logic;
begin

	last_px_s <= '1' when img_rptr = img_width_in * img_height_in - 1 else '0';

	p_store : process(clk_in)
	begin

		if rising_edge(clk_in) then
			if rst_in = '1' then
				--! reset signals
				img_wptr <= (others => '0');
			else
				if wr_valid_in = '1' then
					img_buffer(to_integer(img_wptr)) <= wr_px_in;
					img_wptr <= img_wptr + 1;
				end if;

				if last_px_s = '1' then
					-- auto reset
					img_wptr <= (others => '0');
				end if;
			end if; -- rst
		end if; --clk

	end process p_store;

	p_read : process(rst_in, clk_in)
	begin
		if rising_edge(clk_in) then
			if rst_in = '1' then
				--! reset signals
				img_rptr     <= (others => '0');
				rd_valid_out <= '0';
				rd_last_px_out <= '0';
				rd_slast_px_out <= '0';
			else
				rd_valid_out <= '0';
				rd_last_px_out <= '0';
				rd_slast_px_out <= '0';
				if rd_px_in = '1' then 
					rd_px_out <= img_buffer(to_integer(img_rptr));
					img_rptr <= img_rptr + 1;
					rd_valid_out <= '1';
				end if;

				if img_rptr = img_width_in * img_height_in - 2 then
					rd_slast_px_out <= '1';
				end if;

				if last_px_s = '1' then
					--! auto reset
					rd_last_px_out <= '1';
					img_rptr     <= (others => '0');
				end if;
			end if; --rst
		end if; --clk
	end process p_read;

end architecture px_storage_arc;
