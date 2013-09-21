--[[
	The following sequence of bits...
	   ... were aligned by a cosmic ray.

	You are free to do with them whatever you want.
]]
--[[

	CRC-32, MD5, SHA-1 and SHA-256 in pure Lua.

	The functions crc32, md5, sha1, and sha256 return hash objects.

		hash.crc32()
		hash.md5()
		hash.sha1()
		hash.sha256()

	The hash objects have two functions to generate the hash sum. The process
	function takes the input data and the finish function finalizes the
	calculation and returns the hash sum as a string. The hash object can not be
	reset at this time.

		obj:process(string)
		obj:finish()

	Usage example.

		hash = require("hash")

		my_md5 = hash.md5()

		my_md5:process("The quick brown fox ")
		my_md5:process("jumps over the lazy dog")

		md5_hash = my_md5:finish() -- "9e107d9d372bb6826bd81d3542a419d6"


	Random performance table! Measured with a i7 920 at 3 GHz.

	         |  Lua 5.1     Lua 5.1*    Lua 5.2    LuaJIT 2.0.2
	------------------------------------------------------------
	 CRC-32  | 207 KiB/s   795 KiB/s   3.4 MiB/s   135 MiB/s
	 MD5     | 153 KiB/s   434 KiB/s   1.9 MiB/s    82 MiB/s
	 SHA-1   |  51 KiB/s   195 KiB/s   1.0 MiB/s    49 MiB/s
	 SHA-256 |  23 KiB/s    83 KiB/s   573 KiB/s    46 MiB/s

	* with bit LUT

]]

local floor = math.floor
local strbyte = string.byte
local strchar = string.char
local format = string.format
local min = math.min
local sin = math.sin
local abs = math.abs

-- utils.lua part of https://bitbucket.org/Boolsheet/bslf.
local utils = require("lib.bslf.utils")
local intstr = utils.intstr
local bswap = utils.bswap32


local band, bor, bxor, bxor8, bnot, rshift, arshift, lshift, rrotate, lrotate

if bit32 then
	-- If present, use Lua 5.2 native bitwise functions
	band = bit32.band
	bor = bit32.bor
	bxor = bit32.bxor
	bxor8 = bit32.bxor
	bnot = bit32.bnot

	rshift = bit32.rshift
	arshift = bit32.arshift
	lshift = bit32.lshift
	rrotate = bit32.rrotate
	lrotate = bit32.lrotate
elseif bit and bit.band then
	-- or BitOp functions.
	band = bit.band
	bor = bit.bor
	bxor = bit.bxor
	bxor8 = bit.bxor
	bnot = bit.bnot

	rshift = bit.rshift
	arshift = bit.arshift
	lshift = bit.lshift
	rrotate = bit.ror
	lrotate = bit.rol
else
	-- Pure Lua bitwise functions part of https://bitbucket.org/Boolsheet/bslf.
	local bit_lua = require("lib.bslf.bit")

	band = bit_lua.band
	bor = bit_lua.bor
	bxor = bit_lua.bxor
	bxor8 = bit_lua.bxor8
	bnot = bit_lua.bnot

	rshift = bit_lua.rshift
	arshift = bit_lua.arshift
	lshift = bit_lua.lshift
	rrotate = bit_lua.rrotate
	lrotate = bit_lua.lrotate
end


local hash = {}


------------
-- CRC-32
------------

local CRC32_POLY = 0xEDB88320 -- normal: 0x04C11DB7
local CRC32_LUT = {}

for byte = 0, 255 do
	local lv = byte
	for i = 1, 8 do
		local lsb = lv % 2
		lv = rshift(lv, 1)
		if lsb == 1 then
			lv = bxor(lv, CRC32_POLY)
		end
	end
	CRC32_LUT[byte] = lv % 4294967296
end

hash.crc32 = function(init_value, xor_value)
	return {
		crc = init_value or 0xffffffff,
		xor = xor_value,

		buffer = {},

		process = hash.crc32_process,
		finish = hash.crc32_finish,
	}
end

function hash:crc32_process(data)
	local buf = self.buffer
	local crc = self.crc
	local data_len = #data
	local data_rem = data_len % 16

	for p = 1, data_len - 15, 16 do
		buf[0x01], buf[0x02], buf[0x03], buf[0x04],
		buf[0x05], buf[0x06], buf[0x07], buf[0x08],
		buf[0x09], buf[0x0a], buf[0x0b], buf[0x0c],
		buf[0x0d], buf[0x0e], buf[0x0f], buf[0x10]
		=
		strbyte(data, p, p + 15)

		for i = 1, 16 do
			crc = bxor(CRC32_LUT[bxor8(crc, buf[i]) % 256], rshift(crc, 8))
			-- print(crc)
			-- io.read()
		end
	end

	if data_rem > 0 then
		buf[0x01], buf[0x02], buf[0x03], buf[0x04],
		buf[0x05], buf[0x06], buf[0x07], buf[0x08],
		buf[0x09], buf[0x0a], buf[0x0b], buf[0x0c],
		buf[0x0d], buf[0x0e], buf[0x0f], buf[0x10]
		=
		strbyte(data, data_len - data_rem + 1, -1)

		for i = 1, data_rem do
			crc = bxor(CRC32_LUT[bxor8(crc, buf[i]) % 256], rshift(crc, 8))
		end
	end

	self.crc = crc
end

function hash:crc32_finish()
	if not self.result then
		if self.xor then
			self.crc = bxor(self.crc, self.xor) % 4294967296
		else
			self.crc = bnot(self.crc) % 4294967296
		end

		self.result = format("%08x", self.crc)
	end

	return self.result
end


------------
-- MD5
------------

local MD5_LUT = {
	1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16,
	2,  7, 12,  1,  6, 11, 16,  5, 10, 15,  4,  9, 14,  3,  8, 13,
	6,  9, 12, 15,  2,  5,  8, 11, 14,  1,  4,  7, 10, 13, 16,  3,
	1,  8, 15,  6, 13,  4, 11,  2,  9, 16,  7, 14,  5, 12,  3, 10
}

local MD5_ROTATE_LUT = {
	7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
	5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20,
	4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
	6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21
}

local MD5_SINE_LUT = {
	0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee, 0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
	0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be, 0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
	0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa, 0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
	0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed, 0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
	0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c, 0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
	0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05, 0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
	0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039, 0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
	0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1, 0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391
}

--[[
for i = 1, 64 do
	MD5_SINE_LUT[i] = floor(abs(sin(i))*(2^32))%(2^32)
end
]]


hash.md5 = function()
	return {
		h1 = 0x67452301,
		h2 = 0xefcdab89,
		h3 = 0x98badcfe,
		h4 = 0x10325476,

		buffer = {},
		buffer_index = 1,
		data_length = 0,

		process = hash.md5_process,
		finish = hash.md5_finish,
	}
end

function hash:md5_process(data)
	local data_length = #data
	local buf = self.buffer
	local buf_idx = self.buffer_index
	local data_idx = 1

	local h1, h2, h3, h4 = self.h1, self.h2, self.h3, self.h4

	while data_idx <= data_length do
		local data_needed = 65 - buf_idx
		local bytes_added = min(data_needed, data_length - data_idx + 1)

		buf[buf_idx],      buf[buf_idx+0x01], buf[buf_idx+0x02], buf[buf_idx+0x03],
		buf[buf_idx+0x04], buf[buf_idx+0x05], buf[buf_idx+0x06], buf[buf_idx+0x07],
		buf[buf_idx+0x08], buf[buf_idx+0x09], buf[buf_idx+0x0a], buf[buf_idx+0x0b],
		buf[buf_idx+0x0c], buf[buf_idx+0x0d], buf[buf_idx+0x0e], buf[buf_idx+0x0f],
		buf[buf_idx+0x10], buf[buf_idx+0x11], buf[buf_idx+0x12], buf[buf_idx+0x13],
		buf[buf_idx+0x14], buf[buf_idx+0x15], buf[buf_idx+0x16], buf[buf_idx+0x17],
		buf[buf_idx+0x18], buf[buf_idx+0x19], buf[buf_idx+0x1a], buf[buf_idx+0x1b],
		buf[buf_idx+0x1c], buf[buf_idx+0x1d], buf[buf_idx+0x1e], buf[buf_idx+0x1f],
		buf[buf_idx+0x20], buf[buf_idx+0x21], buf[buf_idx+0x22], buf[buf_idx+0x23],
		buf[buf_idx+0x24], buf[buf_idx+0x25], buf[buf_idx+0x26], buf[buf_idx+0x27],
		buf[buf_idx+0x28], buf[buf_idx+0x29], buf[buf_idx+0x2a], buf[buf_idx+0x2b],
		buf[buf_idx+0x2c], buf[buf_idx+0x2d], buf[buf_idx+0x2e], buf[buf_idx+0x2f],
		buf[buf_idx+0x30], buf[buf_idx+0x31], buf[buf_idx+0x32], buf[buf_idx+0x33],
		buf[buf_idx+0x34], buf[buf_idx+0x35], buf[buf_idx+0x36], buf[buf_idx+0x37],
		buf[buf_idx+0x38], buf[buf_idx+0x39], buf[buf_idx+0x3a], buf[buf_idx+0x3b],
		buf[buf_idx+0x3c], buf[buf_idx+0x3d], buf[buf_idx+0x3e], buf[buf_idx+0x3f]
		=
		strbyte(data, data_idx, data_idx + bytes_added - 1)

		data_idx = data_idx + bytes_added
		buf_idx = buf_idx + bytes_added

		if buf_idx > 64 then
			buf_idx = 1

			buf[0x01], buf[0x02], buf[0x03], buf[0x04],
			buf[0x05], buf[0x06], buf[0x07], buf[0x08],
			buf[0x09], buf[0x0a], buf[0x0b], buf[0x0c],
			buf[0x0d], buf[0x0e], buf[0x0f], buf[0x10]
			=
			buf[0x01] + buf[0x02] * 256 + buf[0x03] * 65536 + buf[0x04] * 16777216,
			buf[0x05] + buf[0x06] * 256 + buf[0x07] * 65536 + buf[0x08] * 16777216,
			buf[0x09] + buf[0x0a] * 256 + buf[0x0b] * 65536 + buf[0x0c] * 16777216,
			buf[0x0d] + buf[0x0e] * 256 + buf[0x0f] * 65536 + buf[0x10] * 16777216,
			buf[0x11] + buf[0x12] * 256 + buf[0x13] * 65536 + buf[0x14] * 16777216,
			buf[0x15] + buf[0x16] * 256 + buf[0x17] * 65536 + buf[0x18] * 16777216,
			buf[0x19] + buf[0x1a] * 256 + buf[0x1b] * 65536 + buf[0x1c] * 16777216,
			buf[0x1d] + buf[0x1e] * 256 + buf[0x1f] * 65536 + buf[0x20] * 16777216,
			buf[0x21] + buf[0x22] * 256 + buf[0x23] * 65536 + buf[0x24] * 16777216,
			buf[0x25] + buf[0x26] * 256 + buf[0x27] * 65536 + buf[0x28] * 16777216,
			buf[0x29] + buf[0x2a] * 256 + buf[0x2b] * 65536 + buf[0x2c] * 16777216,
			buf[0x2d] + buf[0x2e] * 256 + buf[0x2f] * 65536 + buf[0x30] * 16777216,
			buf[0x31] + buf[0x32] * 256 + buf[0x33] * 65536 + buf[0x34] * 16777216,
			buf[0x35] + buf[0x36] * 256 + buf[0x37] * 65536 + buf[0x38] * 16777216,
			buf[0x39] + buf[0x3a] * 256 + buf[0x3b] * 65536 + buf[0x3c] * 16777216,
			buf[0x3d] + buf[0x3e] * 256 + buf[0x3f] * 65536 + buf[0x40] * 16777216


			--
			local a, b, c, d = h1, h2, h3, h4

			for i = 1, 16 do
				a, b, c, d = d, lrotate(a + MD5_SINE_LUT[i] + buf[MD5_LUT[i]] + bor(band(b, c), band((0xffffffff - b), d)), MD5_ROTATE_LUT[i]) + b, b, c
			end
			for i = 17, 32 do
				a, b, c, d = d, lrotate(a + MD5_SINE_LUT[i] + buf[MD5_LUT[i]] + bor(band(b, d), band((0xffffffff - d), c)), MD5_ROTATE_LUT[i]) + b, b, c
			end
			for i = 33, 48 do
				a, b, c, d = d, lrotate(a + MD5_SINE_LUT[i] + buf[MD5_LUT[i]] + bxor(b, c, d), MD5_ROTATE_LUT[i]) + b, b, c
			end
			for i = 49, 64 do
				a, b, c, d = d, lrotate(a + MD5_SINE_LUT[i] + buf[MD5_LUT[i]] + bxor(c, bor(b, (0xffffffff - d))), MD5_ROTATE_LUT[i]) + b, b, c
			end

			h1, h2, h3, h4 =
				(h1 + a) % 4294967296, (h2 + b) % 4294967296, (h3 + c) % 4294967296,
				(h4 + d) % 4294967296
		end
	end

	self.buffer_index = buf_idx
	self.data_length = self.data_length + data_length
	self.h1, self.h2, self.h3, self.h4 = h1, h2, h3, h4
end

function hash:md5_finish()
	if not self.result then
		local data_length = self.data_length
		local filler_length = 64 - (data_length + 9) % 64

		self:process("\128"..("\0"):rep(filler_length)..intstr(data_length * 8, 8, false))

		self.data_length = data_length -- Yes, I'm lazy.
		self.result = format("%08x%08x%08x%08x", bswap(self.h1), bswap(self.h2), bswap(self.h3), bswap(self.h4))
	end

	return self.result
end


------------
-- SHA-1
------------

hash.sha1 = function()
	return {
		h1 = 0x67452301,
		h2 = 0xefcdab89,
		h3 = 0x98badcfe,
		h4 = 0x10325476,
		h5 = 0xc3d2e1f0,

		buffer = {},
		buffer_index = 1,
		data_length = 0,

		process = hash.sha1_process,
		finish = hash.sha1_finish,
	}
end

function hash:sha1_process(data)
	local data_length = #data
	local buf = self.buffer
	local buf_idx = self.buffer_index
	local data_idx = 1

	local h1, h2, h3, h4, h5 = self.h1, self.h2, self.h3, self.h4, self.h5

	while data_idx <= data_length do
		local data_needed = 65 - buf_idx
		local bytes_added = min(data_needed, data_length - data_idx + 1)

		buf[buf_idx],      buf[buf_idx+0x01], buf[buf_idx+0x02], buf[buf_idx+0x03],
		buf[buf_idx+0x04], buf[buf_idx+0x05], buf[buf_idx+0x06], buf[buf_idx+0x07],
		buf[buf_idx+0x08], buf[buf_idx+0x09], buf[buf_idx+0x0a], buf[buf_idx+0x0b],
		buf[buf_idx+0x0c], buf[buf_idx+0x0d], buf[buf_idx+0x0e], buf[buf_idx+0x0f],
		buf[buf_idx+0x10], buf[buf_idx+0x11], buf[buf_idx+0x12], buf[buf_idx+0x13],
		buf[buf_idx+0x14], buf[buf_idx+0x15], buf[buf_idx+0x16], buf[buf_idx+0x17],
		buf[buf_idx+0x18], buf[buf_idx+0x19], buf[buf_idx+0x1a], buf[buf_idx+0x1b],
		buf[buf_idx+0x1c], buf[buf_idx+0x1d], buf[buf_idx+0x1e], buf[buf_idx+0x1f],
		buf[buf_idx+0x20], buf[buf_idx+0x21], buf[buf_idx+0x22], buf[buf_idx+0x23],
		buf[buf_idx+0x24], buf[buf_idx+0x25], buf[buf_idx+0x26], buf[buf_idx+0x27],
		buf[buf_idx+0x28], buf[buf_idx+0x29], buf[buf_idx+0x2a], buf[buf_idx+0x2b],
		buf[buf_idx+0x2c], buf[buf_idx+0x2d], buf[buf_idx+0x2e], buf[buf_idx+0x2f],
		buf[buf_idx+0x30], buf[buf_idx+0x31], buf[buf_idx+0x32], buf[buf_idx+0x33],
		buf[buf_idx+0x34], buf[buf_idx+0x35], buf[buf_idx+0x36], buf[buf_idx+0x37],
		buf[buf_idx+0x38], buf[buf_idx+0x39], buf[buf_idx+0x3a], buf[buf_idx+0x3b],
		buf[buf_idx+0x3c], buf[buf_idx+0x3d], buf[buf_idx+0x3e], buf[buf_idx+0x3f]
		=
		strbyte(data, data_idx, data_idx + bytes_added - 1)

		data_idx = data_idx + bytes_added
		buf_idx = buf_idx + bytes_added

		if buf_idx > 64 then
			buf_idx = 1

			buf[0x01], buf[0x02], buf[0x03], buf[0x04],
			buf[0x05], buf[0x06], buf[0x07], buf[0x08],
			buf[0x09], buf[0x0a], buf[0x0b], buf[0x0c],
			buf[0x0d], buf[0x0e], buf[0x0f], buf[0x10]
			=
			buf[0x01] * 16777216 + buf[0x02] * 65536 + buf[0x03] * 256 + buf[0x04],
			buf[0x05] * 16777216 + buf[0x06] * 65536 + buf[0x07] * 256 + buf[0x08],
			buf[0x09] * 16777216 + buf[0x0a] * 65536 + buf[0x0b] * 256 + buf[0x0c],
			buf[0x0d] * 16777216 + buf[0x0e] * 65536 + buf[0x0f] * 256 + buf[0x10],
			buf[0x11] * 16777216 + buf[0x12] * 65536 + buf[0x13] * 256 + buf[0x14],
			buf[0x15] * 16777216 + buf[0x16] * 65536 + buf[0x17] * 256 + buf[0x18],
			buf[0x19] * 16777216 + buf[0x1a] * 65536 + buf[0x1b] * 256 + buf[0x1c],
			buf[0x1d] * 16777216 + buf[0x1e] * 65536 + buf[0x1f] * 256 + buf[0x20],
			buf[0x21] * 16777216 + buf[0x22] * 65536 + buf[0x23] * 256 + buf[0x24],
			buf[0x25] * 16777216 + buf[0x26] * 65536 + buf[0x27] * 256 + buf[0x28],
			buf[0x29] * 16777216 + buf[0x2a] * 65536 + buf[0x2b] * 256 + buf[0x2c],
			buf[0x2d] * 16777216 + buf[0x2e] * 65536 + buf[0x2f] * 256 + buf[0x30],
			buf[0x31] * 16777216 + buf[0x32] * 65536 + buf[0x33] * 256 + buf[0x34],
			buf[0x35] * 16777216 + buf[0x36] * 65536 + buf[0x37] * 256 + buf[0x38],
			buf[0x39] * 16777216 + buf[0x3a] * 65536 + buf[0x3b] * 256 + buf[0x3c],
			buf[0x3d] * 16777216 + buf[0x3e] * 65536 + buf[0x3f] * 256 + buf[0x40]


			--
			local a, b, c, d, e = h1, h2, h3, h4, h5

			for i = 17, 80 do
				buf[i] = lrotate(bxor(buf[i - 3], buf[i - 8], buf[i - 14], buf[i - 16]), 1)
			end

			for i = 1, 20 do
				a, b, c, d, e = e + 0x5a827999 + buf[i] + lrotate(a, 5) + band(b, c) + band((0xffffffff - b), d), a, lrotate(b, 30), c, d
			end
			for i = 21, 40 do
				a, b, c, d, e = e + 0x6ed9eba1 + buf[i] + lrotate(a, 5) + bxor(b, c, d), a, lrotate(b, 30), c, d
			end
			for i = 41, 60 do
				a, b, c, d, e = e + 0x8f1bbcdc + buf[i] + lrotate(a, 5) + band(b, c) + band(bxor(b, c), d), a, lrotate(b, 30), c, d
			end
			for i = 61, 80 do
				a, b, c, d, e = e + 0xca62c1d6 + buf[i] + lrotate(a, 5) + bxor(b, c, d), a, lrotate(b, 30), c, d
			end

			h1, h2, h3, h4, h5 =
				(h1 + a) % 4294967296, (h2 + b) % 4294967296, (h3 + c) % 4294967296,
				(h4 + d) % 4294967296, (h5 + e) % 4294967296
		end
	end

	self.buffer_index = buf_idx
	self.data_length = self.data_length + data_length
	self.h1, self.h2, self.h3, self.h4, self.h5 = h1, h2, h3, h4, h5
end

function hash:sha1_finish()
	if not self.result then
		local data_length = self.data_length
		local filler_length = 64 - (data_length + 9) % 64

		self:process("\128"..("\0"):rep(filler_length)..intstr(data_length * 8, 8, false, true))

		self.data_length = data_length -- Yes, I'm lazy.
		self.result = format("%08x%08x%08x%08x%08x", self.h1, self.h2, self.h3, self.h4, self.h5)
	end

	return self.result
end


------------
-- SHA-256
------------

local SHA256_PRIMES_LUT = {
	0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
	0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
	0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
	0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
	0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
	0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
	0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
	0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
}

hash.sha256 = function()
	return {
		h1 = 0x6a09e667,
		h2 = 0xbb67ae85,
		h3 = 0x3c6ef372,
		h4 = 0xa54ff53a,
		h5 = 0x510e527f,
		h6 = 0x9b05688c,
		h7 = 0x1f83d9ab,
		h8 = 0x5be0cd19,

		buffer = {},
		buffer_index = 1,
		data_length = 0,

		process = hash.sha256_process,
		finish = hash.sha256_finish,
	}
end

function hash:sha256_process(data)
	local data_length = #data
	local buf = self.buffer
	local buf_idx = self.buffer_index
	local data_idx = 1

	local h1, h2, h3, h4, h5, h6, h7, h8 = self.h1, self.h2, self.h3, self.h4, self.h5, self.h6, self.h7, self.h8

	while data_idx <= data_length do
		local data_needed = 65 - buf_idx
		local bytes_added = min(data_needed, data_length - data_idx + 1)

		buf[buf_idx],      buf[buf_idx+0x01], buf[buf_idx+0x02], buf[buf_idx+0x03],
		buf[buf_idx+0x04], buf[buf_idx+0x05], buf[buf_idx+0x06], buf[buf_idx+0x07],
		buf[buf_idx+0x08], buf[buf_idx+0x09], buf[buf_idx+0x0a], buf[buf_idx+0x0b],
		buf[buf_idx+0x0c], buf[buf_idx+0x0d], buf[buf_idx+0x0e], buf[buf_idx+0x0f],
		buf[buf_idx+0x10], buf[buf_idx+0x11], buf[buf_idx+0x12], buf[buf_idx+0x13],
		buf[buf_idx+0x14], buf[buf_idx+0x15], buf[buf_idx+0x16], buf[buf_idx+0x17],
		buf[buf_idx+0x18], buf[buf_idx+0x19], buf[buf_idx+0x1a], buf[buf_idx+0x1b],
		buf[buf_idx+0x1c], buf[buf_idx+0x1d], buf[buf_idx+0x1e], buf[buf_idx+0x1f],
		buf[buf_idx+0x20], buf[buf_idx+0x21], buf[buf_idx+0x22], buf[buf_idx+0x23],
		buf[buf_idx+0x24], buf[buf_idx+0x25], buf[buf_idx+0x26], buf[buf_idx+0x27],
		buf[buf_idx+0x28], buf[buf_idx+0x29], buf[buf_idx+0x2a], buf[buf_idx+0x2b],
		buf[buf_idx+0x2c], buf[buf_idx+0x2d], buf[buf_idx+0x2e], buf[buf_idx+0x2f],
		buf[buf_idx+0x30], buf[buf_idx+0x31], buf[buf_idx+0x32], buf[buf_idx+0x33],
		buf[buf_idx+0x34], buf[buf_idx+0x35], buf[buf_idx+0x36], buf[buf_idx+0x37],
		buf[buf_idx+0x38], buf[buf_idx+0x39], buf[buf_idx+0x3a], buf[buf_idx+0x3b],
		buf[buf_idx+0x3c], buf[buf_idx+0x3d], buf[buf_idx+0x3e], buf[buf_idx+0x3f]
		=
		strbyte(data, data_idx, data_idx + bytes_added - 1)

		data_idx = data_idx + bytes_added
		buf_idx = buf_idx + bytes_added

		if buf_idx > 64 then
			buf_idx = 1

			buf[0x01], buf[0x02], buf[0x03], buf[0x04],
			buf[0x05], buf[0x06], buf[0x07], buf[0x08],
			buf[0x09], buf[0x0a], buf[0x0b], buf[0x0c],
			buf[0x0d], buf[0x0e], buf[0x0f], buf[0x10]
			=
			buf[0x01] * 16777216 + buf[0x02] * 65536 + buf[0x03] * 256 + buf[0x04],
			buf[0x05] * 16777216 + buf[0x06] * 65536 + buf[0x07] * 256 + buf[0x08],
			buf[0x09] * 16777216 + buf[0x0a] * 65536 + buf[0x0b] * 256 + buf[0x0c],
			buf[0x0d] * 16777216 + buf[0x0e] * 65536 + buf[0x0f] * 256 + buf[0x10],
			buf[0x11] * 16777216 + buf[0x12] * 65536 + buf[0x13] * 256 + buf[0x14],
			buf[0x15] * 16777216 + buf[0x16] * 65536 + buf[0x17] * 256 + buf[0x18],
			buf[0x19] * 16777216 + buf[0x1a] * 65536 + buf[0x1b] * 256 + buf[0x1c],
			buf[0x1d] * 16777216 + buf[0x1e] * 65536 + buf[0x1f] * 256 + buf[0x20],
			buf[0x21] * 16777216 + buf[0x22] * 65536 + buf[0x23] * 256 + buf[0x24],
			buf[0x25] * 16777216 + buf[0x26] * 65536 + buf[0x27] * 256 + buf[0x28],
			buf[0x29] * 16777216 + buf[0x2a] * 65536 + buf[0x2b] * 256 + buf[0x2c],
			buf[0x2d] * 16777216 + buf[0x2e] * 65536 + buf[0x2f] * 256 + buf[0x30],
			buf[0x31] * 16777216 + buf[0x32] * 65536 + buf[0x33] * 256 + buf[0x34],
			buf[0x35] * 16777216 + buf[0x36] * 65536 + buf[0x37] * 256 + buf[0x38],
			buf[0x39] * 16777216 + buf[0x3a] * 65536 + buf[0x3b] * 256 + buf[0x3c],
			buf[0x3d] * 16777216 + buf[0x3e] * 65536 + buf[0x3f] * 256 + buf[0x40]


			--
			local a, b, c, d, e, f, g, h = h1, h2, h3, h4, h5, h6, h7, h8

			for i = 17, 64 do
				local c15, c2 = buf[i - 15], buf[i - 2]

				buf[i] = buf[i - 16] + buf[i - 7] +
					bxor(rrotate(c15, 7), rrotate(c15, 18), rshift(c15, 3)) +
					bxor(rrotate(c2, 17), rrotate(c2, 19), rshift(c2, 10))
			end
			for i = 1, 64 do
				local t1 = h + SHA256_PRIMES_LUT[i] + buf[i] +
					bxor(rrotate(e, 6), rrotate(e, 11), rrotate(e, 25)) +
					band(e, f) + band((0xffffffff - e), g)

				a, b, c, d, e, f, g, h = t1 + bxor(rrotate(a, 2), rrotate(a, 13),
					rrotate(a, 22)) + bxor(band(a, b), band(a, c), band(b, c)),
					a, b, c, d + t1, e, f, g
			end

			h1, h2, h3, h4, h5, h6, h7, h8 =
				(h1 + a) % 4294967296, (h2 + b) % 4294967296, (h3 + c) % 4294967296, (h4 + d) % 4294967296,
				(h5 + e) % 4294967296, (h6 + f) % 4294967296, (h7 + g) % 4294967296, (h8 + h) % 4294967296
		end
	end

	self.buffer_index = buf_idx
	self.data_length = self.data_length + data_length
	self.h1, self.h2, self.h3, self.h4, self.h5, self.h6, self.h7, self.h8 = h1, h2, h3, h4, h5, h6, h7, h8
end

function hash:sha256_finish()
	if not self.result then
		local data_length = self.data_length
		local filler_length = 64 - (data_length + 9) % 64

		self:process("\128"..("\0"):rep(filler_length)..intstr(data_length * 8, 8, false, true))

		self.data_length = data_length -- Yes, I'm lazy.
		self.result = format("%08x%08x%08x%08x%08x%08x%08x%08x", self.h1, self.h2, self.h3, self.h4, self.h5, self.h6, self.h7, self.h8)
	end

	return self.result
end


return hash
