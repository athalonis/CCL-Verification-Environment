-------------------------------------------------------
--! @file labeling_p1.vhd
--! @brief Common Component Labeling first pass with lookup generation
--! @author Benjamin Bässler
--! @email bbaessler@xunit.de
--! @date 2013-06-04
-------------------------------------------------------

--! Use standard library
library ieee;
--! Use numeric std
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
use work.types.all;
use work.utils.all;

--! The first pass of the labeling algorithm

entity labeling_p1 is
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

		--! Output if the chain resolution stalls
		stall_out         : out STD_LOGIC;

		--! Input if the lookup_table stalls
		stall_in          : in STD_LOGIC;

		--! Pixel input 0 => background, 1=> foreground
		px_in             : in STD_LOGIC;

		--! Pixel px_in is valid
		px_valid_in       : in STD_LOGIC;

		--! width of the image at the input
		img_width_in      : in UNSIGNED(log2_ceil(G_MAX_IMG_WIDTH) downto 0);

		--! height of the image 
		img_height_in     : in UNSIGNED(log2_ceil(G_MAX_IMG_HEIGHT) downto 0);

		--! if last label of image this signal rises
		last_lbl_out      : out STD_LOGIC;

		--! if second last label of image this signal rises
		slast_lbl_out     : out STD_LOGIC;

		--! Value of next new label
		next_lable_in     : in T_LABEL;

		--! tell the lookup table to generate a new label
		gen_lable_out     : out STD_LOGIC;

		--! send the lookup table a new equivalent pair
		equi_out          : out T_EQUI;

		--! Signal to set equivalent pair as valid
		equi_valid_out    : out STD_LOGIC;

		--! output of labeled image
		label_out         : out T_LABEL
	);
end entity labeling_p1;

--! @brief arc description
--! @details more detailed description
architecture labeling_p1_arc of labeling_p1 is

	-- Stores the last row of the input image
	type T_ROW_BUFFER is array (C_MAX_IMAGE_WIDTH-3 downto 0) of T_LABEL;
	signal row_buffer_s   : T_ROW_BUFFER;

	-- Labels of the neighborhood
	signal d, c, b, a     : T_LABEL;
	signal label_out_s    : T_LABEL;

	-- col_cnt needs to be one bigger since the counter is one ahead
	signal col_cnt        : unsigned(log2_ceil(G_MAX_IMG_WIDTH) downto 0);
	signal row_cnt        : unsigned(log2_ceil(G_MAX_IMG_HEIGHT)-1 downto 0);

	signal last_lbl_s     : std_logic;

	attribute ram_style   : string;
	attribute ram_style of row_buffer_s : signal is "auto"; --"{auto|block|distributed|pipe_distributed|block_power1|block_power2}";
begin

	label_out <= label_out_s;
	last_lbl_s <= '1' when resize(col_cnt, col_cnt'length) + 1 = img_width_in and resize(row_cnt, row_cnt'length + 1) + 1 = img_height_in else '0';
	slast_lbl_out <= last_lbl_s;

	p_col_cnt : process(rst_in, clk_in, stall_in)
	begin
		if rising_edge(clk_in) then
			if rst_in = '1' then
				col_cnt <= (others => '0');
				row_cnt <= (others => '0');
			else
				if stall_in = '0' then
					if px_valid_in = '1' then

						if resize (col_cnt, col_cnt'length) + 1 = img_width_in then
							col_cnt <= (others => '0');

							if last_lbl_s = '1' then
								-- autoreset
								row_cnt <= (others => '0');
							else
								row_cnt <= row_cnt + 1;
							end if;
						else
							col_cnt <= col_cnt + 1;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process p_col_cnt;


	p_buffer: process(rst_in, clk_in) is
	begin
		if rst_in = '1' then
			--row_buffer_s <= (others => C_UNLABELD);
			null;
		elsif rising_edge(clk_in) and rst_in = '0' then
			if stall_in = '0' and px_valid_in = '1' then
				row_buffer_s <= row_buffer_s(row_buffer_s'high-1 downto 0) & label_out_s;
			end if;
		end if; -- clk
	end process p_buffer;

	p_lable_selection : process(rst_in, clk_in, px_in)
	begin

		if rst_in = '1' then
			--! reset signals
			d <= C_UNLABELD;
			gen_lable_out <= '0';
			equi_valid_out <= '0';
			label_out_s <= C_UNLABELD;
			last_lbl_out <= '0';

			stall_out <= '1';

		elsif rising_edge(clk_in) and rst_in = '0' then
			--! default settings
			gen_lable_out <= '0';
			equi_valid_out <= '0';

			last_lbl_out <= last_lbl_s;

			if stall_in = '0' and px_valid_in = '1' then
				stall_out <= stall_in;

				if px_in = C_BACKGROUND then
					d <= C_UNLABELD;
					label_out_s <= C_UNLABELD;
				else
					-- No one is labeled in the neighborhood generate new label
					if a = C_UNLABELD and b = C_UNLABELD and c = C_UNLABELD and d = C_UNLABELD then
						d <= next_lable_in;
						label_out_s <= next_lable_in;
						gen_lable_out <= '1';

					else
						if b /= C_UNLABELD then
							-- no merging the selected label doesn't matter,
							-- since the second pass will fix this

							d <= b;
							label_out_s <= b;

							if d /= C_UNLABELD and b > d then
								d <= d;
								label_out_s <= d;
							end if;
							if c /= C_UNLABELD and b > c then
								d <= c;
								label_out_s <= c;
							end if;
							if a /= C_UNLABELD and b > a then
								d <= a;
								label_out_s <= a;
							end if;
						else
							if a /= C_UNLABELD and c /= C_UNLABELD and a /= c then
								if a < c then
									d <= a;
									label_out_s <= a;
									equi_out(0) <= c;
									equi_out(1) <= a;
									equi_valid_out <= '1';
								else
									d <= c;
									label_out_s <= c;
									equi_out(0) <= a;
									equi_out(1) <= c;
									equi_valid_out <= '1';
								end if;
							end if;
							if d /= C_UNLABELD and c /= C_UNLABELD and d /= c then
								if d < c then
									d <= d;
									label_out_s <= d;
									equi_out(0) <= c;
									equi_out(1) <= d;
									equi_valid_out <= '1';
								else
									d <= c;
									label_out_s <= c;
									equi_out(0) <= d;
									equi_out(1) <= c;
									equi_valid_out <= '1';
								end if;
							end if;

							--no merge
							if a /= C_UNLABELD and c /= C_UNLABELD and b = C_UNLABELD and d = C_UNLABELD and a = c then
								d <= a;
								label_out_s <= a;
							end if;


							if a /= C_UNLABELD and c = C_UNLABELD then
								d <= a;
								label_out_s <= a;
							end if;
							if d /= C_UNLABELD and c = C_UNLABELD then
								d <= d;
								label_out_s <= d;
							end if;
							if a = C_UNLABELD and b = C_UNLABELD and d = C_UNLABELD and c /= C_UNLABELD then
								d <= c;
								label_out_s <= c;
							end if;

						end if;
					end if; -- b /= C_UNLABELD

				end if;
				if col_cnt = img_width_in - 1  or last_lbl_s = '1' then
					d <= C_UNLABELD;
				end if;
			end if; -- stall
		end if; --clk
	end process p_lable_selection;

	p_neighbor: process(clk_in, rst_in) is
	begin
		if rst_in = '1' then
			a <= C_UNLABELD;
			b <= C_UNLABELD;
			c <= C_UNLABELD;
		elsif rst_in = '0' and rising_edge(clk_in) then
			if stall_in = '0' and px_valid_in = '1' then
				a <= b;
				b <= c;

				-- c needs to be zero in the first line but on the last col of the first
				-- line the label of the next line needs to be loaded
				if col_cnt = img_width_in-2 or (row_cnt = 0 and col_cnt /= img_width_in-1) then
					c <= C_UNLABELD;
				else
					c <=
				 row_buffer_s(row_buffer_s'high-1-to_integer(G_MAX_IMG_WIDTH-img_width_in));
				end if;

				-- on new line
				if col_cnt = img_width_in - 1 then
					b <= row_buffer_s(row_buffer_s'high-to_integer(G_MAX_IMG_WIDTH-img_width_in));
					a <= C_UNLABELD;
				end if;

				if last_lbl_s = '1' then
					--auto reset
					a <= C_UNLABELD;
					b <= C_UNLABELD;
					c <= C_UNLABELD;
				end if;

			end if; --stall and valid
		end if; --clk
	end process p_neighbor;


end labeling_p1_arc;

