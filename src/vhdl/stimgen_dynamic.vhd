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
--! @file stimgen.vhd
--! @brief Generates Stimulies for CCL and compares the result of two instances
--! @author Benjamin Bässler
--! @email ccl@xunit.de
--! @date 2013-09-02
--------------------------------------------------------------------------------

--! Use standard library
library ieee;
--! Use numeric std
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
use IEEE.math_real.all;
use work.types.all;
use work.utils.all;


entity stimgen is
	generic(
		--! Size of the Scheduler table
		G_SIZE_SCHEDULE    : NATURAL := 10;

		--! Number of DUT instances
		G_DUT_INST         : NATURAL := 9;

		--! Number of REV instances
		G_REV_INST         : NATURAL := 9;

		--! Number of Comparators
		G_COMP_INST        : NATURAL := 10;

		--! Image width
		-- value from ccl_dut common.vhd
		G_IMG_WIDTH       : NATURAL := C_IMAGE_WIDTH;

		--! Image height
		-- value from ccl_dut common.vhd
		G_IMG_HEIGHT       : NATURAL := C_IMAGE_HEIGHT
	);
	port(
		--! Clock input
		clk_in          : in STD_LOGIC;

		--! Clock input 2 x clk_in
		clk2x_in        : in STD_LOGIC;

		--! Reset input
		rst_in          : in STD_LOGIC;

		--! error_out valid
		error_valid_out : out STD_LOGIC;

		--! error valu
		error_out       : out STD_LOGIC_VECTOR(3 downto 0);

		--! stimuli lead to error
		stimuli_out     : out STD_LOGIC_VECTOR(G_IMG_WIDTH*G_IMG_HEIGHT-1 downto 0);

		--! how many stimulis are processed
		processed_out   : out STD_LOGIC_VECTOR(G_IMG_WIDTH*G_IMG_HEIGHT-1 downto 0);

		--! rises if check is done
		check_done_out  : out STD_LOGIC
	);
end entity stimgen;

architecture stimgen_arc of stimgen is
	--! All index types can store one value more as neccessary to use index 0 as unused

	--! Scheduler types
	SUBTYPE T_STIM is UNSIGNED(G_IMG_WIDTH*G_IMG_HEIGHT-1 downto 0);
	TYPE T_STIMS is array (G_SIZE_SCHEDULE downto 1) of T_STIM;
	TYPE T_BOX_STATE is (UNASSIGNED, PROCESSING, DONE);
	TYPE T_BOX_S_LIST is array (G_SIZE_SCHEDULE downto 1) of T_BOX_STATE;

	SUBTYPE T_DUT_ID is UNSIGNED(log2_ceil(G_DUT_INST+1)-1 downto 0);
	SUBTYPE T_REV_ID is UNSIGNED(log2_ceil(G_REV_INST+1)-1 downto 0);
	SUBTYPE T_SCHED_ID is UNSIGNED(log2_ceil(G_SIZE_SCHEDULE+1)-1 downto 0);
	SUBTYPE T_COMP_ID is UNSIGNED(log2_ceil(G_COMP_INST+1)-1 downto 0);
	SUBTYPE T_ERROR is UNSIGNED(3 downto 0);
	SUBTYPE T_RD_ADR is UNSIGNED(log2_ceil(G_IMG_HEIGHT*G_IMG_WIDTH) -1 downto 0);

	TYPE T_DUT_IDS is array (G_SIZE_SCHEDULE downto 1) of T_DUT_ID;
	TYPE T_REV_IDS is array (G_SIZE_SCHEDULE downto 1) of T_REV_ID;
	TYPE T_SCHED_IDS is array (G_SIZE_SCHEDULE downto 1) of T_SCHED_ID;
	TYPE T_COMP_IDS is array (G_SIZE_SCHEDULE downto 1) of T_COMP_ID;
	TYPE T_ERRORS is array(G_SIZE_SCHEDULE downto 1) of T_ERROR;
	TYPE T_RD_ADRS is array (G_SIZE_SCHEDULE downto 1) of T_RD_ADR;

	--! REV table types
	TYPE T_REV_SCHED_IDS is array (G_DUT_INST downto 1) of T_SCHED_ID;

	--! Types for comparators
	TYPE T_COMP_BOXES is array (G_COMP_INST downto 1) of T_BOX;
	TYPE T_COMP_ERRORS is array(G_COMP_INST downto 1) of UNSIGNED(3 downto 0);

	--! Types for DUT
	TYPE T_DUT_BOXS is array (G_DUT_INST downto 1) of STD_LOGIC_VECTOR(T_BOX'length
	downto 0);
	TYPE T_DUT_PXS is array (G_DUT_INST downto 1) of STD_LOGIC_VECTOR(1 downto 0);

	--! Types for REV
	TYPE T_REV_XS is array (G_REV_INST downto 1) of
	STD_LOGIC_VECTOR(log2_ceil(C_MAX_IMAGE_WIDTH)-1 downto 0);
	TYPE T_REV_YS is array (G_REV_INST downto 1) of
	STD_LOGIC_VECTOR(log2_ceil(C_MAX_IMAGE_HEIGHT)-1 downto 0);


	--! Scheduler table
	Signal sched_stim_s      : T_STIMS;
	Signal sched_dut_state_s : T_BOX_S_LIST;
	Signal sched_rev_state_s : T_BOX_S_LIST;
	Signal sched_cmp_state_s : T_BOX_S_LIST;
	Signal sched_dut_id_s    : T_DUT_IDS;
	Signal sched_rev_id_s    : T_REV_IDS;
	Signal sched_comp_id_s   : T_COMP_IDS;
	Signal sched_error_s     : T_ERRORS;
	Signal sched_rev_rd_s    : T_RD_ADRS;
	Signal sched_dut_rd_s    : T_RD_ADRS;

	Signal sched_err_done_s  : STD_LOGIC_VECTOR(G_SIZE_SCHEDULE downto 1);

	Signal sched_chk_s       : T_SCHED_ID;
	Signal sched_err_chk_s   : T_SCHED_ID;

	--! REV Table
	Signal rev_sched_in_s  : T_REV_SCHED_IDS;
	Signal rev_sched_pro_s : T_REV_SCHED_IDS;
	Signal rev_sched_out_s : T_REV_SCHED_IDS;
	Signal rev_next_id_s   : T_REV_ID;
	Signal rev_done_s      : STD_LOGIC_VECTOR(G_REV_INST downto 1);

	--! DUT Table
	Signal dut_in_use_s    : STD_LOGIC_VECTOR(G_DUT_INST downto 1);

	--! COMP Table
	Signal comp_in_use_s   : STD_LOGIC_VECTOR(G_COMP_INST downto 1);

	--! Signals for comparators
	Signal comp_rst_s      : STD_LOGIC_VECTOR(G_COMP_INST downto 1);
	Signal comp_last_s     : STD_LOGIC_VECTOR(G_COMP_INST downto 1);
	Signal comp_box1_s     : T_COMP_BOXES;
	Signal comp_box1_vl_s  : STD_LOGIC_VECTOR(G_COMP_INST downto 1);
	Signal comp_box2_s     : T_COMP_BOXES;
	Signal comp_box2_vl_s  : STD_LOGIC_VECTOR(G_COMP_INST downto 1);
	Signal comp_err_s      : T_COMP_ERRORS;
	Signal comp_done_s     : STD_LOGIC_VECTOR(G_COMP_INST downto 1);

	--! Signals for dut
	Signal dut_rst_s       : STD_LOGIC_VECTOR(G_DUT_INST downto 1);
	Signal dut_px_s        : T_DUT_PXS;
	Signal dut_rd_s        : STD_LOGIC_VECTOR(G_DUT_INST downto 1);
	Signal dut_box_s       : T_DUT_BOXS;
	Signal dut_done_s      : STD_LOGIC_VECTOR(G_DUT_INST downto 1);

	--! Signals for rev
	Signal rev_px_vl_s     : STD_LOGIC_VECTOR(G_REV_INST downto 1);
	Signal rev_px_s        : STD_LOGIC_VECTOR(G_REV_INST downto 1);
	Signal rev_vl_out_s    : STD_LOGIC_VECTOR(G_REV_INST downto 1);
	Signal rev_s_x_out_s   : T_REV_XS;
	Signal rev_s_y_out_s   : T_REV_YS;
	Signal rev_e_x_out_s   : T_REV_XS;
	Signal rev_e_y_out_s   : T_REV_YS;
	Signal rev_done_out_s  : STD_LOGIC_VECTOR(G_REV_INST downto 1);

	--! Signal cnt
	--Signal cnt_rst_s       : STD_LOGIC;
	Signal cnt_inc_s       : STD_LOGIC;
	Signal cnt_s           : T_STIM;


begin

	-- Value not exact since cnt_s is the signal which will be processed as next
	processed_out <= std_logic_vector(cnt_s);
	check_done_out <= '1' when cnt_s = to_unsigned(2**(G_IMG_HEIGHT*G_IMG_WIDTH),cnt_s'length+1)-1 else '0';

	p_sched_dut : process (clk_in) is
	begin
		if rising_edge(clk_in) then
			if rst_in = '1' then
				dut_in_use_s <= (others => '0');
				sched_dut_state_s <= (others => UNASSIGNED);
			else
				case sched_dut_state_s(to_integer(sched_chk_s)) is
					when UNASSIGNED =>
						if sched_comp_id_s(to_integer(sched_chk_s)) /= 0 and
						sched_stim_s(to_integer(sched_chk_s)) /= 0
						then
							for i in dut_in_use_s'range loop
								if dut_in_use_s(i) = '0' then
									dut_in_use_s(i) <= '1';
									sched_dut_id_s(to_integer(sched_chk_s)) <= to_unsigned(i, sched_dut_id_s(i)'length);
									sched_dut_state_s(to_integer(sched_chk_s)) <= PROCESSING;
									exit;
								end if;
							end loop;
						end if;
					when PROCESSING =>
						if dut_done_s(to_integer(sched_dut_id_s(to_integer(sched_chk_s)))) = '1' then
							sched_dut_state_s(to_integer(sched_chk_s)) <= DONE;
						end if;
					when DONE =>
						dut_in_use_s(to_integer(sched_dut_id_s(to_integer(sched_chk_s)))) <= '0';
						if sched_cmp_state_s(to_integer(sched_chk_s)) = DONE then
							sched_dut_state_s(to_integer(sched_chk_s)) <= UNASSIGNED;
						end if;
				end case;
			end if; -- rst
		end if; -- clk
	end process p_sched_dut;

	--! assign comperators to schedule table
	p_sched_cmp : process (clk_in) is
	begin
		if rising_edge(clk_in) then
			if rst_in = '1' then
				sched_comp_id_s <= (others => (others => '0'));
				comp_in_use_s <= (others => '0');
				comp_rst_s <= (others => '1');
				sched_cmp_state_s <= (others => UNASSIGNED);
				sched_err_chk_s <= to_unsigned(2, sched_err_chk_s'length);
				error_valid_out <= '0';

				for i in G_SIZE_SCHEDULE downto 1 loop
					sched_stim_s(i) <= to_unsigned(i, G_IMG_WIDTH*G_IMG_HEIGHT);
				end loop;
				cnt_inc_s <= '0';
			else

				cnt_inc_s <= '0';
				if sched_err_chk_s < G_SIZE_SCHEDULE then
					sched_err_chk_s <= sched_err_chk_s + 1;
				else
					sched_err_chk_s <= to_unsigned(1, sched_err_chk_s'length);
				end if;

				comp_rst_s <= (others => '0');
				error_valid_out <= '0';
				case sched_cmp_state_s(to_integer(sched_err_chk_s)) is
					when UNASSIGNED =>
						for i in comp_in_use_s'range loop
							if sched_err_done_s(i) = '1' then
								comp_in_use_s(i) <= '0';
							elsif comp_in_use_s(i) = '0' then
								sched_comp_id_s(to_integer(sched_err_chk_s)) <= to_unsigned(i, sched_comp_id_s(1)'length);
								comp_in_use_s(i) <= '1';
								sched_cmp_state_s(to_integer(sched_err_chk_s)) <= PROCESSING;
								--sched_err_done_s(to_integer(sched_err_chk_s)) <= '0';
								comp_rst_s(i) <= '1';
								exit;
							end if;
						end loop;
					when PROCESSING =>
						if sched_err_done_s(to_integer(sched_err_chk_s)) = '1' then
							sched_cmp_state_s(to_integer(sched_err_chk_s)) <= DONE;
						end if;
					when DONE =>
						if sched_dut_state_s(to_integer(sched_err_chk_s)) = UNASSIGNED then
							-- assigne stimuli for next check
							cnt_inc_s <= '1';
							sched_stim_s(to_integer(sched_err_chk_s)) <= cnt_s;

							-- write output of comparation
							error_valid_out <= '1';
							error_out <= std_logic_vector(sched_error_s(to_integer(sched_err_chk_s)));
							stimuli_out <= std_logic_vector(sched_stim_s(to_integer(sched_err_chk_s)));

							sched_cmp_state_s(to_integer(sched_err_chk_s)) <= UNASSIGNED;
						end if;

				end case;
			end if; --clk
		end if; --rst
	end process p_sched_cmp;

	--! @TODO on start of a new output the rev_sched_pro_s needs to be copied to
	--! rev_sched_out_s
	--! or copy if the rev_sched_out_s gets 0 and set the rev_sched_out_s to 0
	--! if last_box_out rises

	p_rev_io : process (clk_in) is
	begin
		if rising_edge(clk_in) then
			if rst_in = '1' then
				rev_sched_pro_s <= (others => (others => '0'));
				rev_sched_out_s <= (others => (others => '0'));
			else
				for i in rev_sched_pro_s'range loop

					if rev_sched_pro_s(i) = 0 then
						rev_sched_pro_s(i) <= rev_sched_in_s(i);
					end if;

					if rev_sched_out_s(i) = 0 then
						rev_sched_out_s(i) <= rev_sched_pro_s(i);
					end if;

					if rev_done_out_s(i) = '1' then
						rev_sched_pro_s(i) <= (others => '0');
						rev_sched_out_s(i) <= rev_sched_pro_s(i);
					end if;
				end loop;
			end if; --rst
		end if; --clk
	end process;


	p_rev_done : process (clk_in) is
	begin
		if rising_edge(clk_in) then
			if rst_in = '1' then
				rev_done_s <= (others => '0');
			else
				for i in rev_sched_pro_s'range loop
					if rev_sched_out_s(i) /= 0 then
						if rev_done_out_s(i) = '1' then
							rev_done_s(i) <= '1';
						end if;
						if sched_rev_state_s(to_integer(rev_sched_out_s(i))) = DONE then
							rev_done_s(i) <= '0';
						end if;
					end if;
				end loop;
			end if; --rst
		end if; --clk
	end process p_rev_done;


	p_sched_rev : process (clk_in) is
		variable rev_next_id_v : std_logic;
	begin
		if rising_edge(clk_in) then
			if rst_in = '1' then
				sched_rev_state_s <= (others => UNASSIGNED);
				rev_sched_in_s <= (others => (others => '0'));
				sched_chk_s <= to_unsigned(1, sched_chk_s'length);
				rev_next_id_s <= (others => '0');
			else
				-- default
				error_valid_out <= '0';

				if sched_chk_s < G_SIZE_SCHEDULE then
					sched_chk_s <= sched_chk_s + 1;
				else
					sched_chk_s <= to_unsigned(1, sched_chk_s'length);
				end if;

				rev_next_id_s <= (others => '0');

				--! generate rev_next_id_s
				for i in G_REV_INST downto 1 loop
					if rev_sched_in_s(i) = 0 then
						rev_next_id_s <= to_unsigned(i, rev_next_id_s'length);
						exit;
					end if;
				end loop;

				case sched_rev_state_s(to_integer(sched_chk_s)) is
					when UNASSIGNED =>
						if sched_stim_s(to_integer(sched_chk_s)) /= 0 and rev_next_id_s /= 0
						and sched_comp_id_s(to_integer(sched_chk_s)) /= 0 then
							sched_rev_id_s(to_integer(sched_chk_s)) <= rev_next_id_s;
							rev_sched_in_s(to_integer(rev_next_id_s)) <= sched_chk_s;
							sched_rev_state_s(to_integer(sched_chk_s)) <= PROCESSING;
						end if;
					when PROCESSING =>
						if sched_rev_rd_s(to_integer(sched_chk_s)) = G_IMG_HEIGHT*G_IMG_WIDTH then
							rev_sched_in_s(to_integer(sched_rev_id_s(to_integer(sched_chk_s)))) <= (others => '0');
						end if;

						if rev_done_s(to_integer(sched_rev_id_s(to_integer(sched_chk_s)))) = '1' then
							sched_rev_state_s(to_integer(sched_chk_s)) <= DONE;
						end if;
					when DONE =>
						sched_rev_state_s(to_integer(sched_chk_s)) <= UNASSIGNED;
				end case;
			end if; --rst
		end if; --clk
	end process p_sched_rev;



	--! store compare result to register
	p_sched_err : process (clk_in) is
	begin
		if rising_edge(clk_in) then
			if rst_in = '1' then
				sched_err_done_s <= (others => '0');
			else
				for i in sched_error_s'range loop
					if sched_cmp_state_s(i) = PROCESSING then
						if comp_done_s(to_integer(sched_comp_id_s(i))) = '1' then
							sched_err_done_s(i) <= '1';
							sched_error_s(i) <= comp_err_s(to_integer(sched_comp_id_s(i)));
						end if;
					elsif sched_cmp_state_s(i) = UNASSIGNED then
						sched_err_done_s(i) <= '0';
					end if;
				end loop;
			end if; -- rst
		end if; -- clk
	end process p_sched_err;



	--! generate the px for DUT
	p_dut_px : process (clk_in) is
		variable rd_cnt_v : T_RD_ADR;
	begin
		if rising_edge(clk_in) then
			if rst_in = '1' then
				dut_px_s <= (others => (others => '0'));
				dut_rst_s <= (others => '1');
				dut_done_s <= (others => '0');
			else
				dut_px_s <= (others => (others => '0'));
				dut_rst_s <= (others => '0');
				for i in sched_dut_state_s'range loop
					case sched_dut_state_s(i) is
						when UNASSIGNED =>
							--! reset the counter of the stimuli read position
							sched_dut_rd_s(i) <= (others => '0');
						when PROCESSING =>
							rd_cnt_v := sched_dut_rd_s(i);
							if rd_cnt_v <= G_IMG_WIDTH * G_IMG_HEIGHT - 1 then
								--! only write new Value if the DUT FIFO send a ready signal
								if dut_rd_s(to_integer(sched_dut_id_s(i))) = '1' then
									--! write px Value
									dut_px_s(to_integer(sched_dut_id_s(i)))(0) <= sched_stim_s(i)(to_integer(rd_cnt_v));
									--! write px valid Value
									dut_px_s(to_integer(sched_dut_id_s(i)))(1) <= '1';
									sched_dut_rd_s(i) <= rd_cnt_v + 1;
								end if;
							else
								dut_done_s(to_integer(sched_dut_id_s(i))) <= '1';
							end if;
						when DONE =>
							dut_rst_s(to_integer(sched_dut_id_s(i))) <= '1';
							dut_done_s(to_integer(sched_dut_id_s(i))) <= '0';
					end case;
				end loop;
			end if; --rst
		end if; --clk
	end process p_dut_px;


	--! generate the px and px_valid signal for REV
	p_rev_px : process (clk_in) is
		variable rd_cnt_v : T_RD_ADR;
		variable sched_adr_v : T_SCHED_ID;
	begin
		if rising_edge(clk_in) then
			if rst_in = '1' then
				rev_px_vl_s <= (others => '0');
			else
				for i in G_REV_INST downto 1 loop

					--! generate px signal for rev
					sched_adr_v := rev_sched_in_s(i);
					if sched_adr_v /= 0 then
						if sched_rev_state_s(to_integer(sched_adr_v)) = PROCESSING then
							rd_cnt_v := sched_rev_rd_s(to_integer(sched_adr_v));
							rev_px_vl_s(i) <= '0';

							if rd_cnt_v <= G_IMG_WIDTH * G_IMG_HEIGHT - 1 then
								rev_px_vl_s(i) <= '1';
								rev_px_s(i) <= sched_stim_s(to_integer(sched_adr_v))(to_integer(rd_cnt_v));
								sched_rev_rd_s(to_integer(sched_adr_v)) <= rd_cnt_v + 1;
							end if;
						else
							rev_px_vl_s(i) <= '0';
						end if; -- state
					end if;
				end loop;

				for i in G_SIZE_SCHEDULE downto 1 loop
					if sched_rev_state_s(i) = UNASSIGNED then
						sched_rev_rd_s(i) <= (others => '0');
					end if;
				end loop;

			end if; --rst
		end if; --clk
	end process p_rev_px;


	--! controls the data in and outputs of the comperators
	p_switch : process(sched_comp_id_s, sched_rev_id_s, rev_s_x_out_s,
		rev_s_y_out_s, rev_e_x_out_s, rev_e_y_out_s, rev_vl_out_s, dut_box_s,
		sched_rev_state_s, sched_dut_state_s, sched_cmp_state_s)
	is begin
		comp_box2_s <= (others => (others => '-'));
		comp_box2_vl_s <= (others => '0');
		comp_box1_s <= (others => (others => '-'));
		comp_box1_vl_s <= (others => '0');
		comp_last_s <= (others => '0');

		for i in G_SIZE_SCHEDULE downto 1 loop
			if sched_cmp_state_s(i) = PROCESSING then
				if sched_rev_state_s(i) = PROCESSING then
					comp_box2_s(to_integer(sched_comp_id_s(i)))(T_X_START) <= unsigned(rev_s_x_out_s(to_integer(sched_rev_id_s(i))));
					comp_box2_s(to_integer(sched_comp_id_s(i)))(T_Y_START) <= unsigned(rev_s_y_out_s(to_integer(sched_rev_id_s(i))));
					comp_box2_s(to_integer(sched_comp_id_s(i)))(T_X_END) <= unsigned(rev_e_x_out_s(to_integer(sched_rev_id_s(i))));
					comp_box2_s(to_integer(sched_comp_id_s(i)))(T_Y_END) <= unsigned(rev_e_y_out_s(to_integer(sched_rev_id_s(i))));

					comp_box2_vl_s(to_integer(sched_comp_id_s(i))) <= rev_vl_out_s(to_integer(sched_rev_id_s(i)));
				end if;

				if sched_dut_state_s(i) = PROCESSING then
					comp_box1_s(to_integer(sched_comp_id_s(i))) <= unsigned(dut_box_s(to_integer(sched_dut_id_s(i)))(dut_box_s(1)'high -1 downto 0));
					comp_box1_vl_s(to_integer(sched_comp_id_s(i))) <= dut_box_s(to_integer(sched_dut_id_s(i)))(dut_box_s(1)'high);
				end if;

				if sched_rev_state_s(i) = DONE and sched_dut_state_s(i) = DONE then
					--! when both DUT and REV are done, the comperator can start
					comp_last_s(to_integer(sched_comp_id_s(i))) <= '1';
				end if;

			end if;
		end loop;
	end process p_switch;


	gen_comp : for i in G_COMP_INST downto 1 generate
		comparator : entity work.comparator GENERIC MAP(
			G_MAX_BOXES       => integer(ceil(real(C_IMAGE_WIDTH)/2.0))*integer(ceil(real(C_IMAGE_HEIGHT))/2.0)
		)
		PORT MAP(
			clk_in            => clk_in,
			rst_in            => comp_rst_s(i),
			last_box_in       => comp_last_s(i),
			clk1_in           => clk_in,
			box1_in           => comp_box1_s(i),
			box1_valid_in     => comp_box1_vl_s(i),
			box2_in           => comp_box2_s(i),
			box2_valid_in     => comp_box2_vl_s(i),
			error_code_out    => comp_err_s(i),
			check_done_out    => comp_done_s(i)
		);
	end generate gen_comp;


	gen_dut : for i in G_DUT_INST downto 1 generate
		box_dut : entity work.CCL_module PORT MAP(
			clk          	   => clk_in,
			clk2x            => clk2x_in,
			reset        	   => dut_rst_s(i),
			pixel_stream 	   => dut_px_s(i),
			read_fifo    	   => dut_rd_s(i),
			obj_data		     => dut_box_s(i)
		);
	end generate gen_dut;

	gen_rev : for i in G_REV_INST downto 1 generate
		box_rev : entity work.labeling_box PORT MAP(
			clk_in            => clk_in,
			rst_in            => rst_in,
			stall_out         => open,
			stall_in          => '0',
			data_valid_in     => rev_px_vl_s(i),
			px_in             => rev_px_s(i),
			img_width_in      => std_logic_vector(to_unsigned(G_IMG_WIDTH, log2_ceil(C_MAX_IMAGE_WIDTH)+1)),
			img_height_in     => std_logic_vector(to_unsigned(G_IMG_HEIGHT,log2_ceil(C_MAX_IMAGE_HEIGHT)+1)),
			box_valid_out     => rev_vl_out_s(i),
			box_start_x_out   => rev_s_x_out_s(i),
			box_start_y_out   => rev_s_y_out_s(i),
			box_end_x_out     => rev_e_x_out_s(i),
			box_end_y_out     => rev_e_y_out_s(i),
			box_done_out      => rev_done_out_s(i),
			error_out         => open
		);
	end generate gen_rev;

	counter : entity work.counter GENERIC MAP(
		G_CNT_LENGTH    => G_IMG_WIDTH*G_IMG_HEIGHT,
		G_INC_VALUE     => 1,
		G_OFFSET        => to_unsigned(1 + G_SIZE_SCHEDULE, 64)
		--G_OFFSET        => x"0000000700F73906" --1 + G_SIZE_SCHEDULE
	)
	PORT MAP(
		clk_in          => clk_in,
		rst_in          => rst_in,
		inc_in          => cnt_inc_s,
		cnt_out         => cnt_s
	);

end architecture stimgen_arc;


