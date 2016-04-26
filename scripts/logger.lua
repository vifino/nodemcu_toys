-- Log module

local _M, modname = {}, ...
package.loaded[modname] = nil

_M.version = "0.0.1"

-- Libraries
local colors = require("ansicolors")

-- Variables
_M.print = print
_M.debug = cobalt and cobalt.debug or false -- Debugging turned on or off depending on cobalt setting.

-- Levels:
--  0: Critical priority, for _very_ _important_ messages. Red.
--  1: Important info, but not critical. Yellow.
--  2: Normal level, to be viewed, but generally nobody cares.
--  3: Debug output, won't output unless debug is enabled.
_M.critical = 0
_M.important = 1
_M.normal = 2
_M.debug = 3

-- Localizing just the required things to save memory.
local col_bright = colors.bright
local col_reset = colors.reset
local col_black = colors.black
local col_red = colors.red
local col_yellow = colors.yellow
colors = nil

-- The most commonly used log function, its colorful!
-- Format (log level colored): [STATENAME]> message
function _M.log(state_name, level, message)
	local level = level and tonumber(level) or 2
	local msg = "[" .. col_bright .. col_black .. (state_name or "Unnamed") .. col_reset .. "]> "
	if level == 0 then
		led(255, 0, 0)
		msg = msg .. col_bright .. col_red .. message .. col_reset
	elseif level == 1 then
		led(255, 100, 0)
		msg = msg .. col_yellow .. message .. col_reset
	elseif level == 2 then
		--led(0, 255, 0)
		msg = msg .. message
	elseif level >= 3 then
		if _M.debug then
			msg = msg .. message
		else
			return
		end
	else
		return -- Don't do anything.
	end
	_M.print(msg)
end

return _M
