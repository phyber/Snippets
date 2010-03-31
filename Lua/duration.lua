#!/usr/bin/env lua
--[[
-- Work out how long ago a timestamp was
-- and display it nicely.
-- Well, almost.
-- TODO: Edit snippet so it does the above.
--]]

local function ago(when)
        if not when then
                return 0
        end     
	local now = os.time()
        local diff = now - (now - when)
        local day = math.floor(diff / 86400)    diff = diff - (day * 86400)
        local hrs = math.floor(diff / 3600)     diff = diff - (hrs * 3600)
        local min = math.floor(diff / 60)       diff = diff - (min * 60)
        local sec = diff

        return string.format("%s%s%s%s",
                (day ~= 0) and day.."d " or "",
                (day or hrs ~= 0) and hrs.."h " or "",
                (day or hrs or min ~= 0) and min.."m " or "",
                sec.."s")
end     

print(ago(86400 * 1.5))
