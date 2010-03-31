#!/usr/bin/env lua
--[[
-- Insert separators into a given number if required.
--]]

local num = 1234567

local function commify(num)
	local finalnum = ""
	local count = 0
	for d in string.gmatch(string.reverse(tostring(num)), "%d") do
		if count ~= 0 and math.mod(count, 3) == 0 then
			finalnum = finalnum .. "," .. d
		else
			finalnum = finalnum .. d
		end
		count = count + 1

	end
	return string.reverse(finalnum)
end

print(commify(num))
