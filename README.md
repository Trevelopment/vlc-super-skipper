<h1 align="center">Super Skipper</h1>
<p align=center><img alt="Super Skipper Logo" src="./super-skipper-logo.jpg" style="height:100px"></p>
<h3 align="center">For VLC Media Player</h3>
<h4 align="center">Automatically Skip Opening and Ending Sequences.</h4>
<h5 align="center"><a href="https://addons.videolan.org/p/1415936/">VLC Addons page</a></h5>

## Installation

Download the repo, copy the `lua` folder (containing [/extensions/super-skipper.lua & /intf/skipper_intf.lua](https://github.com/Trevelopment/vlc-super-skipper/archive/master.zip)) and paste it into your VLC [config-directory][config-dir]:

- Linux:
    - (All Users)
      - `/usr/lib/vlc/`
    - (Current User):
      - `~/.local/share/vlc/`
- MacOS:
    - (All Users)
       - `/Applications/VLC.app/Contents/MacOS/share/`
    - (Current User):
       - `/Users/<name>/Library/Application Support/org.videolan.vlc/`
- Windows:
    - (All Users)
      - `%ProgramFiles%\VideoLAN\VLC\`
    - (Current User):
      - `%APPDATA%\VLC\`

<div align="center">*** *Enable the 'skipper_intf' interface in the 'Set Interface' menu.  This only needs to be done if it is not already enabled. Restart VLC after enabling.* *** </div>

<p align=center><img alt="Super Skipper Preview" src="./super-skipper-v1.jpg"></p>

## Usage

1. From the VLC menu, select <kbd>&nbsp;View&nbsp;&gt;&nbsp;Super Skipper&nbsp;</kbd>.<br />
2. Set times for **openings and endings and a profile name** which is compared to the name and artist of the media file.<br />
3. If Profile equals or is a substring of the **name or artist** then that profile will be used.<br />
4. For simplicity all **special characters and spaces are stripped before comparing,** so file: **<code>test123.mp4</code>** will match with profile: **<code>t e$st1#2@3mp4</code>**<br />
    * Search priority is names first then artist, from top to bottom of list.  Uses first found match.<br />
    * Profiles are saved in a file named <kbd>super-skipper.conf</kbd> in your VLC [config-directory][config-dir].<br />
        * you can change the order or adjust times in that file.<br />

## Features

* **Autofill Buttons** for name, artist, or current time (s) of the playing media file.<br />
    * **Name:** File name.<br />
    * **Artst:** Artist.<br />
    * **Opening Start:** Start of opening credits. Check box **From Start** for start of video.<br />
    * **Opening Stop:** End of opening credits. (0 to disable skip opening)<br />
    * **Ending Start:** Start of ending credits.<br />
    * **Ending Stop:** End of ending credits. Check box **To End** for end of video. (0 to disable)<br />
* **Save:** Save profile.<br />
* **Save for Current:** Set profile to now playing file name and save.<br />
* **Set Interface:** Easily set interface settings.<br />
* **Time Format:** Toggle between (s) and HH:MM:SS time formats..<br />
* **Load:** Load selected profile values. <br />
* **Clear:** Clear all fields.<br />
* **Delete:** Delete Selected Profile.<br />
* **Help Menu:** With all this information!<br>

#### [Changelog](./changelog.md)

## Contributing

Bug reports, pull requests and ideas or suggestions are welcome on [GitHub](https://github.com/Trevelopment/vlc-super-skipper)

## License

This project is available under the terms of the GNU GPL V3. See the [`LICENSE`](LICENSE) file for the copyleft information.

[config-dir]: https://www.videolan.org/support/faq.html#Config
