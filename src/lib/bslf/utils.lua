--[[
    The following sequence of bits...
	   ... come only in 2 types.

	You are free to do with them whatever you want.
]]
--[[

	A small collection of functions with various usefulness.

	utils.hextobin(string_hex)
	utils.logbase(number, number_base)
	utils.sign(number)
	utils.clamp(number, number_lower_limit, number_upper_limit)
	utils.round(number)
	utils.xy_to_x(number_x, number_y, number_width, number_offset)
	utils.tobase(number, number_base)
	utils.todecimal(string_number, number_base)
	utils.strint(string_int, bool_signed, bool_big_endian, bool_ones_complement)
	utils.intstr(number, number_num_bytes, bool_signed, bool_big_endian, bool_ones_complement)
	utils.strfloat(string_float, bool_big_endian)
	utils.floatstr(number, bool_big_endian)
	utils.strdouble(string_double, bool_big_endian)
	utils.byte_scale(number, bool_show_unit, bool_binary)
	utils.bswap32(number)
	utils.linear_bounce(number, number_range)

]]

local strsub = string.sub
local strchar = string.char
local strbyte = string.byte
local floor = math.floor
local ceil = math.ceil
local log = math.log
local abs = math.abs

local POWN126 = 2^-126
local POWN1022 = 2^-1022
local INFINITY = math.huge

local utils = {}


utils.strchar_lookup = {}
utils.strbyte_lookup = {}

for i = 0, 255 do
	local char = strchar(i)

	utils.strchar_lookup[i] = char
	utils.strbyte_lookup[char] = i
end


-- Hex to binary.
utils.hextobin = function(hex)
	return (hex:gsub("(..)", function(byte) return utils.strchar_lookup[tonumber(byte, 16)] end))
end

-- Lua 5.2's math.log for older versions.
utils.logbase =	function(x, base)
	return log(x)/log(base)
end

-- Sign checker.
utils.sign = function(x)
	return (x>0 and 1) or (x<0 and -1) or 0
end

-- Value clamper.
utils.clamp = function(v, l, h)
	return (v<l and l) or (v>h and h) or v
end

-- Round to nearest.
utils.round = function(x)
	return (x<0 and ceil(x-0.5)) or floor(x+0.5)
end

-- Two dimensions to one.
utils.xy_to_x = function(x, y, width, offset)
	if offset then      -- 'if ... then' is actually faster than '+(... or 0)'.
		return y*width + x + offset
	end

	return y*width + x
end


-- Lookup tables for the next functions.
local base_digits = { [0]=
	"0","1", "2", "3", "4", "5", "6", "7", "8", "9",
	"A", "B", "C", "D", "E", "F", "G", "H",	"I", "J", "K", "L", "M",
	"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
}

local base_digits_as_numbers = { [0]=
	48, 49, 50, 51, 52, 53, 54, 55, 56, 57,
	65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77,
	78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90
}

local base_digits_lookup = {
	["0"]= 0, ["1"]= 1, ["2"]= 2, ["3"]= 3, ["4"]= 4, ["5"]= 5, ["6"]= 6, ["7"]= 7, ["8"]= 8, ["9"]= 9,
	["A"]=10, ["B"]=11, ["C"]=12, ["D"]=13, ["E"]=14, ["F"]=15, ["G"]=16, ["H"]=17,
	["I"]=18, ["J"]=19, ["K"]=20, ["L"]=21, ["M"]=22, ["N"]=23, ["O"]=24, ["P"]=25,
	["Q"]=26, ["R"]=27, ["S"]=28, ["T"]=29, ["U"]=30, ["V"]=31, ["W"]=32, ["X"]=33,
	["Y"]=34, ["Z"]=35,
	["a"]=10, ["b"]=11, ["c"]=12, ["d"]=13, ["e"]=14, ["f"]=15, ["g"]=16, ["h"]=17,
	["i"]=18, ["j"]=19, ["k"]=20, ["l"]=21, ["m"]=22, ["n"]=23, ["o"]=24, ["p"]=25,
	["q"]=26, ["r"]=27, ["s"]=28, ["t"]=29, ["u"]=30, ["v"]=31, ["w"]=32, ["x"]=33,
	["y"]=34, ["z"]=35
}


local function tobase_calc(num, base, ...)
	if num > 0 then
		local rem = num%base
		return tobase_calc((num-rem)/base, base, base_digits_as_numbers[rem], ...)
	end

	return ...
end

--	Converts decimal integers into a new base.
--	53216 in base 21 -> "5FE2"
utils.tobase = function(num, base)
	if num == 0 then
		return "0"
	end
	return strchar(tobase_calc(num, base))
end


-- Higher precision for tonumber with bases other than decimal.
utils.todecimal = function(num_str, base)
	local num, str_len = 0, #num_str

	for i = 0, str_len-1 do
		num = num + base_digits_lookup[strsub(num_str, str_len-i, str_len-i)]*(base^i)
	end

	return num
end


local function strint_split_be(num, byte, byte2, ...)
	if not byte2 and byte then
		return num*256 + byte
	end

	return strint_split_be(num*256 + byte, byte2, ...)
end

local function strint_split_le(num, byte, byte2, ...)
	if not byte2 and byte then
		return num*0.00390625 + byte
	end

	return strint_split_le(num*0.00390625 + byte, byte2, ...)
end

-- Converts binary integer in a string to number.
utils.strint = function(int_str, signed, big_endian, ones_complement)
	local num_bytes = #int_str
	local num

	if big_endian then
		num = strint_split_be(0, strbyte(int_str, 1, -1))
	else
		num = strint_split_le(0, strbyte(int_str, 1, -1))*2^((num_bytes-1)*8)
	end

	if signed then
		local signed_bit = 2^(num_bytes*8-1)
		if num >= signed_bit then
			if ones_complement then
				return num - signed_bit*2 + 1
			end

			return num - signed_bit*2
		end
	end

	return num
end



local function intstr_split_be(i, num, ...)
	local byte = num%256
	if i > 1 then
		return intstr_split_be(i-1,(num-byte)*0.00390625, byte, ...)
	end

	return byte, ...
end

local function intstr_split_le(i, num, ...)
	local frac = num%1
	local byte = num - frac
	if i > 1 then
		return intstr_split_le(i-1, frac*256, byte, ...)
	end

	return byte, ...
end


-- Converts number to binary integer in a string.
utils.intstr = function(num, int_bytes, signed, big_endian, ones_complement)
	if not int_bytes then
		int_bytes = 4
	end

	if num < 0 then
		if signed then
			num = 2^(int_bytes*8) + num

			if ones_complement then
				 num = num - 1
			end
		else
			num = num % 2^(int_bytes*8)
		end
	end

	if big_endian then
		return strchar(intstr_split_be(int_bytes, num))
	end

	return strchar(intstr_split_le(int_bytes, num/256^(int_bytes-1)))
end


-- Converts 32-bit float to number.
utils.strfloat = function(float, big_endian)
	local f4, f3, f2, f1 = strbyte(float, 1, 4)

	if big_endian then
		f1, f2, f3, f4 = f4, f3, f2, f1
	end

	local sgn = 1
	local exp = f1*2
	if f1 >= 128 then
		sgn = -1
		exp = exp - 256
	end

	local man = f2*65536 + f3*256 + f4
	if f2 >= 128 then
		man = man - 8388608
		exp = exp + 1
	end

	if exp == 0 then
		return sgn * (man*(1/8388608)) * POWN126
	elseif exp == 255 then
		if man == 0 then
			return sgn * INFINITY
		else
			return 0/0
		end
	else
		return sgn * (1 + man*(1/8388608)) * 2^(exp-127)
	end
end


-- Lazy and untested number to 32-bit float conversion.
utils.floatstr = function(num, big_endian)
	local exp, sgn = 127, 0

	if num ~= 0 then
		if num < 0 then
			sgn = 1
			num = -num
		end

		if num >= 2 then
			while num >= 2 do
				num = num * 0.5
				exp = exp + 1
			end
		elseif num < 1 then
			while num < 1 do
				num = num * 2
				exp = exp - 1
			end
		end

		num = (num-1)*8388608

		if big_endian then
			return strchar(128*sgn + floor(exp/2), 128*(exp%2) + floor(num/65536), floor(num/256)%256, floor(num)%256)
		end

		return strchar(floor(num)%256, floor(num/256)%256, 128*(exp%2) + floor(num/65536), 128*sgn + floor(exp/2))
	end

	return "\0\0\0\0"
end

-- Converts 64-bit float to number.
utils.strdouble = function(double, big_endian)
	local f8, f7, f6, f5, f4, f3, f2, f1 = strbyte(double, 1, 8)

	if big_endian then
		f1, f2, f3, f4, f5, f6, f7, f8 = f8, f7, f6, f5, f4, f3, f2, f1
	end

	local sgn = 1
	local exp = f1*16
	if f1 >= 128 then
		sgn = -1
		exp = exp - 2048
	end

	local msm = f2%16
	exp = exp + (f2 - msm)*0.0625
	local man = msm*281474976710656 + f3*1099511627776 + f4*4294967296 + f5*16777216 + f6*65536 + f7*256 + f8

	if exp == 0 then
		return sgn * (man*(1/4503599627370496)) * POWN1022
	elseif exp == 2047 then
		if man == 0 then
			return sgn * INFINITY
		else
			return 0/0
		end
	else
		return sgn * (1 + man*(1/4503599627370496)) * 2^(exp-1023)
	end
end


-- Auto scaler for byte size in decimal and binary notation.
local byte_prefixes = {
	{"B", "kB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"},
	{"B", "KiB", "MiB", "GiB", "TiB", "PiB", "EiB", "ZiB", "YiB"}
}

utils.byte_scale = function(num, show_unit, binary)
	local base, step = 1, 1000
	if binary then
		base, step = 2, 1024
	end

	-- log is slower: local unit = floor(logbase(max(1, size), step)+1)
	local mag
	for i = 1, 9 do
		if num >= step then
			num = num / step
		else
			mag = i
			break
		end
	end

	if show_unit then
		return (ceil(num*1000)/1000).." "..byte_prefixes[base][mag], mag
	end

	return ceil(num*1000)/1000, mag
end


-- 32-bit byte swapping.
utils.bswap32 = function(n)
	local b1, b2, b3, b4
	b1 = n%256
	n = (n-b1)/256
	b2 = n%256
	n = (n-b2)/256
	b3 = n%256
	b4 = (n-b3)/256

	return b1*16777216 + b2*65536 + b3*256 + b4
end


-- Clamps x to [0, range) by bouncing up and down.
utils.linear_bounce = function(x, range)
	range = range - 1
	return abs(x%(range*2) - range)
end


return utils
