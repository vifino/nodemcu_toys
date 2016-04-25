-- loadremote.lua: Dynamic loading of new firmware.
local loadremote = {}

-- Server base URL
loadremote.urls = {
	"http://apps.venom.lan/nodemcu-fetch",
	"http://apps.wtfits.science/nodemcu-fetch"
}
loadremote.url_index = 1

-- Status output
local status, status_err, status_warn
if log then
	status = function(msg, level)
		log(msg, "loadremote", level)
	end
	status_err = logger.critical
	status_warn = logger.important
else
	status = function(msg)
		print(msg)
	end
end

-- Fetch header
loadremote.fetch_header = "MAC: "..wifi.sta.getmac().."\r\nFILE: "

-- Fetch stuff
function loadremote.fetch(name, cb)
	return http.get(loadremote.urls[loadremote.url_index], loadremote.fetch_header..name.."\r\n", function(code, data)
		if code == -1 then -- Connection error.
			status("Mirror #"..tostring(loadremote.url_index).."failed, trying mirror #"..tostring(loadremote.url_index + 1), status_warn)
			loadremote.url_index = loadremote.url_index + 1
			if loadremote.urls[loadremote.url_index] then
				return loadremote.fetch(name, cb)
			else
				status("Tried all available mirror urls, all failed. Giving up.", status_err)
			end
		else
			return cb(code, data)
		end
	end)
end

-- Load file from remote
function loadremote.load(script, cb)
	loadremote.fetch(script, function(code, data)
		if code == 200 then
			local f, err = loadstring(data)
			data = nil
			if err then
				status("New firmware errored: "..err, status_err)
				return
			end
			if cb then
				soon(function() cb(f) end)
			else
				soon(f)
			end
		else
			status("Failed loading firmware, http code is "..tostring(code), status_err)
		end
	end)
end

local _, reset_reason = node.bootreason()
if reset_reason == 0 then
	print("Bootup, fetching new software...")
	loadremote.load("boot.lua")
end

return loadremote
