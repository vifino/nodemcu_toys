-- NodeMCU server side fetcher

local mac = header("MAC"):gsub(":", "")
local file = header("FILE")

print("MAC: " .. tostring(mac))
print("File: " .. tostring(file))

local fp = "/nodemcu-fetch/"..mac.."/"..file

if not fs.exists(fp) then
	content("404 not found", 404)
	return
end
local ext = file:match("^.+(%..+)$") or ""
return fs.readfile(fp), 200, (mime.byext and mime.byext(ext)) or "application/octet-stream"
