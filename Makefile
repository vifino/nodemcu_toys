# Tools
UPLOADER?=sudo nodemcu-tool upload -o -c
UPLOADER_NOBC?=sudo nodemcu-tool upload -o

# Tool rules

terminal:
	sudo nodemcu-tool terminal

# Uploading rules
%.lua: scripts/%.lua
	$(UPLOADER) "$^" -n "$@"

# Dependencies
init.lua: wifi-setup.lua loadremote.lua logger.lua ansicolors.lua led.lua
	$(UPLOADER_NOBC) "scripts/init.lua" -n "init.lua"
