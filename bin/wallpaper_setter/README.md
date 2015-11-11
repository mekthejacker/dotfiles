wallpaper_setter.sh
===================

A daemon to set and adjust wallpapers.

_Depends on `identify` from imagemagick, `xrandr`, `bc`, `hsetroot` and `Xdialog`. Tested with GNU bash-4.2.45, GNU sed-4.2.1 and GNU grep-2.14. Stable work with similar utilities produced by other projects, like BSD, or having versions below the specified ones, is not guaranteed._

### Did you ever

- think about how many folders with _potential wallpapers_ you have?
- wanted _to simply choose a folder_ where to take wallpapers from?
- and set them in random order each ten minutes?
- wanted to _adjust brightness_ of the current wallpaper with a shortcut?

With this script you’ll be able to do not only this, but also

- set a new wallpaper with a shortcut;
- change its filling mode on the screen;
- keep it from auto-switching;
- set default brightness which all images will have after being set as wallpaper;
- have history of previously set images and remember their brightness and other settings after reboot;
- and, of course, switch between images in history with settings they had.

### Running the daemon

To start the daemon, only `-d <directory>` option is required. It takes a path to a directory with wallpapers as argument. But in order to see if something went wrong, for example, if the path was mistyped, it’s better to also set via `-e <a program>` which will be showing error messages. This script was written with `i3-nagbar` in mind, but any other program will go. e.g. it was also tested with `zenity`. The bad thing about zenity is, if you have many workspaces, you may not see the message because it will appear only on one workspace.
So, how would a simple call look like?

    ~/path/to/wallpaper_setter.sh -d "/path/to/my/wallapapers" &

or, better

    ~/path/to/wallpaper_setter.sh -e "i3-nagbar -m \"%m\" -b Restart \"%a\"" -d "/path/to/my/wallapapers" &

Here in escaped quotes you may see keys for substitution: `%m` will be substituted with actual error _message_ and `%a` will be substituted with _action_ (there can be only one action — command to restart the script). Some errors are not critical but others force the script to quit, so it’s useful to have such button. The same example with zenity would look more simple, because it cannot take action as an argument.

    ~/path/to/wallpaper_setter.sh -e "zenity --error --text=\"%m\"" -d "/path/to/my/wallapapers" &

This script will work even if no program to show messages was set, but in this case the only possibility to understand what’s wrong would be watching the terminal output (after running the daemon without forking (`&`) it to background)

### And what then?

This script works as a client-server application, but consists of only one file. There were several reasons to do it this way:
- this script must remember paths to images from the folder it currently takes images from, becasue picking a random one from a big folder will abuse the disk;
- history must be kept;
- settings for the images must be kept, too.

And there is no need to make two files — file is one, but instances differ. When called with client keys, script only communicates with the server part and exits.
So, to send a command, one can simply run

    ~/path/to/wallpaper_setter.sh -n

from a terminal. This should set another wallpaper from the directory specified with `-d`.

To automate changing wallapaper every 10 minutes put these lines in crontab file, calling it for editing with `crontab -e`

    # Change wallpaper every 10 minutes.
    */10 * * * * ~/path/to/wallpaper_setter.sh -qn
    
The new `-q` key stands for being quiet. When this switch is given, script doesn’t produce any output, even on terminal, and forces the server not to produce any output as well during the execution of command following the `-q` key. This means if it will be unable to set a new wallpaper (e.g. if you set the current wallpaper to be kept), then it shouldn’t produce any messages.

Is all clear so far? Good.

### Synopsis

This is the full list of keys that may be passed to server and to client.

Run as server:

    ~/path/to/wallpaper_setter.sh [-q] [-B] [-l] [-s] [-e command] -d directory 

Run as client:

    ~/path/to/wallpaper_setter.sh [-q] [-e command] <-b|-i|-k|-m|-[f]n|-p|-r|-R directory|-u|w>

To get information:

    ~/path/to/wallpaper_setter.sh <-h|-H|-v>

#### Parameters

`-b amount` Set or adjust brightness of current image. The value must be enclosed in range [-1..1]. To increase or decrease brightness, - or + sign must precede the value, e.g. -0.2, +0.1 etc.

`-B amount` Initial brightness value to be used when setting a new wallpaper.

`-d directory` A directory where wallpapers stored.

`-e command` Output error messages through this `command`. Since this script is supposed to run in background, there should be some utility interacting with your GUI so you could be aware of what’s going on, if something went wrong. It better should be the first parameter specified. `%m` and `%a` within the `command` will be substituted with the actual message and shell code to restart this script respectively, e.g. 

    -e "i3-nagbar -m \"%m\" -b 'Restart' \"%a\""

will be executed as

    i3-nagbar -m "A message" -b 'Restart' \
        "~/path/to/wallpaper_setter.sh \"with\" \"all\" \"its\" \"parameters\" &"

`-f` Force action. At current state using this key in addition to `-n` will cancel the effect of `-k` and set next wallpaper.

`-h` Show usage.

`-H` Briefly explain how this script works with examples.

`-i` Show path to the current wallpaper.

`-k` Keep current wallpaper. Ignore commands that try to set a new wallpaper, i.e. `-n` commands. The main purpose is to override a cron job that automates changing.

`-l` Collection limit. The maximum amount of images stored in history. Set to 0 in order to make it unlimited. If unset, then it’s equal to 5 by default.

`-m` Change mode in which current image is shown on the screen. Available modes are the ones `hsetroot` uses: fill, full, center and tile.

`-n` Change to the next (random) wallpaper.

`-p` Move back to the previous wallpaper in history.

`-r` Restrict to subdirectory. Calls GUI interface with a list of subdirectories to pick. After selection wallpapers will be taken only from selected directory (and its subdirectories). This option also forces new wallpaper to be chosen and set from the new directory. This option implies `-u`.

`-R directory` CLI version of the above. Instead of calling GUI, sets restriction to the directory passed as argument.

`-q` Be quiet. No output will be done, so it’s safe to use in a cron job.

`-s` Scale images that are smaller than screen to fill it (saving proportions), instead of placing them in center in scale 1:1.

`-u` Update the internal list of files in the directory script currently looks for wallpapers. Supposed to be used in a cron job, like once in 24 hours or so. In runtime is not much useful since changing directory implies update.

`-v` Print version and legal information.

`-w` Redraw current wallpaper. Useful in autostart script if this script is left hanging in the background for some reason.

`-z directory` Make a symbolic link to the current wallpaper in the specified directory on wallpaper change.

##### Notes

- The order of keys is important!
  This means `-e` and `-q` should be given as early as possible.

- The `-k` setting that keeps current wallpaper has effect only on command setting new wallpaper. I.e. you can freely switch to the previous one, and then _it_ will be kept. But switching to the next one will still require force, i.e `-fn`. Actually, it doesn’t keep wallpaper, it only prevents action of `next_wallpaper` commmand, but it’s long and hard to remember.

- `next_wallpaper` will try to avoid setting a wallpaper that was already set and can be found in history. So, if the history limit is big, one can notice a higher CPU usage sometimes — script will check images one by one until it finds a new one that wasn’t used or the count of performed tries will reach the current amount of history entries. In this case it will just pick a random index from history and use it.

- Unlike the original `hsetroot` behaviour, if the value passed as brightness has a sign, this script adds it to or substracts it from the brightness wallpaper currently has, i.e. if

­

    hsetroot my_wallpaper.png -brightness -0.5
    
would _set_ the image brightness, 

    ~/path/to/wallpaper_setter.sh -b -0.5
    
will _decrease_ it, and if it was, say, 0.4, it will become -0.1. However,

    ~/path/to/wallpaper_setter.sh -b 0
    
will set brightness to 0, because it has no + or - sign in front of the digit. Thus `-b 0.2` will set brightness to 0.2 while `-b +0.2` will increase it by 0.2.

- Actually, the script uses two named pipes to send actual command, and when called as client it only sends the corresponding command to the pipe, confirms its receiving and exits. Named pipes mentioned above are

­

    ~/.wallpaper_setter/rx         This pipe is used to receive commands.
    ~/.wallpaper_setter/tx         And this one – to confirm the act of receiving.

#### Signals

This script has two hooks end user may find handy to use:

- on `SIGUSR1` script will export its data to files;
- on `SIGUSR2` it will export data and reload itself.


For example, if there is a new version then, instead of restarting it manually with typing all the necessary keys or copypasting them, it’s enough to replace the script file and execute

    pkill -USR2 -f 'wallpaper_setter.sh'

or even

    pkill -USR2 -f wallp
    
if you’re sure it will not kill any other process.

### Putting in autostart script

A live example can be found in [dotfiles](https://github.com/deterenkelt/dotfiles/blob/master/.i3/autostart.sh#L99) repository.
