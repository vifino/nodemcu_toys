# Tools
NODEMCU_TOOL?=sudo nodemcu-tool -b 115200
UPLOADER?=$(NODEMCU_TOOL) upload -o -c
UPLOADER_NOBC?=$(NODEMCU_TOOL) upload -o

# Tool rules

terminal:
	$(NODEMCU_TOOL) terminal

# Uploading rules
%.lua: scripts/%.lua
	$(UPLOADER) "$^" -n "$@"

# Dependencies
init.lua: wifi-setup.lua loadremote.lua logger.lua ansicolors.lua led.lua
	$(UPLOADER_NOBC) "scripts/init.lua" -n "init.lua"
