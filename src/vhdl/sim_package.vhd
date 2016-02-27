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
--! @file sim_package.vhd
--! @brief this is a package witch supplies functions for simplification of testbench building
--! @author Benjamin Bässler
--! @email ccl@xunit.de
--! @date 2013-06-12
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pbm_package is

	--! defines the possible maximum width of images 
	constant C_MAX_WIDTH  : natural := 6000;

	--! defines the possible maximum height of images 
	constant C_MAX_HEIGHT : natural := 6000;

	type line_type is array (1 to C_MAX_WIDTH) of std_logic;
	type image_type is array (1 to C_MAX_HEIGHT) of line_type;

	type image_file_type is file of character;
	type T_LINE is array(1 to 100) of character;

	procedure read_line(file pbm_file : image_file_type; line_in : inout T_LINE; length : inout natural);
	function line2str(l : T_LINE; length : natural) return string;

	impure function read_natural (file pbm_file : image_file_type) return natural;

	procedure read_pbm(constant filename  : in string;
	  variable image     : out image_type;
	  variable width     : out positive;
	  variable height    : out positive
	);


end package pbm_package;

package body pbm_package is

	file pbm_file : image_file_type;

	type input_type is (RAW, ASCII);

	procedure read_line(file pbm_file : image_file_type; line_in : inout T_LINE; length : inout natural) 
	is
		variable c : character := ' ';
	begin
		length := 0;
		while not endfile(pbm_file) and (length = 0 or (length > 0 and c /= LF)) loop
			read(pbm_file, c);

			-- ignore control characters
			if character'pos(c) > 30 then
				length := length + 1;
				line_in(length) := c;
			end if;
		end loop;
	end procedure read_line;

	function line2str(l : T_LINE; length : natural) return string
	is
		variable s : string(1 to length);
	begin
		for i in s'range loop
			s(i) := l (i);
		end loop;
		return s;
	end function line2str;

	--! Read the next natural ignore comments and white space
	impure function read_natural (file pbm_file : image_file_type) return natural
	is
		variable value    : natural;
		variable s_val    : string (1 to 70);
		variable s_pos    : natural;
		variable comment  : boolean;
		variable done     : boolean;
		variable char     : character;
		variable tmp      : natural;
	begin

		s_val := (others => nul);
		s_pos := 0;
		comment := false;
		done := false;
		value := 0;

		while not endfile(pbm_file) and not done loop
			read(pbm_file, char);

			if comment = false then

				if char = '#' and s_pos = 0 then
					-- this is the start of a comment
					comment := true;

				elsif character'pos(char) >= character'pos('0') and character'pos(char) <= character'pos('9') then
					s_pos := s_pos + 1;
					s_val(s_pos) := char;

				elsif s_pos /= 0 then
					done := true;

				end if;
			elsif char = lf then
				-- comment ends by line feed
				comment := false;
			end if;
		end loop;

		if s_pos > 0 then
			-- convert string to natural
			for i in s_pos downto 1 loop
				tmp := character'pos(s_val(i))-character'pos('0');
				value := value + (character'pos(s_val(i))-character'pos('0')) * (10**(s_pos - i));
			end loop;
		else
			report "no Natural found in file" severity failure;
		end if;

		return value;
	end function read_natural;

	--! Read the next character as raw value and return as natural
	procedure read_raw (variable n : out natural)
	is
		variable char     : character;
	begin
		read(pbm_file, char);
		n := character'pos(char);
	end procedure read_raw;

	--! Read the next value as hex ignore comments and white space
	procedure read_hex (variable n : out natural)
	is
		variable value    : natural;
		variable s_val    : string (1 to 70);
		variable s_pos    : natural;
		variable comment  : boolean;
		variable done     : boolean;
		variable char     : character;
		variable par_val  : natural;
	begin

		s_val := (others => nul);
		s_pos := 0;
		comment := false;
		done := false;
		value := 0;

		while not endfile(pbm_file) and not done loop
			read(pbm_file, char);

			if comment = false then

				if char = '#' and s_pos = 0 then
					-- this is the start of a comment
					comment := true;

				elsif (character'pos(char) >= character'pos('0') and character'pos(char) <= character'pos('9')) or
				(character'pos(char) >= character'pos('a') and character'pos(char) <= character'pos('f')) or
				(character'pos(char) >= character'pos('A') and character'pos(char) <= character'pos('F'))
				then
					s_pos := s_pos + 1;
					s_val(s_pos) := char;

				elsif s_pos /= 0 then
					done := true;

				end if;
			elsif char = lf then
				-- comment ends by line feed
				comment := false;
			end if;
		end loop;

		if s_pos > 0 then
			-- convert string to natural
			for i in s_pos downto 1 loop
				if character'pos(s_val(i)) >= character'pos('0') and character'pos(s_val(i)) <= character'pos('9') then
					par_val := character'pos(s_val(i)) - character'pos('0');
				elsif s_val(i) = 'a' or s_val(i) = 'A' then
					par_val := 10;
				elsif s_val(i) = 'b' or s_val(i) = 'B' then
					par_val := 11;
				elsif s_val(i) = 'c' or s_val(i) = 'C' then
					par_val := 12;
				elsif s_val(i) = 'd' or s_val(i) = 'D' then
					par_val := 13;
				elsif s_val(i) = 'e' or s_val(i) = 'E' then
					par_val := 14;
				elsif s_val(i) = 'f' or s_val(i) = 'F' then
					par_val := 15;
				end if;

				value := value + par_val * (16**(s_pos - i));
			end loop;
		else
			report "no Natural found in file" severity failure;
		end if;

		n := value;
	end procedure read_hex;





	--! Open the image and read file to buffer
	procedure read_pbm(constant filename  : in string;
										 variable image     : out image_type;
										 variable width     : out positive;
										 variable height    : out positive)
										 is
											 variable char         : character;
											 variable len          : natural;
											 variable v_width      : natural;
											 variable v_height     : natural;
											 variable pos_x        : positive;
											 variable pos_y        : positive;
											 variable pixel        : std_ulogic;
											 variable file_type    : input_type;
											 variable read_v       : natural;
											 variable byte         : unsigned (7 downto 0);
											 variable start_y      : natural;
	begin

		file_open(pbm_file, filename, read_mode);

		-- the first two bits defines the type of the image file P1 means binary and P4 means ASCII values
		read(pbm_file, char);

		assert char = 'P'
		report filename & " is not PBM format" severity failure;

		read(pbm_file, char);
		if char = '1' then
			file_type := ASCII;
		elsif char = '4' then
			file_type := RAW;
		else
		  report "Filetype P" & char & " not supported" severity failure;
		end if;

		-- next should be the width in ASCII decimal
		
		v_width := read_natural(pbm_file);
		width := v_width;

		-- next should be the height in ASCII decimal
		
		v_height := read_natural(pbm_file);
		height := v_height;

		-- header should end by a whitespace (is already read by read_natural)

		assert v_width <= C_MAX_WIDTH
		report "The width of the image is bigger than the max width. Change the constants in the package.";

		assert v_height <= C_MAX_HEIGHT
		report "The height of the image is bigger than the max height. Change the constants in the package";

		-- read the whole image
		pos_x := 1;
		pos_y := 1;

		while not endfile (pbm_file) loop


			if file_type = ASCII then
				assert pos_y <= v_height
				report "There are more pixels than described in the header" severity error;

				read_v := read_natural(pbm_file);
				if read_v = 0 then
					image(pos_y)(pos_x) := '0';
				elsif read_v = 1 then
					image(pos_y)(pos_x) := '1';
				else
					report "pbm inputfile is corrupt" severity error;
				end if;

				if pos_x = v_width then
					pos_x := 1;
					pos_y := pos_y + 1;
				else
					pos_x := pos_x + 1;
				end if;

			elsif file_type = RAW then
				read_raw(read_v);
				byte := to_unsigned(read_v, 8);
				start_y := pos_y;
				for i in byte'range loop
					-- dump fill bits of last char in line
					if start_y = pos_y then
						image(pos_y)(pos_x) := byte(i);

						if pos_x = v_width then
							pos_x := 1;
							pos_y := pos_y + 1;
						else
							pos_x := pos_x + 1;
						end if;
					end if;
				end loop;
			end if;

		end loop;

		-- read is done, close file...
		file_close(pbm_file);

	end procedure read_pbm;


end package body pbm_package;
