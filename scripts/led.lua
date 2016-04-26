-- RGB LED attached to D1-D3 with R, G and B respectively.
local modname = ...
package.loaded[modname] = nil

if pwm then
	function led(r,g,b)
		local red = ( r == true ) and 255 or r
		local green = ( g == true ) and 255 or g
		local blue = ( b == true ) and 255 or b


		pwm.setduty(1, red or 0)
		pwm.setduty(2, green or 0)
		pwm.setduty(3, blue or 0)
	end

	pwm.setup(1,500,512)
	pwm.setup(2,500,512)
	pwm.setup(3,500,512)
	pwm.start(1)
	pwm.start(2)
	pwm.start(3)
	led()
else
	-- Placeholder so nothing crashes.
	function led()

	end
end
