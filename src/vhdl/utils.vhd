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
--! @file utils.vhd
--! @brief often used procedures and functions
--! @author Benjamin Bässler
--! @email ccl@xunit.de
--! @date 2013-08-12
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

package utils is

	--! calculates the log2 and ceil the result
	--! @param val value to calculate log2
	--! @return log2 of val and round to the next integer bigger or equals the exact result
	function log2_ceil (val : natural) return natural;


	--! divides val1/val2
	--! @param val1 dividend
	--! @param val2 divider
	--! @return the result of division rount to next integer bigger or equals the exact result
	function div_ceil (val1 : natural; val2 : natural) return natural;

end package utils;

package body utils is
	function log2_ceil (val : natural) return natural is
	begin
		if val = 0 then
			assert false report "Value log2(0) is -infinity" severity failure; return 0; -- some tools complain if no return value is present 
		elsif val <= 2 then
			return 1; 
		else
			if val mod 2 = 0 then
				return 1 + log2_ceil(val/2); 
			else
				return 1 + log2_ceil(val/2+1); 
			end if; 
		end if; 	
	end function log2_ceil;


	function div_ceil (val1 : natural; val2 : natural) return natural is
	begin
		return natural(ceil(real(val1)/real(val2)));
	end function div_ceil;



--function log2_ceil (val : natural) return natural is
--	variable tmp : real := real(val);
--	variable res : natural = 0;
--begin
--	while tmp >= 1.0 loop
--		tmp := tmp / 2;
--		res := res + 1;
--	end loop;

--	if 2**res < val then
--		return res + 1;
--	else
--		return res;
--	end if;
--end function log2_ceil;
end package body utils;


