print("NodeMCU init.lua loading up...")
local maxfreeheap = node.heap()

-- Require hack to save memory.
local old_require = require
function require(lib)
	local ret = old_require(lib)
	package.loaded[lib] = nil
	return ret
end

-- Timers.
-- Kinda hacky, but it works! :D
timers_used = {
	false, -- 0
	false, -- 1
	false, -- 2
	false, -- 3
	false, -- 4
	false, -- 5
	false, -- 6
}
function soon(ms, fn) -- TIMER JUGGELING AHEAD
	if not fn then -- if its only called with function as single argument, use that
		fn = ms
		ms = 10
	end

	local nextfree
	for n = 1, 7 do
		if not timers_used[n] then
			nextfree = n - 1
			timers_used[n] = true
			break
		end
	end
	if nextfree then
		tmr.alarm(nextfree, ms, tmr.ALARM_SINGLE, function() -- schedule a timer on timerslot nextfree in 10ms, giving the mcu a little room to breathe and do networking shizniz or something
			timers_used[nextfree] = false
			fn()
		end)
	else
		error("All timers used!")
	end
end

function every(ms, fn) -- REPEATED TIMER JUGGELING AHEAD
	local nextfree
	for n = 1, 7 do
		if not timers_used[n] then
			nextfree = n - 1
			timers_used[n] = true
			break
		end
	end
	if nextfree then
		tmr.alarm(nextfree, ms, tmr.ALARM_AUTO, function()
			local ret = fn()
			if ret == true then
				tmr.unregister(nextfree)
				timers_used[nextfree] = false
			end
		end)
	else
		error("All timers used!")
	end
end

-- Log output
-- I like me some colors. ESPECIALLY WITH LEDS!!!
require("led")
package.loaded["led"] = nil
led()
logger = require("logger")

function log(str, nme, lvl)
	logger.log(nme or "Main", lvl or logger.normal, str)
end

-- Small utility
function round(num, idp)
  return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end


-- Main entry point
soon(5000, function()
	ip = wifi.sta.getip()
	if ip then
		log("NodeMCU has the IP "..tostring(ip))
		loadremote = require("loadremote")
		package.loaded["loadremote"] = nil

		-- Display some stats
		collectgarbage()
		local heap = node.heap()
		local mempercent = round((heap/maxfreeheap)*100, 2) -- old heap is the max lua side can get afaik
		log("Heap memory: "..tostring(maxfreeheap-heap).."/"..tostring(maxfreeheap).." Bytes used. ("..tostring(100-mempercent).."%)")
		heap = nil
		mempercent = nil
		maxfreeheap = nil

		local _, fs_used, fs_total = file.fsinfo()
		local fspercent = round((fs_used/fs_total)*100, 2)
		log("Storage: "..tostring(fs_used).."/"..tostring(fs_total).." Bytes used. ("..tostring(fspercent).."%)")
		fs_used = nil
		fs_total = nil

		log("Fetching new FW via HTTP...")
		loadremote.load("boot.lua", function(f)
			-- Cleanup
			led() -- turn off all the things
			loadremote = nil

			-- Start func
			f()

			-- Done
			f = nil
			log("Done.")
		end)
	else -- no ip? run wifi-setup to reconnect to wifi, running this file shortly afterwards to check again.
		log("No IP yet, reconnecting to Wifi...")
		require("wifi-setup")
		package.loaded["wifi-setup"] = nil
		soon(function()
			log("Reloading init.lua to check if it is better now...")
			require("init")
		end)
	end
end)
