-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local xresources        = require("beautiful.xresources")
local dpi               = xresources.apply_dpi
--require("collision")()
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling libraryR
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local lain    = require("lain")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}


-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("~/.config/awesome/themes/theme/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "alacritty"
editor = os.getenv("nano") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    --awful.layout.suit.tile.left,
    --awful.layout.suit.tile.bottom,
    --awful.layout.suit.tile.top,
    --awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.magnifier,
    --awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

-- Menu
beautiful.menu_height=20
beautiful.menu_width=180
beautiful.menu_bg_normal="#040208"
beautiful.menu_bg_focus="#6236b2"
beautiful.menu_fg_focus="#040208"
--beautiful.menu_bg_normal=""


mymainmenu = awful.menu({ items = { { " Awesome ", myawesomemenu},
                                    { "🗖 Open terminal", "alacritty" },
                                    { " Browser ", "librewolf"},
                                    { "📁 Files ", "thunar"},
                                    { " Shutdown", "shutdown now"}
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu  = mymainmenu })

mylauncher = wibox.widget {
    {
        mylauncher,
        widget = wibox.container.margin,
        margins = 5,
    },
    bg     = "#08052B",
    shape_border_width    = dpi(1),
    shape_border_color    = "#00ffff",
    shape  = gears.shape.rounded_rect,
    widget = wibox.container.background,

}

-- Additional margins around background container
mylauncher = wibox.widget {
    mylauncher,
    widget = wibox.container.margin,
    margins = 2,
}

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock(
    "%l:%M:%S %p", 1
    )

mytextclock = wibox.widget {
    {
        mytextclock,
        widget = wibox.container.margin,
        left  = 5,
        right = 10, --Additional margin added for symmetry 
        top   = 5,
        bottom = 5,
    },
    bg     = "#08052B",
    shape_border_width    = dpi(1),
    shape_border_color    = "#00ffff",
    shape  = gears.shape.rounded_rect,
    widget = wibox.container.background,

}

-- Additional margins around background container
mytextclock = wibox.widget {
    {
        mytextclock,
        widget = wibox.container.margin,
        margins = 2,
    },
    valign = "center",
    widget = wibox.layout.align.horizontal,
}

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized("~/.config/awesome/themes/wallpaper/pain.jpg", s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4"}, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox = awful.widget.layoutbox(s)
    mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
-- Layout box widget
mylayoutbox = wibox.widget {
    
        mylayoutbox,
        widget  = wibox.container.margin,
        margins = 3,
    }
    
    -- Create a taglist widget
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local awful     = require("awful")
local gears     = require("gears")
local wibox     = require("wibox")
local beautiful = require("beautiful")


-- Create a function to generate the circle shape
local function circle_shape(size, bg)
    return function(cr, width, height)
        gears.shape.circle(cr, width, height, size)
    end, bg
end

-- Create the taglist widget
local taglist = awful.widget.taglist {
    screen  = s,
    filter  = awful.widget.taglist.filter.all,
    buttons = taglist_buttons,
    widget_template = {
        {
            {
                {
                    {
                        {
                            widget = wibox.widget.imagebox,
                            resize = true,
                            id = 'icon_role',
                        },
                        margins = 1,
                        widget  = wibox.container.margin,
                    },
                    {
                        id     = 'text_role',
                        widget = wibox.widget.textbox,
                    },
                    layout = wibox.layout.fixed.horizontal,
                },
                left  = 12,
                right = 14,
                widget = wibox.container.margin,
            },
            shape        = circle_shape(11, "#ffffff"),
            shape_border_width = 2,
            shape_border_color = "#00ffff",
            widget       = wibox.container.background,
        },
        id              = 'background_role',
        forced_height   = 25,
        widget          = wibox.container.background,
    },
}

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Statusbar: WIBAR


-- Systray widget
local systray = wibox.widget.systray()
systray = wibox.widget {
    {
        systray,
        widget  = wibox.container.margin,
        margins = 5,
    },
    bg     = "#08052B",
    shape_border_width    = dpi(1),
    shape_border_color    = "#00ffff",
    shape  = gears.shape.rounded_rect,
    widget = wibox.container.background,

}

-- Additional margins around background container
systray = wibox.widget {
    systray,
    widget = wibox.container.margin,
    margins = 2,
}
-- spacer
    spacer     = wibox.widget.textbox(" ")
    spacerL    = wibox.widget.textbox("   ")
  spacerXL   = wibox.widget.textbox("     ")

  local spacerline = wibox.widget.textbox("  ")
  spacerline = wibox.widget {
    spacerline,
    fg = "#808080",
    bg     = beautiful.bg_normal .. "00",
        widget = wibox.container.background,
  }

-- convert GB into decimals
    local GB_const = 0.00098
  local GB_convert = function ( mb )
    return string.format("%.1f", mb * GB_const)
  end
    
-- memory widget
local mymem = lain.widget.mem{
    settings = function()
        widget:set_markup(" " .. GB_convert(mem_now.used) .. " GB ")
    end
}
mymem = wibox.widget {
  mymem,
  fg     = "#50c878",
  bg     = beautiful.bg_normal .. "00",
    widget = wibox.container.background,
}
-- cpu widget
    local mycpu = lain.widget.cpu {
    settings = function()
        widget:set_markup(" " .. cpu_now.usage .. "% ")
    end
}
mycpu = wibox.widget {
    mycpu,
    fg     = "#87cefa" ,
    bg     = beautiful.bg_normal .. "00",                                                            
    widget = wibox.container.background,
}
-- temp widget
local mytemp = lain.widget.temp{
settings = function()
widget:set_markup(" " .. coretemp_now .. "°C ")
end 
}
mytemp = wibox.widget {
    mytemp,
    fg     = "#ffa500",
    bg     = beautiful.bg_normal .. "00",                                                            
    widget = wibox.container.background,
}

infobox = wibox.widget {
    {
        mycpu,
        mymem,
        mytemp,
        widget  = wibox.container.margins,
        margins = 5,
        layout  = wibox.layout.fixed.horizontal,
    },

    --bg     = "#08052B",
    shape_border_width    = dpi(1),
    shape_border_color    = "#00ffff",
    shape  = gears.shape.rounded_rect,
    widget = wibox.container.background,
}

infobox = wibox.widget {
    infobox,
    widget = wibox.container.margin,
    margins = 2,
}
--awful.wibox({ screen = s, height = 4, bg = "#00000000", })

    s.mywibox = awful.wibar ({ 

                              position     = "top", 
                              screen       = s,
                              stretch      = false,
                              height       = dpi(32),
                              width        = dpi(1900),
                              --border_width = dpi(2),
                              --border_color = "#22fce6", 
                              fg           = "#ffffff",
                              --bg           = "#010203",
                              bg           = beautiful.bg_normal .. "00",
                             -- shape        = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 20) end,
                              

                            })
    s.mywibox:setup({
    layout = wibox.layout.stack,
    {
      layout = wibox.layout.align.horizontal,
      { -- Left widgets
        layout = wibox.layout.fixed.horizontal,
        spacer,
        mylauncher,
        --spacerline,
        spacer,
        taglist,

      },
      nil,
      { -- Right widgets
        layout = wibox.layout.fixed.horizontal,
        spacer,
        systray,
        --spacerline,
        infobox,
        --spacer,
        mylayoutbox,

      },
    },
    {   
      mytextclock,
      valign = "center",
      halign = "center",
      layout = wibox.container.place,
                              
    },
  })
   

end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    --toggle wibar
    awful.key({modkey,}, "b", 
      function() 
        awful.screen.focused().mywibox.visible = not 
        awful.screen.focused().mywibox.visible end),

    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "r", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),


    -- Rofi
    awful.key({ modkey },            "space",     function () 
        awful.util.spawn("rofi -show combi")end,
            {description = "run rofi", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = "#00f4ff",
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },
  
{
    rule_any = { class = { "Steam" } },
    properties = {
      titlebars_enabled = false,
      floating = true,
      border_width = 0,
      border_color = 0,
      size_hints_honor = false,
    },
  },
    { rule = { class = "steam_app_1172470" },
  properties = { fullscreen = true } },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    --{ rule_any = {type = { "normal", "dialog" }
      --}, properties = { titlebars_enabled = true }
    --},

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

-- Wallpaper
awful.spawn.with_shell("feh --bg-fill ~/.config/awesome/themes/wallpaper/car.png")

-- Autostart programs
awful.spawn.once("picom") 
awful.spawn.once("flameshot")
awful.spawn.with_shell("sxhkd")
--awful.spawn.with_shell("redshift")
--awful.spawn.with_shell('pgrep -u $USER -x volctl || volctl')
awful.spawn.with_shell("xbindkeys -n")

-- Bash scripts
awful.spawn.with_shell("bash mousesettings.sh")









