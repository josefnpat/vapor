--[[
    The following sequence of bits...
	   ... speak fluent latin.

	You are free to do with them whatever you want.
]]
--[[

	32-bit and 8-bit AND, OR, XOR, NOT, shift and rotate bitwise operations in
	pure Lua. The functions take any integer value in [-2^53, 2^53] and return
	either a 32-bit or 8-bit value. Inputs out of range will give undefined
	results.

	Lookup tables can be generated to improve the perfomance at the cost of
	around 277 KiB of memory.

		bit_lua.band(int1, int2, int3, ...)
		bit_lua.bor(int1, int2, int3, ...)
		bit_lua.bxor(int1, int2, int3, ...)
		bit_lua.bnot(int)
		bit_lua.band8(byte1, byte2, byte3, ...)
		bit_lua.bor8(byte1, byte2, byte3, ...)
		bit_lua.bxor8(byte1, byte2, byte3, ...)
		bit_lua.bnot8(byte)
		bit_lua.lshift(int, by)
		bit_lua.rshift(int, by)
		bit_lua.arshift(int, by)
		bit_lua.lrotate(int, by)
		bit_lua.rrotate(int, by)

	The function bit_lua.lut generates the lookup tables and replaces the band,
	bor, and bxor functions with lookup versions.

		bit_lua.lut()

]]

assert((2^48 + 2) - (2^48 + 1) == 1, "Bitwise operations require Lua to be compiled with double precision.")

local POT_LUT = {}
for i = 0, 32 do
	POT_LUT[i] = 2^i
end
local AND_LUT, OR_LUT, XOR_LUT
local band, bor, bxor
local band8, bor8, bxor8
local lu_band, lu_bor, lu_bxor
local lu_band8, lu_bor8, lu_bxor8


local bit_lua = {
	version = {0, 1, 0},
}


band = function(int1, int2, int3, ...)
	local int = 0

	if int1 %          2 >=          1 and int2 %          2 >=          1 then   int = int +          1   end
	if int1 %          4 >=          2 and int2 %          4 >=          2 then   int = int +          2   end
	if int1 %          8 >=          4 and int2 %          8 >=          4 then   int = int +          4   end
	if int1 %         16 >=          8 and int2 %         16 >=          8 then   int = int +          8   end
	if int1 %         32 >=         16 and int2 %         32 >=         16 then   int = int +         16   end
	if int1 %         64 >=         32 and int2 %         64 >=         32 then   int = int +         32   end
	if int1 %        128 >=         64 and int2 %        128 >=         64 then   int = int +         64   end
	if int1 %        256 >=        128 and int2 %        256 >=        128 then   int = int +        128   end
	if int1 %        512 >=        256 and int2 %        512 >=        256 then   int = int +        256   end
	if int1 %       1024 >=        512 and int2 %       1024 >=        512 then   int = int +        512   end
	if int1 %       2048 >=       1024 and int2 %       2048 >=       1024 then   int = int +       1024   end
	if int1 %       4096 >=       2048 and int2 %       4096 >=       2048 then   int = int +       2048   end
	if int1 %       8192 >=       4096 and int2 %       8192 >=       4096 then   int = int +       4096   end
	if int1 %      16384 >=       8192 and int2 %      16384 >=       8192 then   int = int +       8192   end
	if int1 %      32768 >=      16384 and int2 %      32768 >=      16384 then   int = int +      16384   end
	if int1 %      65536 >=      32768 and int2 %      65536 >=      32768 then   int = int +      32768   end
	if int1 %     131072 >=      65536 and int2 %     131072 >=      65536 then   int = int +      65536   end
	if int1 %     262144 >=     131072 and int2 %     262144 >=     131072 then   int = int +     131072   end
	if int1 %     524288 >=     262144 and int2 %     524288 >=     262144 then   int = int +     262144   end
	if int1 %    1048576 >=     524288 and int2 %    1048576 >=     524288 then   int = int +     524288   end
	if int1 %    2097152 >=    1048576 and int2 %    2097152 >=    1048576 then   int = int +    1048576   end
	if int1 %    4194304 >=    2097152 and int2 %    4194304 >=    2097152 then   int = int +    2097152   end
	if int1 %    8388608 >=    4194304 and int2 %    8388608 >=    4194304 then   int = int +    4194304   end
	if int1 %   16777216 >=    8388608 and int2 %   16777216 >=    8388608 then   int = int +    8388608   end
	if int1 %   33554432 >=   16777216 and int2 %   33554432 >=   16777216 then   int = int +   16777216   end
	if int1 %   67108864 >=   33554432 and int2 %   67108864 >=   33554432 then   int = int +   33554432   end
	if int1 %  134217728 >=   67108864 and int2 %  134217728 >=   67108864 then   int = int +   67108864   end
	if int1 %  268435456 >=  134217728 and int2 %  268435456 >=  134217728 then   int = int +  134217728   end
	if int1 %  536870912 >=  268435456 and int2 %  536870912 >=  268435456 then   int = int +  268435456   end
	if int1 % 1073741824 >=  536870912 and int2 % 1073741824 >=  536870912 then   int = int +  536870912   end
	if int1 % 2147483648 >= 1073741824 and int2 % 2147483648 >= 1073741824 then   int = int + 1073741824   end
	if int1 % 4294967296 >= 2147483648 and int2 % 4294967296 >= 2147483648 then   int = int + 2147483648   end

	if not int3 then
		return int
	end

	return band(int, int3, ...)
end


bor = function(int1, int2, int3, ...)
	local int = 0

	if int1 %          2 >=          1 or int2 %          2 >=          1 then   int = int +          1   end
	if int1 %          4 >=          2 or int2 %          4 >=          2 then   int = int +          2   end
	if int1 %          8 >=          4 or int2 %          8 >=          4 then   int = int +          4   end
	if int1 %         16 >=          8 or int2 %         16 >=          8 then   int = int +          8   end
	if int1 %         32 >=         16 or int2 %         32 >=         16 then   int = int +         16   end
	if int1 %         64 >=         32 or int2 %         64 >=         32 then   int = int +         32   end
	if int1 %        128 >=         64 or int2 %        128 >=         64 then   int = int +         64   end
	if int1 %        256 >=        128 or int2 %        256 >=        128 then   int = int +        128   end
	if int1 %        512 >=        256 or int2 %        512 >=        256 then   int = int +        256   end
	if int1 %       1024 >=        512 or int2 %       1024 >=        512 then   int = int +        512   end
	if int1 %       2048 >=       1024 or int2 %       2048 >=       1024 then   int = int +       1024   end
	if int1 %       4096 >=       2048 or int2 %       4096 >=       2048 then   int = int +       2048   end
	if int1 %       8192 >=       4096 or int2 %       8192 >=       4096 then   int = int +       4096   end
	if int1 %      16384 >=       8192 or int2 %      16384 >=       8192 then   int = int +       8192   end
	if int1 %      32768 >=      16384 or int2 %      32768 >=      16384 then   int = int +      16384   end
	if int1 %      65536 >=      32768 or int2 %      65536 >=      32768 then   int = int +      32768   end
	if int1 %     131072 >=      65536 or int2 %     131072 >=      65536 then   int = int +      65536   end
	if int1 %     262144 >=     131072 or int2 %     262144 >=     131072 then   int = int +     131072   end
	if int1 %     524288 >=     262144 or int2 %     524288 >=     262144 then   int = int +     262144   end
	if int1 %    1048576 >=     524288 or int2 %    1048576 >=     524288 then   int = int +     524288   end
	if int1 %    2097152 >=    1048576 or int2 %    2097152 >=    1048576 then   int = int +    1048576   end
	if int1 %    4194304 >=    2097152 or int2 %    4194304 >=    2097152 then   int = int +    2097152   end
	if int1 %    8388608 >=    4194304 or int2 %    8388608 >=    4194304 then   int = int +    4194304   end
	if int1 %   16777216 >=    8388608 or int2 %   16777216 >=    8388608 then   int = int +    8388608   end
	if int1 %   33554432 >=   16777216 or int2 %   33554432 >=   16777216 then   int = int +   16777216   end
	if int1 %   67108864 >=   33554432 or int2 %   67108864 >=   33554432 then   int = int +   33554432   end
	if int1 %  134217728 >=   67108864 or int2 %  134217728 >=   67108864 then   int = int +   67108864   end
	if int1 %  268435456 >=  134217728 or int2 %  268435456 >=  134217728 then   int = int +  134217728   end
	if int1 %  536870912 >=  268435456 or int2 %  536870912 >=  268435456 then   int = int +  268435456   end
	if int1 % 1073741824 >=  536870912 or int2 % 1073741824 >=  536870912 then   int = int +  536870912   end
	if int1 % 2147483648 >= 1073741824 or int2 % 2147483648 >= 1073741824 then   int = int + 1073741824   end
	if int1 % 4294967296 >= 2147483648 or int2 % 4294967296 >= 2147483648 then   int = int + 2147483648   end

	if not int3 then
		return int
	end

	return bor(int, int3, ...)
end


bxor = function(int1, int2, int3, ...)
	local int = 0

	if (int1 %          2 >=          1) ~= (int2 %          2 >=          1) then   int = int +          1   end
	if (int1 %          4 >=          2) ~= (int2 %          4 >=          2) then   int = int +          2   end
	if (int1 %          8 >=          4) ~= (int2 %          8 >=          4) then   int = int +          4   end
	if (int1 %         16 >=          8) ~= (int2 %         16 >=          8) then   int = int +          8   end
	if (int1 %         32 >=         16) ~= (int2 %         32 >=         16) then   int = int +         16   end
	if (int1 %         64 >=         32) ~= (int2 %         64 >=         32) then   int = int +         32   end
	if (int1 %        128 >=         64) ~= (int2 %        128 >=         64) then   int = int +         64   end
	if (int1 %        256 >=        128) ~= (int2 %        256 >=        128) then   int = int +        128   end
	if (int1 %        512 >=        256) ~= (int2 %        512 >=        256) then   int = int +        256   end
	if (int1 %       1024 >=        512) ~= (int2 %       1024 >=        512) then   int = int +        512   end
	if (int1 %       2048 >=       1024) ~= (int2 %       2048 >=       1024) then   int = int +       1024   end
	if (int1 %       4096 >=       2048) ~= (int2 %       4096 >=       2048) then   int = int +       2048   end
	if (int1 %       8192 >=       4096) ~= (int2 %       8192 >=       4096) then   int = int +       4096   end
	if (int1 %      16384 >=       8192) ~= (int2 %      16384 >=       8192) then   int = int +       8192   end
	if (int1 %      32768 >=      16384) ~= (int2 %      32768 >=      16384) then   int = int +      16384   end
	if (int1 %      65536 >=      32768) ~= (int2 %      65536 >=      32768) then   int = int +      32768   end
	if (int1 %     131072 >=      65536) ~= (int2 %     131072 >=      65536) then   int = int +      65536   end
	if (int1 %     262144 >=     131072) ~= (int2 %     262144 >=     131072) then   int = int +     131072   end
	if (int1 %     524288 >=     262144) ~= (int2 %     524288 >=     262144) then   int = int +     262144   end
	if (int1 %    1048576 >=     524288) ~= (int2 %    1048576 >=     524288) then   int = int +     524288   end
	if (int1 %    2097152 >=    1048576) ~= (int2 %    2097152 >=    1048576) then   int = int +    1048576   end
	if (int1 %    4194304 >=    2097152) ~= (int2 %    4194304 >=    2097152) then   int = int +    2097152   end
	if (int1 %    8388608 >=    4194304) ~= (int2 %    8388608 >=    4194304) then   int = int +    4194304   end
	if (int1 %   16777216 >=    8388608) ~= (int2 %   16777216 >=    8388608) then   int = int +    8388608   end
	if (int1 %   33554432 >=   16777216) ~= (int2 %   33554432 >=   16777216) then   int = int +   16777216   end
	if (int1 %   67108864 >=   33554432) ~= (int2 %   67108864 >=   33554432) then   int = int +   33554432   end
	if (int1 %  134217728 >=   67108864) ~= (int2 %  134217728 >=   67108864) then   int = int +   67108864   end
	if (int1 %  268435456 >=  134217728) ~= (int2 %  268435456 >=  134217728) then   int = int +  134217728   end
	if (int1 %  536870912 >=  268435456) ~= (int2 %  536870912 >=  268435456) then   int = int +  268435456   end
	if (int1 % 1073741824 >=  536870912) ~= (int2 % 1073741824 >=  536870912) then   int = int +  536870912   end
	if (int1 % 2147483648 >= 1073741824) ~= (int2 % 2147483648 >= 1073741824) then   int = int + 1073741824   end
	if (int1 % 4294967296 >= 2147483648) ~= (int2 % 4294967296 >= 2147483648) then   int = int + 2147483648   end

	if not int3 then
		return int
	end

	return bxor(int, int3, ...)
end


band8 = function(byte1, byte2, byte3, ...)
	local byte = 0

	if byte1 %   2 >=   1 and byte2 %   2 >=   1 then   byte = byte +   1  end
	if byte1 %   4 >=   2 and byte2 %   4 >=   2 then   byte = byte +   2  end
	if byte1 %   8 >=   4 and byte2 %   8 >=   4 then   byte = byte +   4  end
	if byte1 %  16 >=   8 and byte2 %  16 >=   8 then   byte = byte +   8  end
	if byte1 %  32 >=  16 and byte2 %  32 >=  16 then   byte = byte +  16  end
	if byte1 %  64 >=  32 and byte2 %  64 >=  32 then   byte = byte +  32  end
	if byte1 % 128 >=  64 and byte2 % 128 >=  64 then   byte = byte +  64  end
	if byte1 % 256 >= 128 and byte2 % 256 >= 128 then   byte = byte + 128  end

	if not byte3 then
		return byte
	end

	return band8(byte, byte3, ...)
end

bor8 = function(byte1, byte2, byte3, ...)
	local byte = 0

	if byte1 %   2 >=   1 or byte2 %   2 >=   1 then   byte = byte +   1  end
	if byte1 %   4 >=   2 or byte2 %   4 >=   2 then   byte = byte +   2  end
	if byte1 %   8 >=   4 or byte2 %   8 >=   4 then   byte = byte +   4  end
	if byte1 %  16 >=   8 or byte2 %  16 >=   8 then   byte = byte +   8  end
	if byte1 %  32 >=  16 or byte2 %  32 >=  16 then   byte = byte +  16  end
	if byte1 %  64 >=  32 or byte2 %  64 >=  32 then   byte = byte +  32  end
	if byte1 % 128 >=  64 or byte2 % 128 >=  64 then   byte = byte +  64  end
	if byte1 % 256 >= 128 or byte2 % 256 >= 128 then   byte = byte + 128  end

	if not byte3 then
		return byte
	end

	return bor8(byte, byte3, ...)
end

bxor8 = function(byte1, byte2, byte3, ...)
	local byte, b1, b2 = 0

	if (byte1 %   2 >=   1) ~= (byte2 %   2 >=   1) then   byte = byte +   1  end
	if (byte1 %   4 >=   2) ~= (byte2 %   4 >=   2) then   byte = byte +   2  end
	if (byte1 %   8 >=   4) ~= (byte2 %   8 >=   4) then   byte = byte +   4  end
	if (byte1 %  16 >=   8) ~= (byte2 %  16 >=   8) then   byte = byte +   8  end
	if (byte1 %  32 >=  16) ~= (byte2 %  32 >=  16) then   byte = byte +  16  end
	if (byte1 %  64 >=  32) ~= (byte2 %  64 >=  32) then   byte = byte +  32  end
	if (byte1 % 128 >=  64) ~= (byte2 % 128 >=  64) then   byte = byte +  64  end
	if (byte1 % 256 >= 128) ~= (byte2 % 256 >= 128) then   byte = byte + 128  end

	if not byte3 then
		return byte
	end

	return bxor8(byte, byte3, ...)
end

lu_band = function(int1, int2, int3, ...)
	local a1 = int1 % 256
	int1 = (int1 - a1) / 256
	local a2 = int1 % 256
	int1 = (int1 - a2) / 256
	local a3 = int1 % 256
	int1 = (int1 - a3) / 256
	local a4 = int1 % 256

	local b1 = int2 % 256
	int2 = (int2 - b1) / 256
	local b2 = int2 % 256
	int2 = (int2 - b2) / 256
	local b3 = int2 % 256
	int2 = (int2 - b3) / 256
	local b4 = int2 % 256

	local ret = AND_LUT[a1][b1] + AND_LUT[a2][b2] * 256 + AND_LUT[a3][b3] * 65536 + AND_LUT[a4][b4] * 16777216

	if not int3 then
		return ret
	end

	return lu_band(ret, int3, ...)
end

lu_bor = function(int1, int2, int3, ...)
	local a1 = int1 % 256
	int1 = (int1 - a1) / 256
	local a2 = int1 % 256
	int1 = (int1 - a2) / 256
	local a3 = int1 % 256
	int1 = (int1 - a3) / 256
	local a4 = int1 % 256

	local b1 = int2 % 256
	int2 = (int2 - b1) / 256
	local b2 = int2 % 256
	int2 = (int2 - b2) / 256
	local b3 = int2 % 256
	int2 = (int2 - b3) / 256
	local b4 = int2 % 256

	local ret = OR_LUT[a1][b1] + OR_LUT[a2][b2] * 256 + OR_LUT[a3][b3] * 65536 + OR_LUT[a4][b4] * 16777216

	if not int3 then
		return ret
	end

	return lu_bor(ret, int3, ...)
end

lu_bxor = function(int1, int2, int3, ...)
	local a1 = int1 % 256
	int1 = (int1 - a1) / 256
	local a2 = int1 % 256
	int1 = (int1 - a2) / 256
	local a3 = int1 % 256
	int1 = (int1 - a3) / 256
	local a4 = int1 % 256

	local b1 = int2 % 256
	int2 = (int2 - b1) / 256
	local b2 = int2 % 256
	int2 = (int2 - b2) / 256
	local b3 = int2 % 256
	int2 = (int2 - b3) / 256
	local b4 = int2 % 256

	local ret = XOR_LUT[a1][b1] + XOR_LUT[a2][b2] * 256 + XOR_LUT[a3][b3] * 65536 + XOR_LUT[a4][b4] * 16777216

	if not int3 then
		return ret
	end

	return lu_bxor(ret, int3, ...)
end

lu_band8 = function(byte1, byte2, byte3, ...)
	byte2 = AND_LUT[byte1 % 256][byte2 % 256]

	if not byte3 then
		return byte2
	end

	return lu_band8(byte2, byte3, ...)
end

lu_bor8 = function(byte1, byte2, byte3, ...)
	byte2 = OR_LUT[byte1 % 256][byte2 % 256]

	if not byte3 then
		return byte2
	end

	return lu_bor8(byte2, byte3, ...)
end

lu_bxor8 = function(byte1, byte2, byte3, ...)
	byte2 = XOR_LUT[byte1 % 256][byte2 % 256]

	if not byte3 then
		return byte2
	end

	return lu_bxor8(byte2, byte3, ...)
end

bit_lua.bnot = function(int)
	return 4294967295 - int % 4294967296
end

bit_lua.bnot8 = function(byte)
	return 255 - byte % 256
end


bit_lua.lshift = function(int, by)
	return (int % 4294967296 * POT_LUT[by]) % 4294967296
end

bit_lua.rshift = function(int, by)
	local shifted = int % 4294967296 / POT_LUT[by]
	return shifted - shifted % 1
end

bit_lua.arshift = function(int, by)
	int = int % 4294967296
	local pf = POT_LUT[by]
	local shifted = int / pf
	shifted = shifted - shifted % 1
	if int >= 2147483648 then
		return shifted + (pf - 1) * POT_LUT[32 - by]
	end
	return shifted
end


bit_lua.lrotate = function(int, by)
	local shifted = int % 4294967296 / POT_LUT[32 - by]
	local fraction = shifted % 1
	return (shifted - fraction) + fraction * 4294967296
end

bit_lua.rrotate = function(int, by)
	local shifted = int % 4294967296 / POT_LUT[by]
	local fraction = shifted % 1
	return (shifted - fraction) + fraction * 4294967296
end


local function generate_lookup_tables()
	if AND_LUT and OR_LUT and XOR_LUT then
		return
	end

	AND_LUT, OR_LUT, XOR_LUT = {}, {}, {}

	for b1 = 0, 255 do
		AND_LUT[b1], OR_LUT[b1], XOR_LUT[b1] = {}, {}, {}

		for b2 = 0, 255 do
			AND_LUT[b1][b2] = band8(b1, b2)
			OR_LUT[b1][b2] = bor8(b1, b2)
			XOR_LUT[b1][b2] = bxor8(b1, b2)
		end
	end
end

bit_lua.lut = function()
	generate_lookup_tables()

	bit_lua.band = lu_band
	bit_lua.bor = lu_bor
	bit_lua.bxor = lu_bxor

	bit_lua.band8 = lu_band8
	bit_lua.bor8 = lu_bor8
	bit_lua.bxor8 = lu_bxor8
end


bit_lua.band = band
bit_lua.bor = bor
bit_lua.bxor = bxor

bit_lua.band8 = band8
bit_lua.bor8 = bor8
bit_lua.bxor8 = bxor8


return bit_lua
