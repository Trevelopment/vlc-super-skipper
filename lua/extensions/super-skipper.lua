--[[
-- Installation:
-- Linux (All Users): /usr/lib/vlc/lua/extensions/
-- Linux (Current User): ~/.local/share/vlc/lua/extensions/
-- MacOS (All Users): /Applications/VLC.app/Contents/MacOS/share/lua/extensions/
-- MacOS (Current User): /Users/<name>/Library/Application Support/org.videolan.vlc/lua/extensions/
-- Windows (All Users): %ProgramFiles%\VideoLAN\VLC\lua\extensions\
-- Windows (Current User): %APPDATA%\VLC\lua\extensions\
-- Profiles are saved in: ~/.config/vlc/super-skipper.conf
--]]

skipper_ver = "1.1.0" -- Super Skipper Version
intf_script = "skipper_intf" -- Location: \lua\intf\skipper_intf.lua
listwidth = 7 -- dialog table width,  min  4 to max 40
listheight = 35 -- dialog table height, min 10 to max 70
time_format = "s" -- Time format, s = seconds, h = hh:mm:ss
function descriptor()
  return {
    title = "Super Skipper",
    version = skipper_ver,
    author = "Trevor Martin",
    url = "https://github.com/Trevelopment/vlc-super-skipper",
    shortdesc = "Super Skipper",
    description = "Skip Opening and Ending Credits",
    capabilities = {"menu"}
  }
end

function activate()
    profiles = {}
    config_file = vlc.config.configdir() .. "/super-skipper.conf"

    if (file_exists(config_file)) then
      load_all_profiles()
    end

    local VLC_extraintf, VLC_luaintf, t, ti = VLC_intf_settings()
    if not ti or VLC_luaintf~=intf_script then trigger_menu(2) else trigger_menu(1) end
end

function deactivate()
  dlg:delete()
  -- vlc.deactivate()
end

function close()
  dlg:hide()
end


function meta_changed()
end

function menu()
  return {"Profiles", "Set Interface"}
  -------------------- TODO: LIST DIALOG -------------------------
  -- return {"Profiles", "Settings", "List"}
end
function trigger_menu(id)
  if id == 1 then -- Profiles
    if dlg then dlg:delete() end
    open_dialog()
  elseif id == 2 then -- Settings
    if dlg then dlg:delete() end
    open_settings_dialog()
    -- elseif id == 3 then -- TODO: List Profiles
    --   if dlg then dlg:delete() end
    --   open_list_dialog()
  end
end

--------------  Save Profiles Dialog --------------------

function open_dialog()
  dlg = vlc.dialog(descriptor().title)

  dlg:add_label("<center><h3>Profile</h3></center>", 1, 1, 4, 1)
  dlg:add_button("Load", populate_profile_fields, 1, 3, 2, 1)
  dlg:add_button("Clear", clear_profile, 3, 3, 1, 1)
  dlg:add_button("Delete", delete_profile, 4, 3, 1, 1)
  -- dlg:add_button("Current Name", get_now_playing, 1, 6, 2, 1)

  dlg:add_label("", 1, 2, 4, 1)

  dlg:add_label("<center><h3>Settings</h3></center>", 1, 4, 4, 1)

  dlg:add_button("Name ", get_now_playing, 1, 5, 1, 1)
  dlg:add_button("or Artist:", get_playing_artist, 2, 5, 1, 1)
  profile_name_input = dlg:add_text_input("", 3, 5, 2, 1)

  time_label = dlg:add_label("<center><h4>Time Format: Seconds</h4></center>" , 1, 6, 4, 1)

  dlg:add_button("Opening Start:", fill_open_start, 1, 7, 2, 1)
  opening_start_time_input = dlg:add_text_input("", 3, 7, 1, 1)
  check_beg = dlg:add_check_box("From Start", false, 4, 7, 1, 1)

  dlg:add_button("Opening Stop:", fill_open_stop, 1, 8, 2, 1)
  opening_stop_time_input = dlg:add_text_input("", 3, 8, 2, 1)

  dlg:add_label("", 1, 9, 4, 1)

  dlg:add_button("Ending Start:", fill_end_start, 1, 10, 2, 1)
  ending_start_time_input = dlg:add_text_input("", 3, 10, 2, 1)

  dlg:add_button("Ending Stop:", fill_end_stop, 1, 11, 2, 1)
  ending_stop_time_input = dlg:add_text_input("", 3, 11, 1, 1)
  check_end = dlg:add_check_box("To End", false, 4, 11, 1, 1)

  dlg:add_button("Save", save_profile, 1, 12, 2, 1)
  dlg:add_button("Save for Current", save_for_current, 3, 12, 2, 1)

  dlg:add_label("", 1, 13, 4, 1)

  bt_settings = dlg:add_button("Set Interface", click_settings, 1, 14, 1, 1)
  bt_settings = dlg:add_button("Time Fomat", click_time_format, 2, 14, 1, 1)
  bt_help = dlg:add_button("Help", click_HELP, 3, 14, 2, 1)
  ----------------------- TODO: LIST DIALOG -----------------------------
  -- bt_list = dlg:add_button("Profile List", click_list, 2, 14, 1, 1)

  populate_profile_dropdown()
  populate_profile_fields()

  dlg:show()
end

function fill_open_start()
  check_beg:set_checked(false)
  opening_start_time_input:set_text(get_curr_time())
end

function fill_open_stop()
  opening_stop_time_input:set_text(get_curr_time())
end

function fill_end_start()
  ending_start_time_input:set_text(get_curr_time())
end

function fill_end_stop()
  check_end:set_checked(false)
  ending_stop_time_input:set_text(get_curr_time())
end

function clear_profile()
  profile_name_input:set_text("")
  ending_start_time_input:set_text("")
  ending_stop_time_input:set_text("")
  opening_start_time_input:set_text("")
  opening_stop_time_input:set_text("")
  check_beg:set_checked(false)
  check_end:set_checked(false)
end

function get_curr_time()
  local curr_time = math.floor(vlc.var.get(vlc.object.input(), "time") / 1000000)
  if time_format == "h" then curr_time = hhmmss(curr_time) end
  return curr_time
end

function populate_profile_dropdown()
  profile_dropdown = dlg:add_dropdown(1, 2, 4, 1)

  for i, profile in pairs(profiles) do
    profile_dropdown:add_value(profile.name, i)
  end
end

function populate_profile_fields()
  local profile = profiles[profile_dropdown:get_value()]

  if profile then
    profile_name_input:set_text(profile.name)
    opening_start_time_input:set_text(profile.opening_start_time)
    opening_stop_time_input:set_text(profile.opening_stop_time)
    ending_start_time_input:set_text(profile.ending_start_time)
    ending_stop_time_input:set_text(profile.ending_stop_time)
    check_beg:set_checked(tonumber(profile.opening_start_time) == 0)
    check_end:set_checked(tonumber(profile.ending_stop_time) == 3599999)
    if time_format == "h" then format_time(time_format) end
  end
end

function delete_profile()
  local dropdown_value = profile_dropdown:get_value()

  if profiles[dropdown_value] then
    profiles[dropdown_value] = nil
    save_all_profiles()
  end
end

function save_profile()
  if profile_name_input:get_text() == "" then
    return
  end
  local hhmmss_format = time_format == "h" -- Save bool to convert back to h format
  if hhmmss_format then format_time("s") end -- Convert to s format berfore saving
  if opening_start_time_input:get_text() == "" or check_beg:get_checked() then
    opening_start_time_input:set_text("0")
  end
  if opening_stop_time_input:get_text() == "" then
    opening_stop_time_input:set_text("0")
  end
  if ending_start_time_input:get_text() == "" then
    ending_start_time_input:set_text("0")
  end
  if ending_stop_time_input:get_text() == "" then
    ending_stop_time_input:set_text("0")
  end
  if check_end:get_checked() then
    ending_stop_time_input:set_text("3599999") -- Maximum value in hhmmss format (99:59:59)
  end
  local updated_existing = false

  for _, profile in pairs(profiles) do
    if profile.name == profile_name_input:get_text() then
      profile.opening_start_time = tonumber(opening_start_time_input:get_text())
      profile.opening_stop_time = tonumber(opening_stop_time_input:get_text())
      profile.ending_start_time = tonumber(ending_start_time_input:get_text())
      profile.ending_stop_time = tonumber(ending_stop_time_input:get_text())
      updated_existing = true
    end
  end

  if not updated_existing then
    table.insert(profiles, 1, {
      name = profile_name_input:get_text(),
      opening_start_time = tonumber(opening_start_time_input:get_text()),
      opening_stop_time = tonumber(opening_stop_time_input:get_text()),
      ending_start_time = tonumber(ending_start_time_input:get_text()),
      ending_stop_time = tonumber(ending_stop_time_input:get_text())
    })
  end
  if hhmmss_format then format_time("h") end -- Convert back to hhmmss format
  save_all_profiles()
end

function save_for_current()
  get_now_playing()
  save_profile()
end

function get_now_playing()
  profile_name_input:set_text(vlc.input.item():name())
end

function get_playing_artist()
  profile_name_input:set_text(vlc.input.item():metas().artist)
end

function click_time_format()
  if time_format == "s" then
    format_time("h")
  else
    format_time("s")
  end
end

function format_time(format)
  dlg:del_widget(time_label)
  if format == "h" then
    opening_start_time_input:set_text(hhmmss(opening_start_time_input:get_text()))
    opening_stop_time_input:set_text(hhmmss(opening_stop_time_input:get_text()))
    ending_start_time_input:set_text(hhmmss(ending_start_time_input:get_text()))
    ending_stop_time_input:set_text(hhmmss(ending_stop_time_input:get_text()))
    time_label = dlg:add_label("<center><h4>Time Format: HH:MM:SS</h4></center>" , 1, 6, 4, 1)
  else
    opening_start_time_input:set_text(secs(opening_start_time_input:get_text()))
    opening_stop_time_input:set_text(secs(opening_stop_time_input:get_text()))
    ending_start_time_input:set_text(secs(ending_start_time_input:get_text()))
    ending_stop_time_input:set_text(secs(ending_stop_time_input:get_text()))
    time_label = dlg:add_label("<center><h4>Time Format: Seconds</h4></center>" , 1, 6, 4, 1)
  end
  time_format = format
  dlg:update()
end

function click_mainmenu()
  trigger_menu(1)
end

function click_settings()
  trigger_menu(2)
end

function click_list()
  trigger_menu(3)
end

-----------------  UTIL  ------------------------

function secs(hhmmss)            -- "hh:mm:ss" to secs
    local hms, h, m, s, n, i
    hms = hhmmss    -- ok, let's do some generous error checking
    hms = string.gsub(hms,"[:;,.-/ ]","") -- remove time dividers
    n = string.len(hms)
    if n < 6 then hms = string.sub("000000"..hms, -6, -1) end
    if string.len(hms) ~= 6 then return 0 end -- oops
    h = integer(string.sub(hms,1,2))
    m = integer(string.sub(hms,3,4))
    s = integer(string.sub(hms,5,6))
    if h<0 or m<0 or s<0 then return 0 end          -- oops
    return s + m*60 + h*3600
end

function hhmmss(secs) -- secs to "hh:mm:ss"
    local seconds = integer(secs)
    if seconds < 0  then return "00:00:00" end      -- oops
    if seconds > 359999 then return "99:59:59" end  -- oops
    local h = seconds/3600
    local hh = math.floor(h)
    local m = (h - hh) * 60
    local mm = math.floor(m)
    local s = (m - mm) * 60 + .5
    local ss = math.floor(s)
    if hh > 99 then hh = 99 end    -- just in case
    if hh < 10 then hh = "0"..hh end
    if mm < 10 then mm = "0"..mm end
    if ss < 10 then ss = "0"..ss end
    fhhmmss = hh..":"..mm..":"..ss
    return fhhmmss
end

function integer(s)   -- hoping s is integer in string format
    local num = tonumber(s)
    if num == nil then num = 0 end
    num = math.floor(num + .5)  -- ok, round to nearest integer
    if string.match(tostring(num),"[^-0123456789]") then
      return 0      -- if not an integer then set to 0
    else
      return num
    end
end

------------------------ Settings Dialog -----------------

function open_settings_dialog()
  dlg = vlc.dialog(descriptor().title .. " > SETTINGS")
  cb_extraintf = dlg:add_check_box("Enable interface: ", true, 1, 1, 1, 1)
  ti_luaintf = dlg:add_text_input(intf_script, 2, 1, 2, 1)
  dlg:add_button("SAVE!", click_SAVE_settings, 1, 2, 1, 1)
  dlg:add_button("MAIN MENU", click_mainmenu, 2, 2, 1, 1)
  --	lb_message = dlg:add_label("CLI options: --extraintf=luaintf --lua-intf=skipper_intf,1,4,3,1)
  local VLC_extraintf, VLC_luaintf, t, ti = VLC_intf_settings()
  lb_message = dlg:add_label("Current status: " .. (ti and "ENABLED" or "DISABLED") .. ". Interface: " .. tostring(VLC_luaintf), 1, 3, 3, 1)
end

function click_SAVE_settings()
  local VLC_extraintf, VLC_luaintf, t, ti = VLC_intf_settings()

  if cb_extraintf:get_checked() then
    --vlc.config.set("extraintf", "luaintf")
    if not ti then table.insert(t, "luaintf") end
    vlc.config.set("lua-intf", ti_luaintf:get_text())
  else
    --vlc.config.set("extraintf", "")
    if ti then table.remove(t, ti) end
  end
  vlc.config.set("extraintf", table.concat(t, ":"))

  lb_message:set_text("Please restart VLC for changes to take effect!")
end

function SplitString(s, d) -- string, delimiter pattern
  local t = {}
  local i = 1
  local ss, j, k
  local b = false
  while true do
    j, k = string.find(s, d, i)
    if j then
      ss = string.sub(s, i, j - 1)
      i = k + 1
    else
      ss = string.sub(s, i)
      b = true
    end
    table.insert(t, ss)
    if b then break end
  end
  return t
end

function VLC_intf_settings()
  local VLC_extraintf = vlc.config.get("extraintf") -- enabled VLC interfaces
  local VLC_luaintf = vlc.config.get("lua-intf") -- Lua Interface script name
  local t = {}
  local ti = false
  if VLC_extraintf then
    t = SplitString(VLC_extraintf, ":")
    for i, v in ipairs(t) do
      if v == "luaintf" then
        ti = i
        break
      end
    end
  end
  return VLC_extraintf, VLC_luaintf, t, ti
end

--- *************------- TODO: LIST DIALOG -------*************   ---
---------------------------- List Dialog ----------------------------

function open_list_dialog()
  --  display dialog

  dlg = vlc.dialog(descriptor().title)
  --        (..., i, j, k, l) = (..., left, down, width, height)

  lw = listwidth
  lh = listheight

  hiddenspacer = dlg:add_image("", lw + 1, lh, 1, 1) -- this allows list sizing
  list = dlg:add_list(1, 3, lw, lh)
  label_msg = dlg:add_label("", 1, lh + 3, 4, 1) -- ("",1,lh+3,lw,1)
  input = dlg:add_text_input("", 1, lh + 10, 4, 1)
  button_1 = dlg:add_button("<<", click_button1, 1, lh + 11, 1, 1)
  button_2 = dlg:add_button("<", click_button2, 2, lh + 11, 1, 1)
  button_3 = dlg:add_button(">", click_button3, 3, lh + 11, 1, 1)
  button_4 = dlg:add_button(">>", click_button4, 4, lh + 11, 1, 1)
  button_5 = dlg:add_button("Profiles", click_button5, 1, lh + 12, 1, 1)
  button_6 = dlg:add_button("Sort (A-Z)", click_button6, 2, lh + 12, 1, 1)
  button_7 = dlg:add_button("Sort (Z-A)", click_button7, 3, lh + 12, 1, 1)
  bt_help = dlg:add_button("Help", click_HELP, 4, lh + 12, 1, 1)
  -- setdlgmode(setnormal)
  -- there seems to be an issue where a click function is called twice
  -- with a single click. uses lastclicktime to slow the calling process
  lastclicktime = os.clock()

end

function click_button1()
end

function click_button2()
end

function click_button3()
end

function click_button4()
end

function click_button5()
end

function click_button6()
end

function click_button7()
end

function click_button8()
end

-------------   SKIPPER   ---------------

function save_all_profiles()
  io.output(config_file)
  for _, profile in pairs(profiles) do
    io.write(profile.name)
    io.write("=")
    io.write(profile.opening_start_time)
    io.write(",")
    io.write(profile.opening_stop_time)
    io.write(",")
    io.write(profile.ending_start_time)
    io.write(",")
    io.write(profile.ending_stop_time)
    io.write("\n")
  end
  io.close()

  dlg:del_widget(profile_dropdown)
  populate_profile_dropdown()
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

function click_HELP()
  local config_loc = string.gsub(config_file, '\\', '/')
  local config_dir = string.gsub(vlc.config.configdir(), '\\', '/')
  local help_text = [[
<style type="text/css">
body {background-color:white;}
.hello{font-family:"Arial black";font-size:48px;color:red;background-color:lime}
#header{background-color:lavender;}
.marker_red{background-color:#FF7FAA;font-size:18px;margin-bottom:10px;}
.marker_green{background-color:lightgreen;}
.input{background-color:lightblue;}
.button{background-color:silver;}
.tip{background-color:#FFFF7F;}
#footer{background-color:#2AE44F;}
</style>

<div id=header><b>Super Skipper v ]] .. skipper_ver .. [[</b> is VLC Lua Extension that will skip the opening and ending credits in a media file (or any 2 blocks of time.)</div>
<hr />
<center><b class=marker_red>&nbsp;Instructions&nbsp;</b></center>
<center><b class=marker_green>*** Enable the 'skipper_intf' interface in the 'Set Interface' menu.  This only needs to be done if it is not already enabled. Restart VLC. ***</b></center>
<br />
1) From the menu, select <kbd>&nbsp;View&nbsp;>&nbsp;Super Skipper&nbsp;</kbd>.<br />
2) Set times for <b class=input>openings and endings and a profile name</b> which is compared to the name and artist of the media file.<br />
3) If Profile equals or is a substring of the <b class=input>name or artist</b> then that profile will be used.<br />
4) For simplicity all <b class=input>special characters and spaces are stripped before comparing,</b> so profile: <b class=marker_green><code>test123.mp4</code></b> will match to file: <b class=marker_green><code>t e$st1#2@3mp4</code></b><br />
&nbsp;&nbsp;* Search priority is names first then artist, from top to bottom of list.  Uses first found match.<br />
&nbsp;&nbsp;* Profiles are saved in: <kbd><a href="]] .. config_loc .. [[">]] .. config_loc .. [[</a></kbd><br />
&nbsp;&nbsp;&nbsp;&nbsp;* you can change the order or adjust times in that file.<br />
<br />
<center><b class=marker_red>Features</b></center>
* <b class=input>Autofill Buttons</b> for name, artist, or current time (s) of the playing media file.<br />
&nbsp;&nbsp;* <b class=input>Name:</b> File name.<br />
&nbsp;&nbsp;* <b class=input>Artst:</b> Artist.<br />
&nbsp;&nbsp;* <b class=input>Opening Start (s):</b> Start of opening credits. Check box <b class=input>From Start</b> for start of video.<br />
&nbsp;&nbsp;* <b class=input>Opening Stop (s):</b> End of opening credits. (0 to disable skip opening)<br />
&nbsp;&nbsp;* <b class=input>Ending Start (s):</b> Start of ending credits.<br />
&nbsp;&nbsp;* <b class=input>Ending Stop (s):</b> End of ending credits. Check box <b class=input>To End</b> for end of video. (0 to disable)<br />
* <b class=input>Save:</b> Save profile.<br />
* <b class=input>Save for Current:</b> Set profile to now playing file name and save.<br />
* <b class=input>Set Interface:</b> Easily set interface settings.<br />
* <b class=input>Time Format:</b> Change time format (s) <-> HH:MM:SS.<br />
* <b class=input>Load:</b> Load selected profile values. <br />
* <b class=input>Clear:</b> Clear all fields.<br />
* <b class=input>Delete:</b> Delete Selected Profile.<br />
* <b class=input>Help Menu:</b> With all this information!<br />
<br />
<b class=tip>
TIPS:<br />
* Pausing will reload profile.<br />
* To disable skipping put 0 for Opening Stop or Ending Stop.<br />
* New saved profiles are added to the begining of the list, edit order in super-skipper.conf in your VLC config directory.<br />
* Your VLC config directory location: <br />
<kbd><a href="]] .. config_dir .. [[">]] .. config_dir .. [[</kbd><br />
</b>
<hr />
<div id=footer>
<b>GitHub:</b> <a href="https://github.com/Trevelopment/vlc-super-skipper">Super Skipper</a><br />
By: Trezdog44</div>
]]
  dlg:del_widget(bt_help)
  bt_help = nil
  ht_help = dlg:add_html(help_text, 1, 15, 4, 1)
  bt_helpx = dlg:add_button("HELP [x]", click_HELPx, 3, 14, 2, 1)
  dlg:update()
end
function click_HELPx()
  dlg:del_widget(ht_help)
  dlg:del_widget(bt_helpx)
  ht_help = nil
  bt_helpx = nil
  bt_help = dlg:add_button("HELP", click_HELP, 3, 14, 2, 1)
  dlg:update()
end

-----------------------------------------
