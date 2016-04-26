print("Hello world!")
local cb = function(s, us, srv)
	if srv then -- sntp
		log("Synced time via SNTP.")
	end
end

if sntp then
	sntp.sync("venom.lan", cb)
else
	cb()
end
