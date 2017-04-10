// user.js
//
// About this file read http://kb.mozillazine.org/User.js_file
// tl;dr firefox stores actual preferences in pref.js, that is not to be
// edited amnually. Eerase user.js and use about:config to track what’s
// changed, if you want modified preferences back.

//
// ---- PERSONAL FAVOURITE ------------------------------------------------------
//

// Try to automatically resotre tabs after a crash.
// The number means how many consecutive crashes(?) should be automatically
//   resored, but the default value of 1 isn’t working.
// "2" isn’t working either, seems like this feature is broken.
//user_pref("browser.sessionstore.max_resumed_crashes", 2);
user_pref("mousewheel.acceleration.factor", 1);
user_pref("mousewheel.default.delta_multiplier_y", 270);
user_pref("network.dns.disableIPv6", true);
// Disable old plugin warning – sometimes the window with buttons
// to temoporarily or permanently allow flash on this site is shown
// cut with only ~30px of the left part shown or it is not shown at all.
user_pref("extensions.blocklist.enabled", false);
user_pref("general.warnOnAboutConfig", false);
//user_pref("general.useragent.override", "Mozilla/5.0 (X11; Linux x86_64; rv:39.0) Gecko/20100101 Firefox/39.0. Please read a personal appeal from the owner of this browser: ‘Install gentoo, you fat fuck!’");
user_pref("browser.urlbar.clickSelectsAll", false);
user_pref("network.standard-url.escape-utf8", false);
// Number of pages firefox keeps prepared to display from the tab history
user_pref("browser.sessionhistory.max_total_viewers", 1);
// When there are many tabs, that slows down firefox
user_pref("browser.tabs.animate", false);
// Disable SpeedDial, eating CPU time and slowing down opening of new tabs.
user_pref("browser.newtabpage.enabled", false);
//user_pref("memory.free_dirty_pages", true);
user_pref("layers.acceleration.force-enabled", true);
// FF doesn’t sync these prefs for some reason…
user_pref("font.default.x-cyrillic", "sans-serif");
user_pref("font.default.x-western", "sans-serif");
user_pref("font.language.group", "ja");
user_pref("font.minimum-size.ja", 16);
user_pref("font.minimum-size.x-cyrillic", 14);
user_pref("font.minimum-size.x-western", 14);
user_pref("font.name.monospace.ja", "Ricty");
user_pref("font.name.monospace.x-cyrillic", "DejaVu Sans Mono");
user_pref("font.name.monospace.x-western", "DejaVu Sans Mono");
user_pref("font.name.sans-serif.ja", "IPAMonaPGothic");
user_pref("font.name.sans-serif.x-cyrillic", "PT Sans");
user_pref("font.name.sans-serif.x-western", "PT Sans");
user_pref("font.name.serif.ja", "IPAMonaPGothic");
user_pref("font.name.serif.x-cyrillic", "Linux Libertine Display O");
user_pref("font.name.serif.x-western", "Linux Libertine Display O");
user_pref("font.size.variable.ja", 22);
user_pref("browser.chrome.toolbar_tips", false);
user_pref("layout.css.grid.enabled", true);
//Enable multiprocessing.
user_pref("extensions.e10sBlockedByAddons", true);
user_pref("extensions.e10sBlocksEnabling",true);

//
// --- CACHES ----------------------------------------------------------------
//

// Disable disk cache, cause it slows things down
user_pref("browser.cache.disk.capacity", 1048576);
user_pref("browser.cache.disk.enable", false);
user_pref("browser.cache.disk.smart_size.enabled", true);
user_pref("browser.cache.disk_cache_ssl", false);
// Dollchan Extenstion requires more than default 5 MiB to work properly, if browser works for weeks
user_pref("dom.storage.default_quota", 51200);
// Streaming videos needs at least some space to play smoothly.
user_pref("media.cache_size", 51200);
// Cache in memory, in KiB
user_pref("browser.cache.memory.capacity", 524288);
// Equal to what disk.cache.max_entry_size offers by default
user_pref("browser.cache.memory.max_entry_size", 51200);

//
// --- MEDIA ----------------------------------------------------------------
//

user_pref("media.autoplay.enabled", true);
user_pref("media.gstreamer.enabled", true);
// Works on Linux in v38
user_pref("media.mediasource.enabled", true);
user_pref("media.mediasource.mp4.enabled", true);
user_pref("media.mediasource.webm.enabled", true);
user_pref("media.fragmented-mp4.enabled", true);
user_pref("media.fragmented-mp4.exposed", true);
user_pref("media.fragmented-mp4.ffmpeg.enabled", true);
// Disable download of OpenH264 codec by Cisco (GStreamer will be used instead)
user_pref("media.gmp-gmpopenh264.provider.enabled", false);
user_pref("media.gmp-gmpopenh264.autoupdate", false);
user_pref("media.gmp-gmpopenh264.enabled", false);
user_pref("media.gmp-provider.enabled", false);
user_pref("media.gmp-manager.url", "");
user_pref("media.gmp-manager.certs.1.commonName", "");
user_pref("media.gmp-manager.certs.2.commonName", "");
// Disable Web Speech API used for speech recognition and sythesizing.
user_pref("media.webspeech.recognition.enable", false);
user_pref("media.webspeech.synth.enabled", false);
// Forbid use of WebRTC protocol, current implementation of which lets getting the list of IP addresses in LAN imperceptibly for the user. Also real IP behind Tor can be exposed with this. Breaks Firefox Hello
user_pref("media.peerconnection.enabled", false);
user_pref("media.peerconnection.identity.enabled", false);
user_pref("media.peerconnection.video.enabled", false);
user_pref("media.peerconnection.video.h264_enabled", false);
user_pref("media.peerconnection.turn.disable", true);
user_pref("media.peerconnection.default_iceservers", "");
user_pref("media.peerconnection.use_document_iceservers", false);
// Disable getUserMedia API that’s used to record sound from the mic, image from the camera and for screen sharing. Breaks Firefox Hello
user_pref("media.navigator.enabled", false);
user_pref("media.navigator.video.enabled", false);
user_pref("media.navigator.permission.disabled", false);
user_pref("media.getusermedia.browser.enabled", false);
user_pref("media.getusermedia.screensharing.allow_on_old_platforms", false);
user_pref("media.getusermedia.screensharing.allowed_domains", "");
user_pref("media.getusermedia.screensharing.enabled", false);

//
// --- REMOVE USELESS ----------------------------------------------------------------
//

// Disable Mozilla’s antitracjing list that duplicates uBlock function
// and is less effective (due to being based on the list from Disconnect).
// https://support.mozilla.org/en-US/kb/tracking-protection-firefox
// https://wiki.mozilla.org/Polaris
// https://hg.mozilla.org/releases/mozilla-beta/file/00bcc10b3bdc/browser/base/content/browser-trackingprotection.js
user_pref("privacy.trackingprotection.enabled", false);
user_pref("privacy.trackingprotection.pbmode.enabled", false);
user_pref("browser.trackingprotection.updateURL", "");
user_pref("browser.trackingprotection.gethashURL", "");
user_pref("browser.polaris.enabled", false);
user_pref("privacy.trackingprotection.introURL", "");

// d:15000
user_pref("browser.sessionstore.interval", 60000);

// Disable prefetch for the links on the page (firefox thinks you may want click on)
user_pref("network.prefetch-next", false);
// …as well as prefetching their actual addresses
user_pref("network.dns.disablePrefetch", true);
// …and host prefetch for them
user_pref("network.http.speculative-parallel-limit", 0);

// Disable ‘go back’ behaviour for backspace key
user_pref("browser.backspace_action", 0);

// Disable semitransparent preview image for a tab that is hanging while it’s being dragged near the cursor and messing with moving it to the right place
user_pref("nglayout.enable_drag_images", false);

// Disable the Predictor (aka Seer) — a mechanism for remembering dependencies between domains from which content is requested for an URL
user_pref("network.predictor.enabled", false);

// network.predictor.max-db-size must be set to 0, or there will appear a database of visited sites in the profile folder, despite that network.predictor.enabled is disabled.
user_pref("network.predictor.max-db-size", 0);

//Disable Google Safebrowsing. It could be left as it as unless they only were giving hash base for malware URLs and browser checked up with its local copy. But now Google makes it send hashes of every file downloaded by the user (for the so calles check for viruses), that is frankly unacceptable. For those who’s concerned, there is subscription for Malware Domains for AdBlock Plus that includes  URLs from Safebrowsing and doesn’t track user’s moves.
user_pref("browser.safebrowsing.enabled", false);
user_pref("browser.safebrowsing.malware.enabled", false);
user_pref("browser.safebrowsing.downloads.enabled", false);
user_pref("browser.safebrowsing.downloads.remote.enabled", false);
user_pref("browser.safebrowsing.appRepURL", "");
user_pref("browser.safebrowsing.gethashURL", "");
user_pref("browser.safebrowsing.malware.reportURL", "");
user_pref("browser.safebrowsing.reportErrorURL", "");
user_pref("browser.safebrowsing.reportGenericURL", "");
user_pref("browser.safebrowsing.reportMalwareErrorURL", "");
user_pref("browser.safebrowsing.reportMalwareURL", "");
user_pref("browser.safebrowsing.reportPhishURL", "");
user_pref("browser.safebrowsing.reportURL", "");
user_pref("browser.safebrowsing.updateURL", "");

// Forbid sites to connect to important ports occupied by Tor, torrents, i2p…
user_pref("network.security.ports.banned", "4444,9050,9051");

// Disable <a ping> that sends a request to a certain address (with the purpose of tracking) on click
user_pref("browser.send_pings", false);
// Disable sendBeacon() — an API for sending statistics  before unloading pages
user_pref("beacon.enabled", false);

// Disable addition to SpeedDial sponsors of Mozilla
user_pref("browser.newtabpage.directory.ping", "");
user_pref("browser.newtabpage.directory.source", "");
user_pref("browser.newtabpage.enhanced", false);

// Disables downloadingof Mozilla services ads (Sync, Hello, версий для Android) in about:home https://wiki.mozilla.org/Websites/Snippets
user_pref("browser.aboutHomeSnippets.updateUrl", "");

// Disable automatic opening of a tab with description of changes in the new version after update
user_pref("browser.startup.homepage_override.mstone", "ignore");

// Disable showing of AMO in Add-ons manager
user_pref("extensions.webservice.discoverURL", "");

// Disable telemetry.
user_pref("datareporting.healthreport.service.enabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.policy.dataSubmissionPolicyAccepted", false);
user_pref("datareporting.policy.dataSubmissionPolicyBypassAcceptance", false);
user_pref("datareporting.healthreport.about.reportUrl", "");
user_pref("datareporting.healthreport.documentServerURI", "");
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.server", "");

// Disable suggestion to rate how well Firefox runs and send a donation to Mozilla https://wiki.mozilla.org/Advocacy/heartbeat
user_pref("browser.selfsupport.url", "");

// Disable integrated support of Pocket proprietary service of bookmarks. http://www.opennet.ru/opennews/art.shtml?num=42245 https://wiki.mozilla.org/QA/Pocket_integration
user_pref("browser.pocket.enabled", false);
//// api.getpocket.com // ""
user_pref("browser.pocket.api", "");
//// getpocket.com
user_pref("browser.pocket.site", "");
//// 40249-e88c401e1b1f2242d9e441c4
user_pref("browser.pocket.oAuthConsumerKey", "");
//// en-GB ru
user_pref("browser.pocket.enabledLocales", "");

// Disable collection of statistics for effectiveness rating of current values of DNS TTL.
// Removed in v36.
// user_pref("dns.ttl-experiment.enabled", false);
// Disable the rest of experiments with the user
user_pref("network.allow-experiments", false);
user_pref("experiments.enabled", false);
user_pref("experiments.supported", false);
user_pref("experiments.manifest.uri", "");
user_pref("experiments.activeExperiment", false);

// Forbid popups to modify window elements
user_pref("dom.popup_maximum", 5);
user_pref("dom.disable_open_during_load", true);
user_pref("dom.allow_scripts_to_close_windows", false);
user_pref("dom.disable_window_move_resize", true);
user_pref("dom.disable_window_flip", true);
user_pref("dom.disable_window_status_change", true);
user_pref("dom.disable_window_open_feature.close", true);
user_pref("dom.disable_window_open_feature.location", true);
user_pref("dom.disable_window_open_feature.menubar", true);
user_pref("dom.disable_window_open_feature.minimizable", true);
user_pref("dom.disable_window_open_feature.personalbar", true);
user_pref("dom.disable_window_open_feature.resizable", true);
user_pref("dom.disable_window_open_feature.scrollbars", true);
user_pref("dom.disable_window_open_feature.status", true);
user_pref("dom.disable_window_open_feature.titlebar", true);
user_pref("dom.disable_window_open_feature.toolbar", true);

// Disable collection of statistics related to decoding performance of HTML5 video
user_pref("media.video_stats.enabled", false);

// Disable Social API
user_pref("social.enabled", false);
user_pref("social.remote-install.enabled", false);
user_pref("social.toast-notifications.enabled", false);
user_pref("social.directories", "");
user_pref("social.whitelist", "");
user_pref("social.share.activationPanelEnabled", false);
user_pref("social.shareDirectory", "");

// Disable Reading List that is ported from Android version https://wiki.mozilla.org/CloudServices/Reading_List
user_pref("browser.readinglist.enabled", false);
user_pref("browser.readinglist.sidebarEverOpened", false);
user_pref("readinglist.scheduler.enabled", false);
user_pref("readinglist.server", "");
// Disable REader View https://wiki.mozilla.org/QA/Reader_view
user_pref("reader.parse-on-load.enabled", false);
user_pref("reader.parse-on-load.force-enabled", false);

// Disable geolocation via Google with acquiring a unique ID and giving to them information about Wi-Fi spots nearby
user_pref("geo.enabled", true);
user_pref("geo.wifi.logging.enabled", false);
user_pref("geo.wifi.uri", "");
user_pref("browser.search.geoip.timeout", 0);
user_pref("browser.search.geoip.url", "");

// Disable beforeunload event on which some pages place messages like ‘Do you really want to move from this site?’
user_pref("dom.disable_beforeunload", true);

// Forbid battery status tracking
user_pref("dom.battery.enabled", false);

// Disable ImageCapture API for taking shots from webcamera
user_pref("dom.imagecapture.enabled", false);

// Disable Resource Timing API (acquiring information about speed at which elements of the page are being processed).
user_pref("dom.enable_resource_timing", false);
// Disable Vibration API.
user_pref("dom.vibrator.enabled", false);
// Disable acquiring info from acceleromenters and other sensors
user_pref("device.sensors.enabled", false);

// Disable User Timing API — access to a high-res timer with the help of which code running through the CPU can be exposed via some JS vulnerability
// http://www.html5rocks.com/en/tutorials/webperformance/usertiming/
// https://www.linux.org.ru/news/security/11541326
// http://arxiv.org/pdf/1502.07373v2.pdf
user_pref("dom.enable_user_timing", false);
user_pref("dom.performance.enable_user_timing_logging", false);

// Disable Firefox Hello.
user_pref("loop.enabled", false);
user_pref("loop.screenshare.enabled", false);
user_pref("loop.rooms.enabled", false);
user_pref("loop.server", "");

// Disable Encrypted Media Extensions support (DRM for HTML5 video).
user_pref("media.eme.enabled", false);
user_pref("media.eme.apiVisible", false);

// Disable automatic update
user_pref("app.update.auto", false);
user_pref("app.update.enabled", false);
user_pref("app.update.mode", 0);
user_pref("app.update.service.enabled", false);

// Disable requests to send to Mozilla reports about errors in sites’ certificates https://bugzilla.mozilla.org/show_bug.cgi?id=846489
user_pref("security.ssl.errorReporting.enabled", false);
user_pref("security.ssl.errorReporting.automatic", false);
user_pref("security.ssl.errorReporting.url", "");

// "As of 2015, there is speculation that some state cryptologic agencies may possess the capability to break RC4 even when used in the TLS protocol. Mozilla and Microsoft recommend disabling RC4 where possible." -- https://en.wikipedia.org/wiki/RC4
user_pref("security.ssl3.ecdhe_ecdsa_rc4_128_sha", false);
user_pref("security.ssl3.ecdhe_rsa_rc4_128_sha", false);
user_pref("security.ssl3.rsa_rc4_128_md5", false);
user_pref("security.ssl3.rsa_rc4_128_sha", false);

// Отключает автоматическое скачивание и установку ADB Helper и аддона для удаленной отладки мобильных
// браузеров при первом запуске WebIDE. Ручная установка через меню WebIDE все еще будет работать.
// https://developer.mozilla.org/en-US/docs/Tools/Valence
user_pref("devtools.webide.autoinstallADBHelper", false);
user_pref("devtools.webide.autoinstallFxdtAdapters", false);
// Отключает авто-подсоединение к предыдущему отлаживаемому устройству/эмулятору при запуске WebIDE.
user_pref("devtools.webide.autoConnectRuntime", false);

// Отключает возможность соединения с устройством на Firefox OS для отладки по Wi-Fi.
// https://wiki.mozilla.org/DevTools/WiFi_Debugging
user_pref("devtools.remote.wifi.scan", false);
user_pref("devtools.remote.wifi.visible", false);

// Отключает команду screenshot --imgur, которая автоматически загружает сделанный скриншот на Imgur.
// https://bugzilla.mozilla.org/show_bug.cgi?id=992386
// https://bugzilla.mozilla.org/show_bug.cgi?id=1173158
// https://hg.mozilla.org/releases/mozilla-beta/file/ab89cbfcd3e6/toolkit/devtools/gcli/commands/screenshot.js#l382
user_pref("devtools.gcli.imgurClientID", "");
user_pref("devtools.gcli.imgurUploadURL", "");

// Отключает скачивание и показ подсказок для свойств CSS с developer.mozilla.org в Developer Tools.
// https://hg.mozilla.org/releases/mozilla-beta/file/7f005a3c9f9d/browser/devtools/styleinspector/test/browser_ruleview_context-menu-show-mdn-docs-03.js#l5
// https://hg.mozilla.org/releases/mozilla-beta/file/14b2376c96fa/browser/devtools/styleinspector/rule-view.js#l1538
// https://hg.mozilla.org/releases/mozilla-beta/file/7f005a3c9f9d/browser/devtools/shared/widgets/MdnDocsWidget.js#l5
user_pref("devtools.inspector.mdnDocsTooltip.enabled", false);

// Отключает рекламу Firefox Developer Edition в Developer Tools.
// https://hg.mozilla.org/releases/mozilla-esr38/file/0f8338121472/browser/devtools/shared/doorhanger.js#l17
user_pref("devtools.devedition.promo.enabled", false);
user_pref("devtools.devedition.promo.shown", true);
user_pref("devtools.devedition.promo.url", "");

// Отключает SSDP, нужный для обнаружения телевизоров и реализации функции Send Video To Device в
// Firefox для Android. Десктопный Firefox тоже почему-то посылал соответствующие мультикаст-запросы.
// https://bugzilla.mozilla.org/show_bug.cgi?id=1111967
// https://support.mozilla.org/en-US/kb/use-firefox-android-send-videos-chromecast
// https://trac.torproject.org/projects/tor/ticket/16222
// https://support.mozilla.org/en-US/kb/how-stop-firefox-making-automatic-connections#w_send-video-to-device
user_pref("browser.casting.enabled", false);

// Отключает передачу по сети рисуемых браузером кадров специальному отладочному вьюверу.
// https://wiki.mozilla.org/Platform/GFX/LayerScope
// https://trac.torproject.org/projects/tor/ticket/16222#comment:8
// https://hg.mozilla.org/releases/mozilla-esr38/file/a20c7910a82f/gfx/thebes/gfxPrefs.h#l208
// https://hg.mozilla.org/releases/mozilla-esr38/file/a20c7910a82f/gfx/layers/LayerScope.cpp#l1243
user_pref("gfx.layerscope.enabled", false);
// https://hg.mozilla.org/releases/mozilla-esr38/file/a20c7910a82f/gfx/thebes/gfxPrefs.h#l209
// https://hg.mozilla.org/releases/mozilla-esr38/file/a20c7910a82f/gfx/layers/LayerScope.cpp#l1202
// https://hg.mozilla.org/releases/mozilla-esr38/file/a20c7910a82f/netwerk/base/nsServerSocket.cpp#l281
user_pref("gfx.layerscope.port", 100000);
