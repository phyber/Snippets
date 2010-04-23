#!/usr/bin/env lua
--[[
-- Shows the uptime of a given PID.
--]]
-- Required for stat()
require "posix"

-- Location of the uptime file and then
-- format string for the stat files.
local procuptime = "/proc/uptime"
local procpidstatfmt = "/proc/%d/stat"

-- Small wrapper for posix.stat, since we only care about filetype.
function filetype(f)
	return posix.stat(f, "type")
end

-- Split a string like Perl's split.
-- Returns a table.
function split(str, sep)
	local t = {}
	local pattern = "(.-)"..sep
	local last_end = 1
	local s, e, cap = str:find(pattern, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			t[#t + 1] = cap
		end
		last_end = e + 1
		s, e, cap = str:find(pattern, last_end)
	end
	if last_end <= #str then
		cap = str:sub(last_end)
		t[#t + 1] = cap
	end
	return t
end
-- Reads the uptime from the procuptime path givena bove.
function get_sys_uptime()
	local uptimefile = assert(io.open(procuptime, "rb"))
	local content = split(uptimefile:read("*all"), " ")[1]
	io.close(uptimefile)

	return content
end

-- Get the PIDs uptime along with its name.
-- Returns a list.
function get_proc_uptime(pid)
	local procfile = assert(io.open(string.format(procpidstatfmt, pid), "rb"))
	local content = split(procfile:read("*all"), " ")
	io.close(procfile)

	local uptime = content[22]
	local procname = content[2]

	return uptime, procname
end

-- Shows the uptime duration in a nice string.
function duration(uptime)
	local interval = {}
	local str
	for _, i in ipairs({60, 60, 24, 365}) do
		interval[#interval + 1] = uptime % i
		uptime = math.floor(uptime / i)
	end
	str = string.format("%dy %dd %dh %dm %ds", uptime, interval[4], interval[3], interval[2], interval[1])
	return str
end

local pid = arg[1]

if type(tonumber(pid)) == "number" and filetype(string.format(procpidstatfmt, pid)) == "regular" then
	local procuptime, procname = get_proc_uptime(pid)
	print(string.format("PID: %d %s -> %s", pid, procname, duration(get_sys_uptime() - (procuptime / 100))))
else
	print(string.format("Error. PID '%s' none existant or something went terribly wrong.", pid))
end
