### i3 WM configuration

#### Features of this config

* it is set up to use `urxvtc` instead of `dmenu`, which cannot switch locale for itself to english, cannot use aliases, cannot… it’s just ugliness itself;
* launches bound application when switching on an empty workspace;
* has a set of [scripts](https://github.com/deterenkelt/scripts) bound to keys;
* uses json output produced by [bash script](generate-text-for-i3bar) to feed i3bar, its output is profile-based and may contain data, produced by the varoius functions

  * active window name, which i3 is lacking;
  * free and total space per partition (partition list is editable)

      ![disk_space_usual](img/disk_space_usual.png) – usual look.

      ![disk_space_low](img/disk_space_low.png) – low value of free space.

      ![disk_space_extremely_low](img/disk_space_extremely_low.png) – extremely low value of free space.

  * music player daemon (MPD) state;
  * battery status;

      ![charging](img/bat_charging.png) – when power cords is plugged.

      ![discharging](img/bat_discharging.png) – when battery is used up.

      ![fading](img/bat_fading.png) – each block has 5 stages of fading, which gives 25 states with 5 blocks on the screen.

      ![low_level](img/bat_low_level.png) – at low level

      ![extremely_low_level](img/bat_extremely_low_level.png) – battery is about to be completely discharged, but mine after two years of almost daily usage could give **30 minutes** of idle state. Script throws a confirmation to shutdown, which can be declined.

      ![ejected](img/bat_ejected.png) – when battery is ejected.

  * internet status;
  * gmail status

      ![new_letter](img/new_letter.png) – new unread letter. Also pauses mpd at the time of event and plays notification.

      ![server_unavailable](img/server_unavailable.png) – when gmail server is unaccessible.

      ![server_error](img/server_error.png) – server reply returned an error.

      ![net_is_unavailable](img/net_is_unavailable.png) – when it has no access to internet. 
