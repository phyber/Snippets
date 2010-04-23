#!/usr/bin/env lua

local lockfile = require "liblockfile"

local MY_NAME = "lua"

local cur_pid = posix.getpid("pid")
local old_pid = lockfile.getpid(MY_NAME)

print(string.format("My PID: %d", cur_pid))

if old_pid ~= 0 and old_pid ~= cur_pid then
	if old_pid > 0 then
		io.stderr:write(string.format("lockfile with pid %d already running!\n", old_pid))
	end

	return -1
end

if lockfile.pid_stale(MY_NAME, cur_pid) == 1 then
	-- stuff
end

lockfile.create(MY_NAME, cur_pid)
posix.sleep(10)
lockfile.remove(MY_NAME, cur_pid)

print("Done.")

return 0
