-- NodeMCU server side fetcher

local mac = header("MAC"):gsub(":", "")
local file = header("FILE")

print("MAC: " .. tostring(mac))
print("File: " .. tostring(file))

local function ret(p)
	local ext = file:match("^.+(%..+)$") or ""
	return fs.readfile(p), 200, (mime.byext and mime.byext(ext)) or "application/octet-stream"
end

local fp = "/nodemcu-fetch/"..mac.."/"..file

if not fs.exists(fp) then
	local fp = "/nodemcu-fetch/default/"..file
	if not fs.exists(fp) then
		content("404 not found", 404)
		return
	end
	return ret(fp)
end
return ret(fp)
