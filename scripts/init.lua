print("NodeMCU init.lua loading up...")

-- Timers.
-- Kinda hacky, but it works! :D
timers_used = {
	false, -- 1
	false, -- 2
	false, -- 3
	false, -- 4
	false, -- 5
	false, -- 6
}
function soon(fn, ms) -- TIMER JUGGELING AHEAD
	local nextfree
	for n = 1, 6 do
		if not timers_used[n] then
			nextfree = n
			timers_used[n] = timers_used
			break
		end
	end
	if nextfree then
		tmr.alarm(nextfree, ms or 10, tmr.ALARM_SINGLE, function() -- schedule a timer on timerslot nextfree in 10ms, giving the mcu a little room to breathe and do networking shizniz or something
			fn()
			timers_used[nextfree] = false
		end)
	else
		error("All timers used!")
	end
end

-- Log output
-- I like me some colors.
logger = require("logger")

function log(str, nme, lvl)
	logger.log(nme or "Main", lvl or logger.normal, str)
end

-- Main entry point
tmr.alarm(0, 5000, tmr.ALARM_SINGLE, function()
	ip = wifi.sta.getip()
	if ip then
		log("NodeMCU has the IP "..tostring(ip))
		loadremote = require("loadremote")
		log("Fetching new FW via HTTP...")
		loadremote.load("boot.lua", function(f)
			f()
			log("Done.")
		end)
	else -- no ip? run wifi-setup to reconnect to wifi, running this file shortly afterwards to check again.
		log("No IP yet, reconnecting to Wifi...")
		require("wifi-setup")
		soon(function()
			log("Reloading init.lua to check if it is better now...")
			require("init")
		end)
	end
end)
