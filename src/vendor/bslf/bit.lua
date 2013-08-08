--[[
    The following sequence of bits...
	   ... speak fluent latin.

	You are free to do with them whatever you want.
]]
--[[

	AND, OR, XOR, NOT, shift and rotate bitwise operations in pure lua.
	They assume unsigned 32-bit integers for all parameters. The functions
	with the suffix '8' expect unsigned 8-bit integers.

	The function bit_lua.lut activates the lookup tables. They're increasing
	the speed further at the cost of around 277 KiB of memory.


	Function list:

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

	bit_lua.lut() - Generates lookup tables and replaces the band, bor, and bxor
	                functions with lookup versions.

]]

assert((2^48 + 2) - (2^48 + 1) == 1, "Bitwise operations require Lua to be compiled with double precision.")

local POW31 = 2^31
local POW32 = 2^32
local POT_LUT = {}
for i = 0, 32 do
	POT_LUT[i] = 2^i
end
local AND_LUT, OR_LUT, XOR_LUT
local band, bor, bxor
local band8, bor8, bxor8
local lu_band, lu_bor, lu_bxor
local lu_band8, lu_bor8, lu_bxor8


local bit_lua = {}


band = function(int1, int2, int3, ...)
	local int = 0

	if int1 % 0x00000002 >= 0x00000001 and int2 % 0x00000002 >= 0x00000001 then   int = int + 0x00000001   end
	if int1 % 0x00000004 >= 0x00000002 and int2 % 0x00000004 >= 0x00000002 then   int = int + 0x00000002   end
	if int1 % 0x00000008 >= 0x00000004 and int2 % 0x00000008 >= 0x00000004 then   int = int + 0x00000004   end
	if int1 % 0x00000010 >= 0x00000008 and int2 % 0x00000010 >= 0x00000008 then   int = int + 0x00000008   end
	if int1 % 0x00000020 >= 0x00000010 and int2 % 0x00000020 >= 0x00000010 then   int = int + 0x00000010   end
	if int1 % 0x00000040 >= 0x00000020 and int2 % 0x00000040 >= 0x00000020 then   int = int + 0x00000020   end
	if int1 % 0x00000080 >= 0x00000040 and int2 % 0x00000080 >= 0x00000040 then   int = int + 0x00000040   end
	if int1 % 0x00000100 >= 0x00000080 and int2 % 0x00000100 >= 0x00000080 then   int = int + 0x00000080   end
	if int1 % 0x00000200 >= 0x00000100 and int2 % 0x00000200 >= 0x00000100 then   int = int + 0x00000100   end
	if int1 % 0x00000400 >= 0x00000200 and int2 % 0x00000400 >= 0x00000200 then   int = int + 0x00000200   end
	if int1 % 0x00000800 >= 0x00000400 and int2 % 0x00000800 >= 0x00000400 then   int = int + 0x00000400   end
	if int1 % 0x00001000 >= 0x00000800 and int2 % 0x00001000 >= 0x00000800 then   int = int + 0x00000800   end
	if int1 % 0x00002000 >= 0x00001000 and int2 % 0x00002000 >= 0x00001000 then   int = int + 0x00001000   end
	if int1 % 0x00004000 >= 0x00002000 and int2 % 0x00004000 >= 0x00002000 then   int = int + 0x00002000   end
	if int1 % 0x00008000 >= 0x00004000 and int2 % 0x00008000 >= 0x00004000 then   int = int + 0x00004000   end
	if int1 % 0x00010000 >= 0x00008000 and int2 % 0x00010000 >= 0x00008000 then   int = int + 0x00008000   end
	if int1 % 0x00020000 >= 0x00010000 and int2 % 0x00020000 >= 0x00010000 then   int = int + 0x00010000   end
	if int1 % 0x00040000 >= 0x00020000 and int2 % 0x00040000 >= 0x00020000 then   int = int + 0x00020000   end
	if int1 % 0x00080000 >= 0x00040000 and int2 % 0x00080000 >= 0x00040000 then   int = int + 0x00040000   end
	if int1 % 0x00100000 >= 0x00080000 and int2 % 0x00100000 >= 0x00080000 then   int = int + 0x00080000   end
	if int1 % 0x00200000 >= 0x00100000 and int2 % 0x00200000 >= 0x00100000 then   int = int + 0x00100000   end
	if int1 % 0x00400000 >= 0x00200000 and int2 % 0x00400000 >= 0x00200000 then   int = int + 0x00200000   end
	if int1 % 0x00800000 >= 0x00400000 and int2 % 0x00800000 >= 0x00400000 then   int = int + 0x00400000   end
	if int1 % 0x01000000 >= 0x00800000 and int2 % 0x01000000 >= 0x00800000 then   int = int + 0x00800000   end
	if int1 % 0x02000000 >= 0x01000000 and int2 % 0x02000000 >= 0x01000000 then   int = int + 0x01000000   end
	if int1 % 0x04000000 >= 0x02000000 and int2 % 0x04000000 >= 0x02000000 then   int = int + 0x02000000   end
	if int1 % 0x08000000 >= 0x04000000 and int2 % 0x08000000 >= 0x04000000 then   int = int + 0x04000000   end
	if int1 % 0x10000000 >= 0x08000000 and int2 % 0x10000000 >= 0x08000000 then   int = int + 0x08000000   end
	if int1 % 0x20000000 >= 0x10000000 and int2 % 0x20000000 >= 0x10000000 then   int = int + 0x10000000   end
	if int1 % 0x40000000 >= 0x20000000 and int2 % 0x40000000 >= 0x20000000 then   int = int + 0x20000000   end
	if int1 % 0x80000000 >= 0x40000000 and int2 % 0x80000000 >= 0x40000000 then   int = int + 0x40000000   end
	if int1              >= 0x80000000 and int2              >= 0x80000000 then   int = int + 0x80000000   end

	if not int3 then
		return int
	end

	return band(int, int3, ...)
end


bor = function(int1, int2, int3, ...)
	local int = 0

	if int1 % 0x00000002 >= 0x00000001 or int2 % 0x00000002 >= 0x00000001 then   int = int + 0x00000001   end
	if int1 % 0x00000004 >= 0x00000002 or int2 % 0x00000004 >= 0x00000002 then   int = int + 0x00000002   end
	if int1 % 0x00000008 >= 0x00000004 or int2 % 0x00000008 >= 0x00000004 then   int = int + 0x00000004   end
	if int1 % 0x00000010 >= 0x00000008 or int2 % 0x00000010 >= 0x00000008 then   int = int + 0x00000008   end
	if int1 % 0x00000020 >= 0x00000010 or int2 % 0x00000020 >= 0x00000010 then   int = int + 0x00000010   end
	if int1 % 0x00000040 >= 0x00000020 or int2 % 0x00000040 >= 0x00000020 then   int = int + 0x00000020   end
	if int1 % 0x00000080 >= 0x00000040 or int2 % 0x00000080 >= 0x00000040 then   int = int + 0x00000040   end
	if int1 % 0x00000100 >= 0x00000080 or int2 % 0x00000100 >= 0x00000080 then   int = int + 0x00000080   end
	if int1 % 0x00000200 >= 0x00000100 or int2 % 0x00000200 >= 0x00000100 then   int = int + 0x00000100   end
	if int1 % 0x00000400 >= 0x00000200 or int2 % 0x00000400 >= 0x00000200 then   int = int + 0x00000200   end
	if int1 % 0x00000800 >= 0x00000400 or int2 % 0x00000800 >= 0x00000400 then   int = int + 0x00000400   end
	if int1 % 0x00001000 >= 0x00000800 or int2 % 0x00001000 >= 0x00000800 then   int = int + 0x00000800   end
	if int1 % 0x00002000 >= 0x00001000 or int2 % 0x00002000 >= 0x00001000 then   int = int + 0x00001000   end
	if int1 % 0x00004000 >= 0x00002000 or int2 % 0x00004000 >= 0x00002000 then   int = int + 0x00002000   end
	if int1 % 0x00008000 >= 0x00004000 or int2 % 0x00008000 >= 0x00004000 then   int = int + 0x00004000   end
	if int1 % 0x00010000 >= 0x00008000 or int2 % 0x00010000 >= 0x00008000 then   int = int + 0x00008000   end
	if int1 % 0x00020000 >= 0x00010000 or int2 % 0x00020000 >= 0x00010000 then   int = int + 0x00010000   end
	if int1 % 0x00040000 >= 0x00020000 or int2 % 0x00040000 >= 0x00020000 then   int = int + 0x00020000   end
	if int1 % 0x00080000 >= 0x00040000 or int2 % 0x00080000 >= 0x00040000 then   int = int + 0x00040000   end
	if int1 % 0x00100000 >= 0x00080000 or int2 % 0x00100000 >= 0x00080000 then   int = int + 0x00080000   end
	if int1 % 0x00200000 >= 0x00100000 or int2 % 0x00200000 >= 0x00100000 then   int = int + 0x00100000   end
	if int1 % 0x00400000 >= 0x00200000 or int2 % 0x00400000 >= 0x00200000 then   int = int + 0x00200000   end
	if int1 % 0x00800000 >= 0x00400000 or int2 % 0x00800000 >= 0x00400000 then   int = int + 0x00400000   end
	if int1 % 0x01000000 >= 0x00800000 or int2 % 0x01000000 >= 0x00800000 then   int = int + 0x00800000   end
	if int1 % 0x02000000 >= 0x01000000 or int2 % 0x02000000 >= 0x01000000 then   int = int + 0x01000000   end
	if int1 % 0x04000000 >= 0x02000000 or int2 % 0x04000000 >= 0x02000000 then   int = int + 0x02000000   end
	if int1 % 0x08000000 >= 0x04000000 or int2 % 0x08000000 >= 0x04000000 then   int = int + 0x04000000   end
	if int1 % 0x10000000 >= 0x08000000 or int2 % 0x10000000 >= 0x08000000 then   int = int + 0x08000000   end
	if int1 % 0x20000000 >= 0x10000000 or int2 % 0x20000000 >= 0x10000000 then   int = int + 0x10000000   end
	if int1 % 0x40000000 >= 0x20000000 or int2 % 0x40000000 >= 0x20000000 then   int = int + 0x20000000   end
	if int1 % 0x80000000 >= 0x40000000 or int2 % 0x80000000 >= 0x40000000 then   int = int + 0x40000000   end
	if int1              >= 0x80000000 or int2              >= 0x80000000 then   int = int + 0x80000000   end

	if not int3 then
		return int
	end

	return bor(int, int3, ...)
end


bxor = function(int1, int2, int3, ...)
	local int = 0

	if (int1 % 0x00000002 >= 0x00000001) ~= (int2 % 0x00000002 >= 0x00000001) then   int = int + 0x00000001   end
	if (int1 % 0x00000004 >= 0x00000002) ~= (int2 % 0x00000004 >= 0x00000002) then   int = int + 0x00000002   end
	if (int1 % 0x00000008 >= 0x00000004) ~= (int2 % 0x00000008 >= 0x00000004) then   int = int + 0x00000004   end
	if (int1 % 0x00000010 >= 0x00000008) ~= (int2 % 0x00000010 >= 0x00000008) then   int = int + 0x00000008   end
	if (int1 % 0x00000020 >= 0x00000010) ~= (int2 % 0x00000020 >= 0x00000010) then   int = int + 0x00000010   end
	if (int1 % 0x00000040 >= 0x00000020) ~= (int2 % 0x00000040 >= 0x00000020) then   int = int + 0x00000020   end
	if (int1 % 0x00000080 >= 0x00000040) ~= (int2 % 0x00000080 >= 0x00000040) then   int = int + 0x00000040   end
	if (int1 % 0x00000100 >= 0x00000080) ~= (int2 % 0x00000100 >= 0x00000080) then   int = int + 0x00000080   end
	if (int1 % 0x00000200 >= 0x00000100) ~= (int2 % 0x00000200 >= 0x00000100) then   int = int + 0x00000100   end
	if (int1 % 0x00000400 >= 0x00000200) ~= (int2 % 0x00000400 >= 0x00000200) then   int = int + 0x00000200   end
	if (int1 % 0x00000800 >= 0x00000400) ~= (int2 % 0x00000800 >= 0x00000400) then   int = int + 0x00000400   end
	if (int1 % 0x00001000 >= 0x00000800) ~= (int2 % 0x00001000 >= 0x00000800) then   int = int + 0x00000800   end
	if (int1 % 0x00002000 >= 0x00001000) ~= (int2 % 0x00002000 >= 0x00001000) then   int = int + 0x00001000   end
	if (int1 % 0x00004000 >= 0x00002000) ~= (int2 % 0x00004000 >= 0x00002000) then   int = int + 0x00002000   end
	if (int1 % 0x00008000 >= 0x00004000) ~= (int2 % 0x00008000 >= 0x00004000) then   int = int + 0x00004000   end
	if (int1 % 0x00010000 >= 0x00008000) ~= (int2 % 0x00010000 >= 0x00008000) then   int = int + 0x00008000   end
	if (int1 % 0x00020000 >= 0x00010000) ~= (int2 % 0x00020000 >= 0x00010000) then   int = int + 0x00010000   end
	if (int1 % 0x00040000 >= 0x00020000) ~= (int2 % 0x00040000 >= 0x00020000) then   int = int + 0x00020000   end
	if (int1 % 0x00080000 >= 0x00040000) ~= (int2 % 0x00080000 >= 0x00040000) then   int = int + 0x00040000   end
	if (int1 % 0x00100000 >= 0x00080000) ~= (int2 % 0x00100000 >= 0x00080000) then   int = int + 0x00080000   end
	if (int1 % 0x00200000 >= 0x00100000) ~= (int2 % 0x00200000 >= 0x00100000) then   int = int + 0x00100000   end
	if (int1 % 0x00400000 >= 0x00200000) ~= (int2 % 0x00400000 >= 0x00200000) then   int = int + 0x00200000   end
	if (int1 % 0x00800000 >= 0x00400000) ~= (int2 % 0x00800000 >= 0x00400000) then   int = int + 0x00400000   end
	if (int1 % 0x01000000 >= 0x00800000) ~= (int2 % 0x01000000 >= 0x00800000) then   int = int + 0x00800000   end
	if (int1 % 0x02000000 >= 0x01000000) ~= (int2 % 0x02000000 >= 0x01000000) then   int = int + 0x01000000   end
	if (int1 % 0x04000000 >= 0x02000000) ~= (int2 % 0x04000000 >= 0x02000000) then   int = int + 0x02000000   end
	if (int1 % 0x08000000 >= 0x04000000) ~= (int2 % 0x08000000 >= 0x04000000) then   int = int + 0x04000000   end
	if (int1 % 0x10000000 >= 0x08000000) ~= (int2 % 0x10000000 >= 0x08000000) then   int = int + 0x08000000   end
	if (int1 % 0x20000000 >= 0x10000000) ~= (int2 % 0x20000000 >= 0x10000000) then   int = int + 0x10000000   end
	if (int1 % 0x40000000 >= 0x20000000) ~= (int2 % 0x40000000 >= 0x20000000) then   int = int + 0x20000000   end
	if (int1 % 0x80000000 >= 0x40000000) ~= (int2 % 0x80000000 >= 0x40000000) then   int = int + 0x40000000   end
	if (int1              >= 0x80000000) ~= (int2              >= 0x80000000) then   int = int + 0x80000000   end

	if not int3 then
		return int
	end

	return bxor(int, int3, ...)
end

band8 = function(byte1, byte2, byte3, ...)
	local byte = 0

	if byte1 % 0x02 >= 0x01 and byte2 % 0x02 >= 0x01 then   byte = byte + 0x01   end
	if byte1 % 0x04 >= 0x02 and byte2 % 0x04 >= 0x02 then   byte = byte + 0x02   end
	if byte1 % 0x08 >= 0x04 and byte2 % 0x08 >= 0x04 then   byte = byte + 0x04   end
	if byte1 % 0x10 >= 0x08 and byte2 % 0x10 >= 0x08 then   byte = byte + 0x08   end
	if byte1 % 0x20 >= 0x10 and byte2 % 0x20 >= 0x10 then   byte = byte + 0x10   end
	if byte1 % 0x40 >= 0x20 and byte2 % 0x40 >= 0x20 then   byte = byte + 0x20   end
	if byte1 % 0x80 >= 0x40 and byte2 % 0x80 >= 0x40 then   byte = byte + 0x40   end
	if byte1        >= 0x80 and byte2        >= 0x80 then   byte = byte + 0x80   end

	if not byte3 then
		return byte
	end

	return band8(byte, byte3, ...)
end

bor8 = function(byte1, byte2, byte3, ...)
	local byte = 0

	if byte1 % 0x02 >= 0x01 or byte2 % 0x02 >= 0x01 then   byte = byte + 0x01   end
	if byte1 % 0x04 >= 0x02 or byte2 % 0x04 >= 0x02 then   byte = byte + 0x02   end
	if byte1 % 0x08 >= 0x04 or byte2 % 0x08 >= 0x04 then   byte = byte + 0x04   end
	if byte1 % 0x10 >= 0x08 or byte2 % 0x10 >= 0x08 then   byte = byte + 0x08   end
	if byte1 % 0x20 >= 0x10 or byte2 % 0x20 >= 0x10 then   byte = byte + 0x10   end
	if byte1 % 0x40 >= 0x20 or byte2 % 0x40 >= 0x20 then   byte = byte + 0x20   end
	if byte1 % 0x80 >= 0x40 or byte2 % 0x80 >= 0x40 then   byte = byte + 0x40   end
	if byte1        >= 0x80 or byte2        >= 0x80 then   byte = byte + 0x80   end

	if not byte3 then
		return byte
	end

	return bor8(byte, byte3, ...)
end

bxor8 = function(byte1, byte2, byte3, ...)
	local byte, b1, b2 = 0

	if (byte1 % 0x02 >= 0x01) ~= (byte2 % 0x02 >= 0x01) then   byte = byte + 0x01   end
	if (byte1 % 0x04 >= 0x02) ~= (byte2 % 0x04 >= 0x02) then   byte = byte + 0x02   end
	if (byte1 % 0x08 >= 0x04) ~= (byte2 % 0x08 >= 0x04) then   byte = byte + 0x04   end
	if (byte1 % 0x10 >= 0x08) ~= (byte2 % 0x10 >= 0x08) then   byte = byte + 0x08   end
	if (byte1 % 0x20 >= 0x10) ~= (byte2 % 0x20 >= 0x10) then   byte = byte + 0x10   end
	if (byte1 % 0x40 >= 0x20) ~= (byte2 % 0x40 >= 0x20) then   byte = byte + 0x20   end
	if (byte1 % 0x80 >= 0x40) ~= (byte2 % 0x80 >= 0x40) then   byte = byte + 0x40   end
	if (byte1        >= 0x80) ~= (byte2        >= 0x80) then   byte = byte + 0x80   end

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

	local ret = AND_LUT[a1][b1] + AND_LUT[a2][b2] * 0x100 + AND_LUT[a3][b3] * 0x10000 + AND_LUT[a4][b4] * 0x1000000

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

	local ret = OR_LUT[a1][b1] + OR_LUT[a2][b2] * 0x100 + OR_LUT[a3][b3] * 0x10000 + OR_LUT[a4][b4] * 0x1000000

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

	local ret = XOR_LUT[a1][b1] + XOR_LUT[a2][b2] * 0x100 + XOR_LUT[a3][b3] * 0x10000 + XOR_LUT[a4][b4] * 0x1000000

	if not int3 then
		return ret
	end

	return lu_bxor(ret, int3, ...)
end

lu_band8 = function(byte1, byte2, byte3, ...)
	byte2 = AND_LUT[byte1][byte2]

	if not byte3 then
		return byte2
	end

	return lu_band8(byte2, byte3, ...)
end

lu_bor8 = function(byte1, byte2, byte3, ...)
	byte2 = OR_LUT[byte1][byte2]

	if not byte3 then
		return byte2
	end

	return lu_bor8(byte2, byte3, ...)
end

lu_bxor8 = function(byte1, byte2, byte3, ...)
	byte2 = XOR_LUT[byte1][byte2]

	if not byte3 then
		return byte2
	end

	return lu_bxor8(byte2, byte3, ...)
end

bit_lua.bnot = function(int)
	return 4294967295 - int
end

bit_lua.bnot8 = function(byte)
	return 255 - byte
end


bit_lua.lshift = function(int, by)
	return (int * POT_LUT[by]) % POW32
end

bit_lua.rshift = function(int, by)
	local shifted = int / POT_LUT[by]
	return shifted - shifted % 1
end

bit_lua.arshift = function(int, by)
	local pf = POT_LUT[by]
	local shifted = int / pf
	return shifted - shifted % 1 + ((int >= POW31 and (pf - 1) * POT_LUT[32-by]) or 0)
end


bit_lua.lrotate = function(int, by)
	local shifted = int / POT_LUT[32-by]
	local fraction = shifted % 1
	return (shifted - fraction) + fraction * POW32
end

bit_lua.rrotate = function(int, by)
	local shifted = int / POT_LUT[by]
	local fraction = shifted % 1
	return (shifted - fraction) + fraction * POW32
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
