
local slock = {}

local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")

slock.textbox = wibox.widget.textbox()
slock.textbox:set_text("SLOCK")
slock.widget = wibox.container.margin(slock.textbox, 2, 2)

slock.is_on = true
slock.block_time = 300
slock.blocker = "slock"
slock.blocked = false
slock.idle_time = 0

function slock.switch()
   slock.is_on = not slock.is_on
   slock.update()
end

function slock.block_now()
   awful.spawn.easy_async(slock.blocker, function() end)
   slock.blocked = true
end

function update_data(stdout, stderr, reason, exit_code)
   slock.idle_time = math.floor(stdout / 1000)
   local minutes = math.floor(slock.idle_time / 60)
   local idle_time_message = ""
   if minutes > 0 then
      idle_time_message = minutes .. " m"
   elseif slock.idle_time > 5 then
      idle_time_message = slock.idle_time .. " s"
   else
      idle_time_message = "--"
   end
   local status_message = ""
   if slock.is_on then
      status_message = "on"
   else
      status_message = "off"
   end
   slock.textbox:set_text("SL " .. status_message .. " " ..idle_time_message)
   slock.widget = wibox.container.margin(slock.textbox, 2, 2)
end

function slock.update()
   awful.spawn.easy_async("xprintidle",
			  update_data)

   if slock.is_on == true then
      if slock.idle_time >= slock.block_time then
	 if not slock.blocked then
	    slock.block_now()
	 end
      else
	 if slock.blocked then
	    slock.blocked = false
	 end
      end
   end
end

function slock.start()
   slock.timer = gears.timer {
      timeout   = 10,
      autostart = true,
      callback  = function()
	 slock.update()
      end
   }
end

return slock
