#!/usr/bin/env lua
--[[
-- Insert separators into a given number if required.
--]]

local num = 1234567

-- Only works for integers.
local function commify(num)
	local finalnum = ""
	local count = 0
	for d in string.gmatch(string.reverse(tostring(num)), "%d") do
		if count ~= 0 and count % 3 == 0 then
			finalnum = finalnum .. "," .. d
		else
			finalnum = finalnum .. d
		end
		count = count + 1

	end
	return string.reverse(finalnum)
end

-- Works for real numbers
local function commify2(num)
	--local strnum = tostring(num)
	--local a, b = string.match(strnum, "(%d+)%.(%d+)")
	--local a, b = strnum:match("(%d+)%.?(%d+?)")
	--return string.format("%s.%s", string.gsub(string.gsub(a, "(%d%d%d)", "%1,"), ",$", ""), b)
	return ("%s"):format(tostring(num):reverse():gsub("(%d%d%d)", "%1,")):reverse():gsub(",%.", "."):gsub("^,", ""):gsub("%.(.*)", function(s) return "."..s:gsub(",", "") end)
end

if not arg[1] then
	print("Provide a number.")
else
	print(commify(arg[1]))
	local n2 = commify2(arg[1])
	print(n2)
end
