--[[ -- Skipper Interface 1.0.0
-------  By Trezdog44
------- Inspired By TIME ------------------------
"skipper_intf.lua" > Put this VLC Interface Lua script file in \lua\intf\ folder
--------------------------------------------
*** Requires "super-skipper.lua" > Put the VLC Extension Lua script file in \lua\extensions\ folder ***

Simple instructions:
1) "super-skipper.lua" > Copy the VLC Extension Lua script file into \lua\extensions\ folder
2) "skipper_intf.lua" > Copy the VLC Interface Lua script file into \lua\intf\ folder
3) Start the Extension in VLC menu "View > Super Skipper" on Windows/Linux or "Vlc > Extensions > Super Skipper" on Mac and configure your profiles & settings.

Alternative activation of the Interface script:
* The Interface script can be activated from the CLI (batch script or desktop shortcut icon): vlc.exe --extraintf=luaintf --lua-intf=skipper_intf
* VLC preferences for automatic activation of the Interface script: Tools > Preferences > Show settings=All > Interface >
  * > Main interfaces: Extra interface modules [luaintf] (add to the interface list)
  * > Main interfaces > Lua: Lua interface [skipper_intf]

INSTALLATION directory (\lua\intf\):
* Windows (all users): %ProgramFiles%\VideoLAN\VLC\lua\intf\
* Windows (current user): %APPDATA%\VLC\lua\intf\
* Linux (all users): /usr/lib/vlc/lua/intf/
* Linux (current user): ~/.local/share/vlc/lua/intf/
* Mac OS X (all users): /Applications/VLC.app/Contents/MacOS/share/lua/intf/
* Mac OS X (current user): /Users/%your_name%/Library/Application Support/org.videolan.vlc/lua/intf/
**** Create directory if it does not exist! ****
--]]----------------------------------------

os.setlocale("C", "all") -- fixes numeric locale issue on Mac

-- Global Variables
VLC_version = vlc.misc.version()
skipper_ver = "1.1.0" -- Super Skipper Version
config = {}
skipper = false
profile_name = ""
opening_start = 0
opening_stop = 0
ending_start = 0
ending_stop = 0
opening = false
ending = false
-- The Main Function Loop
function Looper()
  Log("Super Skipper v" .. skipper_ver)
  local curi = nil
  while true do
    if vlc.volume.get() == -256 then break end -- inspired by syncplay.lua; kills vlc.exe process in Task Manager
    if vlc.playlist.status() == "stopped" then -- no input or stopped input
      if curi then -- input stopped
        Log("stopped")
        curi = nil
      end
      Sleep(1)
    else -- playing, paused
      local uri = nil
      if vlc.input.item() then uri = vlc.input.item():uri() end
      if not uri then --- WTF (VLC 2.1+): status playing with nil input? Stopping? O.K. in VLC 2.0.x
        Log("WTF??? " .. vlc.playlist.status())
        Sleep(1)
      elseif not curi or curi ~= uri then -- new input (first input or changed input)
        curi = uri
        set_skipper_profile()
        -- Log(curi)
      else -- current input
        if vlc.playlist.status() == "playing" then
          playing_loop()
          -- Log("playing")
        elseif vlc.playlist.status() == "paused" then
          set_skipper_profile()
          --Log("paused")
          Sleep(3)
        else -- ?
          Log("unknown")
          Sleep(1)
        end
        Sleep(1)
      end
    end
  end
end

function Log(lm)
  vlc.msg.info("[*skipper_intf*] " .. lm)
end

function Sleep(st) -- seconds
  vlc.misc.mwait(vlc.misc.mdate() + st * 1000000)
end

-------------   SKIPPER   ---------------

function Get_sk_config()
  profiles = {}
  config_file = vlc.config.configdir() .. "/super-skipper.conf"

  if (file_exists(config_file)) then
    load_all_profiles()
  end
end

function set_skipper_profile()
  Get_sk_config()
  skipper = set_profile_based_on_video_name(vlc.input.item():name()) or set_profile_based_on_video_name(vlc.input.item():metas().artist)
  if skipper then
    opening = true
    ending = true
    duration = vlc.input.item():duration()

    if (opening_stop <= 0 or opening_start > opening_stop) then
      opening = false
    end
    if (ending_start <= 0 or ending_stop <= 0 or ending_start > ending_stop or ending_start > duration) then
      ending = false
    end
  end
end

function playing_loop()
  local input = vlc.object.input()
  if vlc.input.is_playing() and skipper then

    local time = (vlc.var.get(input, "time") / 1000000)

    if opening then
      if (time > opening_start and time < opening_stop) then
        Log("Skipping Intro... to " .. opening_stop)
        vlc.var.set(input, "position", (opening_stop + 0.1) / duration)
      end
    end

    if ending then
      if (time > ending_start and time < ending_stop) then
        if (ending_stop > duration) then
          vlc.playlist.next()
        else
          Log("Skipping Credits... to " .. ending_stop)
          vlc.var.set(input, "position", (ending_stop + 0.1) / duration)
        end
      end
    end
    -- vlc.keep_alive()
    -- Sleep(1)
  end
end

function set_profile_based_on_video_name(name)
  if not name then return false end
  for _, profile in pairs(profiles) do
    local sname = string.strip_spec(name)
    local search = string.strip_spec(profile.name)
    if string.find(sname, search) then
      Log(name .. "; Using Skipper Profile: " .. profile.name)
      -- vlc.osd.message("Skipper: " .. profile.name, 500000000, "top") -- TODO: Show Profile name OSD message
      -- profile_dropdown:set_value(i) // Doesn't exist in VLC Api
      profile_name = profile.name
      opening_start = tonumber(profile.opening_start_time)
      opening_stop = tonumber(profile.opening_stop_time)
      ending_start = tonumber(profile.ending_start_time)
      ending_stop = tonumber(profile.ending_stop_time)
      return true
    end
  end
  -- Log("There is not profile for " .. name .. "!")
  return false
end

function load_all_profiles()
  local lines = lines_from(config_file)
  for _, line in pairs(lines) do
    for name, opening_start_time, opening_stop_time, ending_start_time, ending_stop_time in
    string.gmatch(line, "(.+)=(%d+),(%d+),(%d+),(%d+)") do
      table.insert(profiles, {
        name = name,
        opening_start_time = opening_start_time,
        opening_stop_time = opening_stop_time,
        ending_start_time = ending_start_time,
        ending_stop_time = ending_stop_time
      })
    end
  end
end

function file_exists(file)
  local f = io.open(file, "rb")
  if f then
    f:close()
  end
  return f ~= nil
end

function lines_from(file)
  local lines = {}

  for line in io.lines(file) do
    lines[#lines + 1] = line
  end

  return lines
end

function string.strip_spec(text)
  return string.lower(text:gsub( "%W", "" ))
end

-- -- XXXX -- -- SKIPPER -- -- XXXX -- --

Looper() --start
