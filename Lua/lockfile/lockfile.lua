#!/usr/bin/env lua

local lockfile = {}
require "posix"

local MY_NAME = "lua"
local LOCKFILE_RUN_PATH = "/var/tmp"

function lockfile:get_filename(name)
	if not name or name == "" then
		io.stderr:write("lockfile_get_filename(): No name provided.\n")
		return nil
	end

	local filename = string.format("%s/%s", LOCKFILE_RUN_PATH, name)

	return filename
end

function lockfile:create(name, pid)
	if not name or name == "" then
		io.stderr:write("lockfile_create(): No name provided.\n")
		return nil
	end

	local filename = lockfile:get_filename(name)
	if not filename then
		return -1
	end

	local fp, e, en = io.open(filename, "wb")
	if not fp then
		io.stderr:write(string.format("Couldn't open file in lockfile_create: %s (%d)\n", e, en))
		return -1
	end

	fp:write(string.format("%d\n", pid))
	io.close(fp)

	return 0
end

function lockfile:remove(name, pid)
	if not name or name == "" then
		io.stderr:write("lockfile_remove(): No name provided.\n")
		return nil
	end

	local pid_check = lockfile:getpid(name)

	if pid_check > 0 and pid_check ~= pid then
		io.stderr:write(string.format("\nAnother instnace(%d) seems to be running (we are %d).\n", pid_check, pid))
		return -1
	elseif pid_check == 0 then
		-- no file to check, nothing to do
		return 0
	elseif pid_check < 0 then
		-- error
		return pid_check
	end

	local filename = lockfile:get_filename(name)
	local ret, err = os.remove(filename)
	if not ret then
		io.stderr:write(string.format("Error unlinking %s -> %s\n", filename, err))
		return -1
	else
		return 0
	end
end

function lockfile:getpid(name)
	if not name or name == "" then
		io.stderr:write("lockfile_getpid(): No name provided.\n")
		return nil
	end

	local filename = lockfile:get_filename(name)

	local fp, err, errno = io.open(filename, "rb")
	if not fp then
		if errno == 2 then
			-- ENOENT
			return 0
		end
		io.stderr:write(string.format("lockfile_getpid(): Failed to open %s -> (%d) -> %s\n", filename, errno, err))
		return -1
	end

	local fcontent = fp:read("*all")
	local file_pid = fcontent:match("%d+\n")

	if not file_pid then
		io.stderr:write("Could not getpid().\n")
		file_pid = -1
	end

	io.close(fp)

	return tonumber(file_pid)
end

function lockfile:pid_stale(name, pid)
	local path = string.format("/proc/%d", pid)
	
	if posix.stat(path, "type") ~= "directory" then
		io.stderr:write(string.format("%s is not a directory, process not running.\n", path))
		return 0
	end

	path = path .. "/cmdline"

	local fp, err = io.open(path, "rb")
	if not fp then
		io.stderr:write(string.format("Error opening %s -> %s\n", path, err))
		return -1
	end

	local fcontent = fp:read("*all")
	local base_name = posix.basename(fcontent)

	if name ~= base_name then
		io.stderr:write(string.format("pid reused by unrelated process(%s)\n", base_name))
		return 0
	end

	return 1
end

local function test_it()
	local cur_pid = posix.getpid("pid")
	local old_pid = lockfile:getpid(MY_NAME)

	print(string.format("My PID: %d", cur_pid))

	if old_pid ~= 0 and old_pid ~= cur_pid then
		if old_pid > 0 then
			io.stderr:write(string.format("lockfile with pid %d already running!\n", old_pid))
		end

		return -1
	end

	if lockfile:pid_stale(MY_NAME, cur_pid) == 1 then
		-- stuff
	end

	lockfile:create(MY_NAME, cur_pid)
	posix.sleep(30)
	lockfile:remove(MY_NAME, cur_pid)

	print("Done.")

	return 0
end

test_it()
