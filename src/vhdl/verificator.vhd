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
--! @file verificator.vhd
--! @brief Puts everything together ref, dut, comparator
--! @author Benjamin Bässler
--! @email ccl@xunit.de
--! @date 2013-09-02
--! @details This is the top module for the verification of the CCL and DUT
--! implementation
--! For testing the camera interface use the camif.vhd
--------------------------------------------------------------------------------

--! Use standard library
library ieee;
--! Use numeric std
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
use IEEE.math_real.all;
use work.types.all;
use work.utils.all;

library pccl_lib;
use pccl_lib.all;

entity verificator is
	generic(
		--! Number of Comparators
		G_COMP_INST     : NATURAL := C_COMP_INST;

		--! Image width
		-- value from ccl_dut common.vhd
		G_IMG_WIDTH     : NATURAL := C_IMAGE_WIDTH;

		--! Image height
		-- value from ccl_dut common.vhd
		G_IMG_HEIGHT    : NATURAL := C_IMAGE_HEIGHT
	);
	port(
		--! Clock input
		clk_in          : in STD_LOGIC;

		--! Reset input
		rst_in          : in STD_LOGIC;

	  --! run verification
		run_in          : in STD_LOGIC;

		--! Stimuli in
		stimuli_in      : in UNSIGNED(G_IMG_WIDTH*G_IMG_HEIGHT-1 downto 0);

		--! Stimuli in valid
		stimuli_v_in    : in STD_LOGIC;

		--! error_out valid
		error_valid_out : out STD_LOGIC;

		--! error valu
		error_out       : out T_ERROR;

		--! stimuli lead to error
		stimuli_out     : out UNSIGNED(G_IMG_WIDTH*G_IMG_HEIGHT-1 downto 0);

		--! high if all instances of the comparators in use
		max_util_out    : out STD_LOGIC;

		--! counter output
		counter_out     : out unsigned(C_CNT_SIZE*C_MAX_BOXES-1 downto 0);

		--! high if no testpattern to process asigned
		idle_out        : out STD_LOGIC
	);
end entity verificator;


--! @brief implements the verificator
--! @details The verificator puts all components together and schedules the
--! stimulies to the multiple reference implementations, implementation under
--! test and the output of the related implementation to the comparator.

architecture verificator_arc of verificator is

	CONSTANT C_MAX_USAGE : STD_LOGIC_VECTOR(G_COMP_INST downto 1) := (others =>	'1');

	--! All index types can store one value more as neccessary to use index 0 as unused

	--! Scheduler types
	SUBTYPE T_STIM is UNSIGNED(G_IMG_WIDTH*G_IMG_HEIGHT-1 downto 0);
	TYPE T_STIMS is array (G_COMP_INST downto 1) of T_STIM;
	TYPE T_BOX_STATE is (UNASSIGNED, PROCESSING, DONE);
	TYPE T_BOX_S_LIST is array (G_COMP_INST downto 1) of T_BOX_STATE;


	SUBTYPE T_DUT_ID is UNSIGNED(log2_ceil(G_COMP_INST+1)-1 downto 0);
	SUBTYPE T_REF_ID is UNSIGNED(log2_ceil(G_COMP_INST+1)-1 downto 0);
	SUBTYPE T_SCHED_ID is UNSIGNED(log2_ceil(G_COMP_INST+1)-1 downto 0);
	SUBTYPE T_COMP_ID is UNSIGNED(log2_ceil(G_COMP_INST+1)-1 downto 0);


	-- +2 for two additional white lines
	SUBTYPE T_RD_ADR is UNSIGNED(log2_ceil((G_IMG_HEIGHT+2)*G_IMG_WIDTH) -1 downto 0);

	TYPE T_DUT_IDS is array (G_COMP_INST downto 1) of T_DUT_ID;
	TYPE T_REF_IDS is array (G_COMP_INST downto 1) of T_REF_ID;
	TYPE T_SCHED_IDS is array (G_COMP_INST downto 1) of T_SCHED_ID;
	TYPE T_COMP_IDS is array (G_COMP_INST downto 1) of T_COMP_ID;
	TYPE T_ERROR_LIST is array (G_COMP_INST downto 1) of T_ERROR;
	TYPE T_RD_ADRS is array (G_COMP_INST downto 1) of T_RD_ADR;

	--! ref table types
	TYPE T_ref_SCHED_IDS is array (G_COMP_INST downto 1) of T_SCHED_ID;

	--! Types for comparators
	TYPE T_COMP_BOXES is array (G_COMP_INST downto 1) of T_BOX;
	TYPE T_COMP_ERRORS is array(G_COMP_INST downto 1) of UNSIGNED(3 downto 0);

	--! Types for DUT
	TYPE T_DUT_BOXS is array (G_COMP_INST downto 1) of STD_LOGIC_VECTOR(T_BOX'range);
	TYPE T_DUT_PXS is array (G_COMP_INST downto 1) of STD_LOGIC_VECTOR(1 downto 0);
	TYPE T_DUT_ERRORS is array (G_COMP_INST downto 1) of
	STD_LOGIC_VECTOR(C_ERR_DUT_SIZE - 1 downto 0);

	--! Types for ref
	TYPE T_REF_XS is array (G_COMP_INST downto 1) of
	STD_LOGIC_VECTOR(log2_ceil(C_MAX_IMAGE_WIDTH)-1 downto 0);
	TYPE T_REF_YS is array (G_COMP_INST downto 1) of
	STD_LOGIC_VECTOR(log2_ceil(C_MAX_IMAGE_HEIGHT)-1 downto 0);
	TYPE T_REF_ERRORS is array (G_COMP_INST downto 1) of
	STD_LOGIC_VECTOR(C_ERR_REF_SIZE - 1 downto 0);

	--! Types for CNT
	TYPE T_CNT_LBL is array (G_COMP_INST downto 1) of
	unsigned(C_CNT_SIZE*C_MAX_BOXES-1 downto 0);

	--! Scheduler table
	Signal sched_stim_s      : T_STIMS;
	Signal sched_dut_state_s : T_BOX_S_LIST;
	Signal sched_ref_state_s : T_BOX_S_LIST;
	Signal sched_cmp_state_s : T_BOX_S_LIST;
	Signal sched_ref_id_s    : T_REF_IDS;
	Signal sched_comp_id_s   : T_COMP_IDS;
	Signal sched_ref_rd_s    : T_RD_ADRS;
	Signal sched_dut_rd_s    : T_RD_ADRS;

	Signal next_id_s         : T_SCHED_ID;

	--! ref Table
	Signal ref_sched_pro_s : T_ref_SCHED_IDS;
	Signal ref_sched_out_s : T_ref_SCHED_IDS;

	--! component in use?
	Signal in_use_s        : STD_LOGIC_VECTOR(G_COMP_INST downto 1);
	Signal in_use_cnt_s    : UNSIGNED(log2_ceil(G_COMP_INST) downto 0);

	-- Store error output for output by arbitor
	Signal comp_err_l_s    : T_ERROR_LIST;
	Signal comp_err_lv_s   : UNSIGNED(G_COMP_INST downto 0);
	Signal comp_err_stim_s : T_STIMS;


	--! COMP Table
	--! Signals for comparators
	Signal comp_rst_s      : STD_LOGIC_VECTOR(G_COMP_INST downto 1);
	Signal comp_restart_s  : STD_LOGIC_VECTOR(G_COMP_INST downto 1);
	Signal comp_last_s     : STD_LOGIC_VECTOR(G_COMP_INST downto 1);
	Signal comp_box1_s     : T_COMP_BOXES;
	Signal comp_box1_vl_s  : STD_LOGIC_VECTOR(G_COMP_INST downto 1);
	Signal comp_box2_s     : T_COMP_BOXES;
	Signal comp_box2_vl_s  : STD_LOGIC_VECTOR(G_COMP_INST downto 1);
	Signal comp_err_s      : T_COMP_ERRORS;
	Signal comp_done_s     : STD_LOGIC_VECTOR(G_COMP_INST downto 1);

	--! Signals for dut
	Signal dut_rst_s       : STD_LOGIC_VECTOR(G_COMP_INST downto 1);
	Signal dut_px_vl_s     : STD_LOGIC_VECTOR(G_COMP_INST downto 1);
	Signal dut_px_s_vl_s   : STD_LOGIC_VECTOR(G_COMP_INST downto 1);
	Signal dut_px_s        : STD_LOGIC_VECTOR(G_COMP_INST downto 1);
	Signal dut_ready_s     : STD_LOGIC_VECTOR(G_COMP_INST downto 1);
	Signal dut_box_s       : T_DUT_BOXS;
	Signal dut_box_vl_s    : STD_LOGIC_VECTOR(G_COMP_INST downto 1);
	Signal dut_done_s      : STD_LOGIC_VECTOR(G_COMP_INST downto 1);
	Signal dut_err_out_s   : T_DUT_ERRORS;
	Signal dut_err_s       : T_DUT_ERRORS;

	--! Signals for ref
	Signal ref_rst_s       : STD_LOGIC_VECTOR(G_COMP_INST downto 1);
	Signal ref_px_vl_s     : STD_LOGIC_VECTOR(G_COMP_INST downto 1);
	Signal ref_px_s        : STD_LOGIC_VECTOR(G_COMP_INST downto 1);
	Signal ref_vl_out_s    : STD_LOGIC_VECTOR(G_COMP_INST downto 1);
	Signal ref_s_x_out_s   : T_REF_XS;
	Signal ref_s_y_out_s   : T_REF_YS;
	Signal ref_e_x_out_s   : T_REF_XS;
	Signal ref_e_y_out_s   : T_REF_YS;
	Signal ref_done_out_s  : STD_LOGIC_VECTOR(G_COMP_INST downto 1);
	Signal ref_err_out_s   : T_REF_ERRORS;
	Signal ref_err_s       : T_REF_ERRORS;


	Signal cnt_lbl_s       : T_CNT_LBL;
	Signal cnt_add_ptr_s   : unsigned(C_MAX_BOXES-1 downto 0);
	Signal counter_s       : unsigned(C_CNT_SIZE*C_MAX_BOXES-1 downto 0);

	function unary2bin (u : STD_LOGIC_VECTOR) return unsigned is
		variable bin_v : unsigned(log2_ceil(u'length) downto 0);
	begin
		bin_v := (others => '0');
		for i in u'range loop
			if u(i) = '1' then
				bin_v := bin_v + 1;
			end if;
		end loop;
		return bin_v;
	end function;

begin

	in_use_cnt_s <= unary2bin(in_use_s);

	idle_out <= '1' when in_use_cnt_s = 0 else '0';
	max_util_out <= '0' when in_use_cnt_s < G_COMP_INST-1 or
									(stimuli_v_in = '0' and in_use_cnt_s = G_COMP_INST-1) else '1';



	--! @brief computes the next to use instance of dut, ref, cmp
	p_next_sched : process (clk_in) is
	begin
		if rising_edge(clk_in) then
			if rst_in = '1' then
				next_id_s <= to_unsigned(1, next_id_s'length);

			else

				-- compute next unused id
				for i in G_COMP_INST downto 1 loop
					if i /= next_id_s and in_use_s(i) = '0' then
						next_id_s <= to_unsigned(i, next_id_s'length);
						exit;
					end if;
				end loop;

			end if; --rst
		end if; --clk
	end process;



	--! @brief computes the state of the dut instances
	p_sched_dut : process (clk_in) is
		variable in_use_cnt_v : UNSIGNED(log2_ceil(G_COMP_INST) downto 0);
	begin
		if rising_edge(clk_in) then
			if rst_in = '1' then
				sched_dut_state_s <= (others => UNASSIGNED);
				in_use_s <= (others => '0');
				--in_use_cnt_s <= (others => '0');
			else
				--in_use_cnt_v := in_use_cnt_s;
				for i in G_COMP_INST downto 1 loop

					case sched_dut_state_s(i) is
						when UNASSIGNED =>
							in_use_s(i) <= '0';
							if in_use_s(i) = '1' then
								in_use_cnt_v := in_use_cnt_v - 1;
							end if;

							if next_id_s = i and in_use_s(i) = '0' and stimuli_v_in = '1' then
								in_use_cnt_v := in_use_cnt_v + 1;
								in_use_s(i) <= '1';
								sched_dut_state_s(i) <= PROCESSING;
								sched_stim_s(i) <= stimuli_in;
							end if;

						when PROCESSING =>
							if dut_done_s(i) = '1' then
								sched_dut_state_s(i) <= DONE;
							end if;
							in_use_s(i) <= '1';

						when DONE =>
							if sched_cmp_state_s(i) = DONE then
								sched_dut_state_s(i) <= UNASSIGNED;
							end if;
							in_use_s(i) <= '1';
					end case;

				end loop;
				--in_use_cnt_s <= in_use_cnt_v;
			end if; -- rst
		end if; -- clk
	end process p_sched_dut;

	--! @brief computes the state of the comparator
	p_sched_cmp : process (clk_in) is
	begin
		if rising_edge(clk_in) then
			if rst_in = '1' then
				comp_rst_s <= (others => '1');
				comp_restart_s <= (others => '0');
				error_valid_out <= '0';
				comp_err_lv_s <= (others => '0');
				sched_cmp_state_s <= (others => UNASSIGNED);
			else

				comp_rst_s <= (others => '0');
				comp_restart_s <= (others => '0');
				error_valid_out <= '0';

				for i in G_COMP_INST downto 1 loop
					case sched_cmp_state_s(i) is
						when UNASSIGNED =>
							if next_id_s = i and in_use_s(i) = '0' and stimuli_v_in = '1' then
								sched_cmp_state_s(i) <= PROCESSING;
							end if;
						when PROCESSING =>
							if comp_done_s(i) = '1' then
								sched_cmp_state_s(i) <= DONE;
							end if;
						when DONE =>
							-- write output of comparation to the error arbiter
							comp_err_l_s(i) <= UNSIGNED(dut_err_s(i)) & UNSIGNED(ref_err_s(i)) & comp_err_s(i);
							comp_err_lv_s(i) <= '1';
							comp_err_stim_s(i) <= sched_stim_s(i);
							comp_restart_s(i) <= '1';

							sched_cmp_state_s(i) <= UNASSIGNED;
					end case;
				end loop;

				--! Do the error output arbitration
				for i in G_COMP_INST downto 1 loop
					if comp_err_lv_s(i) = '1' then
						stimuli_out <= comp_err_stim_s(i);
						error_out <= comp_err_l_s(i);
						comp_err_lv_s(i) <= '0';
						error_valid_out <= '1';
						exit;
					end if;
				end loop;

			end if; --clk
		end if; --rst
	end process p_sched_cmp;

	--! @brief computes the state of the ref implementation
	p_sched_ref : process (clk_in) is
	begin
		if rising_edge(clk_in) then
			if rst_in = '1' then
				sched_ref_state_s <= (others => UNASSIGNED);
			else

				for i in G_COMP_INST downto 1 loop
					case sched_ref_state_s(i) is
						when UNASSIGNED =>
							if next_id_s = i and in_use_s(i) = '0' and stimuli_v_in = '1' then
								sched_ref_state_s(i) <= PROCESSING;
							end if;
						when PROCESSING =>
							--if sched_ref_rd_s(i) = G_IMG_HEIGHT*G_IMG_WIDTH then

							if ref_done_out_s(i) = '1' then
								sched_ref_state_s(i) <= DONE;
							end if;
						when DONE =>
							if sched_dut_state_s(i) = DONE then
								sched_ref_state_s(i) <= UNASSIGNED;
							end if;
					end case;
				end loop;

			end if; --rst
		end if; --clk
	end process p_sched_ref;

	--! this process monitors all errors occurred over a run
	p_err_ref : process(clk_in, rst_in)
	begin
		if rst_in = '1' then
			ref_err_s <= (others => (others => '0'));
		else
			if rising_edge(clk_in) then
				for i in G_COMP_INST downto 1 loop
					if comp_restart_s(i) = '1' then
						ref_err_s (i) <= (others => '0');
					else
						ref_err_s(i) <= ref_err_out_s(i) or ref_err_s(i);
					end if;
				end loop;
			end if; -- clk
		end if;--rst
	end process p_err_ref;

	--! this process monitors all errors occurred over a run
	p_err_dut : process(clk_in, rst_in)
	begin
		if rst_in = '1' then
			dut_err_s <= (others => (others => '0'));
		else
			if rising_edge(clk_in) then
				for i in G_COMP_INST downto 1 loop
					if comp_restart_s(i) = '1' then
						dut_err_s (i) <= (others => '0');
					else
						dut_err_s(i) <= dut_err_out_s(i) or dut_err_s(i);
					end if;
				end loop;
			end if;--clk
		end if;--rst
	end process p_err_dut;



	--! generate the px for DUT
	p_dut_px : process (clk_in) is
	begin
		if rising_edge(clk_in) then
			if rst_in = '1' then
				dut_rst_s <= (others => '1');
				dut_done_s <= (others => '0');
			else
				dut_rst_s <= (others => '0');

				for i in G_COMP_INST downto 1 loop

					case sched_dut_state_s(i) is
						when UNASSIGNED =>
							--! reset the counter of the stimuli read position
							sched_dut_rd_s(i) <= (others => '0');
						when PROCESSING =>

							--! only write new Value if the DUT FIFO send a ack signal
							if dut_ready_s(i) = '1' and run_in = '1' then

								sched_dut_rd_s(i) <= sched_dut_rd_s(i) + 1;

								if sched_dut_rd_s(i) >= G_IMG_WIDTH * G_IMG_HEIGHT - 2 + C_DUT_EXTRA_CLKS then
									dut_done_s(i) <= '1';
								end if;
							end if;
						when DONE =>
							dut_rst_s(i) <= '1';
							dut_done_s(i) <= '0';
					end case;
				end loop;
			end if; --rst
		end if; --clk
	end process p_dut_px;


	--! generate the px and px_valid signal for ref
	p_ref_px : process (clk_in) is
		variable rd_cnt_v : T_RD_ADR;
	begin
		if rising_edge(clk_in) then
			if rst_in = '1' then
				ref_px_vl_s <= (others => '0');
				ref_rst_s <= (others => '1');
			else
				ref_px_vl_s <= (others => '0');
				ref_rst_s <= (others => '0');

				for i in G_COMP_INST downto 1 loop
					case sched_ref_state_s(i) is
						when UNASSIGNED =>
							--! reset the counter of the stimuli read position
							sched_ref_rd_s(i) <= (others => '0');
						when PROCESSING =>
							rd_cnt_v := sched_ref_rd_s(i);
							if rd_cnt_v <= G_IMG_WIDTH * G_IMG_HEIGHT - 1 then
								--! only write new Value if the ref FIFO send a ready signal
								if run_in = '1' then
									--! write px Value
									ref_px_s(i) <= sched_stim_s(i)(to_integer(rd_cnt_v));
									--! write px valid Value
									ref_px_vl_s(i) <= '1';
									sched_ref_rd_s(i) <= rd_cnt_v + 1;
								end if;
							end if;
						when DONE =>
							ref_rst_s(i) <= '1';
							--ref_done_s(i) <= '0';
							null;
					end case;
				end loop;

			end if; --rst
		end if; --clk
	end process p_ref_px;


	--! controls the data in and outputs of the comperators
	p_switch : process(sched_comp_id_s, sched_ref_id_s, ref_s_x_out_s,
		ref_s_y_out_s, ref_e_x_out_s, ref_e_y_out_s, ref_vl_out_s, dut_box_s,
		dut_box_vl_s,	sched_ref_state_s, sched_dut_state_s, sched_cmp_state_s)
	is begin
		comp_box2_s <= (others => (others => '-'));
		comp_box2_vl_s <= (others => '0');
		comp_box1_s <= (others => (others => '-'));
		comp_box1_vl_s <= (others => '0');
		comp_last_s <= (others => '0');

		for i in G_COMP_INST downto 1 loop
			if sched_cmp_state_s(i) = PROCESSING then
				if sched_ref_state_s(i) = PROCESSING then
					comp_box2_s(i)(T_X_START) <= unsigned(ref_s_x_out_s(i));
					comp_box2_s(i)(T_Y_START) <= unsigned(ref_s_y_out_s(i));
					comp_box2_s(i)(T_X_END) <= unsigned(ref_e_x_out_s(i));
					comp_box2_s(i)(T_Y_END) <= unsigned(ref_e_y_out_s(i));

					comp_box2_vl_s(i) <= ref_vl_out_s(i);
				end if;

				if sched_dut_state_s(i) = PROCESSING then
					comp_box1_s(i) <= unsigned(dut_box_s(i));
					comp_box1_vl_s(i) <= dut_box_vl_s(i);
				end if;

				if sched_ref_state_s(i) = DONE and sched_dut_state_s(i) = DONE then
					--! when both DUT and ref are done, the comperator can start
					comp_last_s(i) <= '1';
				end if;

			end if;
		end loop;
	end process p_switch;


	gen_comp : for i in G_COMP_INST downto 1 generate
		comparator : entity work.comparator GENERIC MAP(
			G_MAX_BOXES       => div_ceil(C_MAX_IMAGE_WIDTH,2)*div_ceil(C_MAX_IMAGE_HEIGHT, 2)
		)
		PORT MAP(
			clk_in            => clk_in,
			rst_in            => comp_rst_s(i),
			restart_in        => comp_restart_s(i),
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


	gen_dut : for i in G_COMP_INST downto 1 generate
		box_dut : entity pccl_lib.CCL_Slice
		GENERIC MAP(
			slice_number    => 0
		)
		PORT MAP(
			LLabel_in       => (0, 0),      -- Label_Type
			LSetLT_in       => (0, 0, '0'), -- lt_update_type
			RLabel_in       => (0, 0),      -- Label_Type
			RSetLT_in       => (0, 0, '0'), -- lt_update_type
			clk             => clk_in,
			gl_new          => 0,           -- integer RANGE 0 TO no_gl-1;
			pixel_valid     => dut_px_s_vl_s(i),
			pixel_value     => dut_px_s(i),
			res             => dut_rst_s(i),
			LLAbel_out      => open,
			LsetLT_out      => open,
			RLabel_out      => open,
			RSetLT_out      => open,
			error_type      => dut_err_out_s(i),
			finished_object => dut_box_s(i),
			fo_gl           => open,
			fo_sn           => open,
			fo_valid        => dut_box_vl_s(i),
			gl_used         => open,
			ready           => dut_ready_s(i),
			to_mq           => open
		);

		dut_px_s(i) <= '0' when sched_dut_rd_s(i) > G_IMG_WIDTH * G_IMG_HEIGHT - 1 else sched_stim_s(i)(to_integer(sched_dut_rd_s(i)));
		dut_px_s_vl_s(i) <= dut_ready_s(i) when sched_dut_state_s(i) = PROCESSING else
												'0';

	end generate gen_dut;

	gen_ref : for i in G_COMP_INST downto 1 generate
		box_ref : entity work.labeling_box PORT MAP(
			clk_in            => clk_in,
			rst_in            => ref_rst_s(i),
			stall_out         => open,
			stall_in          => '0',
			data_valid_in     => ref_px_vl_s(i),
			px_in             => ref_px_s(i),
			img_width_in      => std_logic_vector(to_unsigned(G_IMG_WIDTH, log2_ceil(C_MAX_IMAGE_WIDTH)+1)),
			img_height_in     => std_logic_vector(to_unsigned(G_IMG_HEIGHT,log2_ceil(C_MAX_IMAGE_HEIGHT)+1)),
			box_valid_out     => ref_vl_out_s(i),
			box_start_x_out   => ref_s_x_out_s(i),
			box_start_y_out   => ref_s_y_out_s(i),
			box_end_x_out     => ref_e_x_out_s(i),
			box_end_y_out     => ref_e_y_out_s(i),
			box_done_out      => ref_done_out_s(i),
			error_out         => ref_err_out_s(i)
		);
	end generate gen_ref;


	gen_cnt_en : if C_INCLUDE_CNT generate
		gen_cnt : for i in G_COMP_INST downto 1 generate
			box_cnt : entity work.box_counter
			port map(
				clk_in            => clk_in,
				rst_in            => comp_rst_s(i),
				restart_in        => comp_restart_s(i),
				last_box_in       => comp_last_s(i),
				box2_valid_in     => comp_box2_vl_s(i),
				count_out					=> cnt_lbl_s(i)
			);
		end generate gen_cnt;

		--! @brief sumes up all counted labels over all ref instances
		--! the value output value is only updated every G_COMP_INST clock cycle
		p_cnt_add : process(clk_in, rst_in) is
		begin
			if rst_in = '1' then
				cnt_add_ptr_s <= (others => '0');
				counter_s <= (others => '0');
			elsif rst_in = '0' and rising_edge(clk_in) then

				if cnt_add_ptr_s = 0 then
					counter_s <= cnt_lbl_s(1);
					counter_out <= counter_s;
				else
					counter_s <= counter_s + cnt_lbl_s(to_integer(cnt_add_ptr_s) + 1);
				end if;

				cnt_add_ptr_s <= cnt_add_ptr_s + 1;
				if cnt_add_ptr_s = G_COMP_INST-1 then
					cnt_add_ptr_s <= (others => '0');
				end if;
			end if;
		end process;
	end generate gen_cnt_en;

end architecture verificator_arc;


