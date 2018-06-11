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
// Prevent Firefox from leaking DNS requests
user_pref("network.proxy.socks_remote_dns", true);
user_pref("network.dns.disablePrefetchFromHTTPS", true);
user_pref("network.dns.disableIPv6", true);
// …and IP leaking through WebRTC
user_pref("media.peerconnection.enabled", false);
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
user_pref("browser.sessionstore.max_resumed_crashes",3);
user_pref("toolkit.startup.max_resumed_crashes",3);
// %D0%9B%D0%B8%D1%81 -> Лис
user_pref("browser.urlbar.decodeURLsOnCopy", true);
// Минимальный интервал в миллисекундах для записи изменений в сессии на диск. Дефолтные 15 секунд -
// маловато, особенно для мегабайтных сессий.
user_pref("browser.sessionstore.interval", 60000);
// Интервал отсутствия активности пользователя, через который браузер начнет сохранять сессию не
// чаще чем раз в час (см. browser.sessionstore.interval.idle).
// https://hg.mozilla.org/releases/mozilla-release/rev/4d8192b5ac7e
user_pref("browser.sessionstore.idleDelay", 720000);
// Отключает автоматическую отправку поисковику недопечатанного запроса по мере его набора,
// используемую для формирования поисковых подсказок.
user_pref("browser.search.suggest.enabled", false);
user_pref("browser.urlbar.suggest.searches", false);
// Отключает предложение включить поисковые подсказки. Должно быть true.
// https://hg.mozilla.org/releases/mozilla-beta/file/00bcc10b3bdc/toolkit/components/telemetry/docs/environment.rst#l301
// https://hg.mozilla.org/releases/mozilla-beta/file/00bcc10b3bdc/browser/base/content/urlbarBindings.xml#l953
// https://hg.mozilla.org/releases/mozilla-beta/file/00bcc10b3bdc/browser/base/content/urlbarBindings.xml#l1201
user_pref("browser.urlbar.userMadeSearchSuggestionsChoice", true);
// https://hg.mozilla.org/releases/mozilla-release/file/c1de04f39fa956cfce83f6065b0e709369215ed5/browser/base/content/urlbarBindings.xml#l957
// https://hg.mozilla.org/releases/mozilla-release/file/c1de04f39fa956cfce83f6065b0e709369215ed5/browser/base/content/urlbarBindings.xml#l1310
user_pref("browser.urlbar.daysBeforeHidingSuggestionsPrompt", 0);
user_pref("pdfjs.enableWebGL", true);

//  Enable multiprocessing.
user_pref("extensions.e10sBlocksEnabling", false);
user_pref("extensions.e10sBlockedByAddons", false);
//  Show sensible connection error pages.
user_pref("browser.xul.error_pages.expert_bad_cert", true);

// Allow sending multiple requests to server simultaneously
user_pref("network.http.pipelining", true);
user_pref("network.http.pipelining.ssl", true);

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

// No autoplay in tabs until selected.
user_pref("media.block-autoplay-until-in-foreground", true);
// Запрещает проигрывание HTML5-медиа до нажатия на кнопку play. Теперь работает и на YouTube.
// Следующие видео из плейлиста будут проигрываться автоматически после окончания первого.
// Автобуферизацию не предотвращает.
user_pref("media.autoplay.enabled", false);
user_pref("media.gstreamer.enabled", true);

// Works on Linux in v38
user_pref("media.mediasource.enabled", true);
user_pref("media.mediasource.mp4.enabled", true);
// VP9 is a shit codec that makes FF eat CPU.
// Disabling it here in favour of x264 doesn’t break usual webm playback.
user_pref("media.mediasource.webm.enabled",false);
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

// Отключает предзагрузку ссылок, на которые по мнению браузера вы собираетесь кликнуть.
// https://developer.mozilla.org/en-US/docs/Web/HTTP/Link_prefetching_FAQ
// https://support.mozilla.org/en-US/kb/how-stop-firefox-making-automatic-connections#w_link-prefetching
user_pref("network.prefetch-next", false);
// И предварительный резолвинг их доменов тоже.
// https://developer.mozilla.org/en-US/docs/Web/HTTP/Controlling_DNS_prefetching
// https://support.mozilla.org/en-US/kb/how-stop-firefox-making-automatic-connections#w_dns-prefetching
user_pref("network.dns.disablePrefetch", true);
// https://hg.mozilla.org/releases/mozilla-esr38/file/96e6f9392598/dom/html/nsHTMLDNSPrefetch.cpp#l64
user_pref("network.dns.disablePrefetchFromHTTPS", true);
// И предварительный коннект к хостам.
// https://bugzilla.mozilla.org/show_bug.cgi?id=814169
// https://support.mozilla.org/en-US/kb/how-stop-firefox-making-automatic-connections#w_speculative-pre-connections
user_pref("network.http.speculative-parallel-limit", 0);

// Disable ‘go back’ behaviour for backspace key
user_pref("browser.backspace_action", 0);

// Disable semitransparent preview image for a tab that is hanging while it’s being dragged near the cursor and messing with moving it to the right place
user_pref("nglayout.enable_drag_images", false);

// Отключает Predictor (бывший Seer) - механизм, запоминающий связи между хостами, с которых
// запрашивается контент для того или иного URL (например, основным хостом и хостом со статикой),
// и при следующем подключении заранее соединяющийся со всеми хостами, которые понадобятся.
// https://wiki.mozilla.org/Privacy/Reviews/Necko
// https://hg.mozilla.org/releases/mozilla-esr45/file/87a22e023b10fc3116f333e313934d38cd533ce0/netwerk/base/Predictor.cpp#l73
user_pref("network.predictor.enabled", false);
// https://hg.mozilla.org/releases/mozilla-esr45/file/87a22e023b10fc3116f333e313934d38cd533ce0/netwerk/base/Predictor.cpp#l972
user_pref("network.predictor.enable-hover-on-ssl", false);
// Начиная с Firefox 48, Predictor умеет не только предконнекты, но и префетч.
// https://bugzilla.mozilla.org/show_bug.cgi?id=1016628
// https://bugzilla.mozilla.org/show_bug.cgi?id=1271944
// https://hg.mozilla.org/releases/mozilla-release/file/c1de04f39fa956cfce83f6065b0e709369215ed5/netwerk/base/Predictor.cpp#l1301
user_pref("network.predictor.enable-prefetch", false);
user_pref("network.predictor.prefetch-rolling-load-count", 0);
// https://hg.mozilla.org/releases/mozilla-release/file/c1de04f39fa956cfce83f6065b0e709369215ed5/netwerk/base/Predictor.cpp#l1132
// https://hg.mozilla.org/releases/mozilla-release/file/c1de04f39fa956cfce83f6065b0e709369215ed5/netwerk/test/unit/test_predictor.js#l405
user_pref("network.predictor.prefetch-min-confidence", 101);
user_pref("network.predictor.preconnect-min-confidence", 101);
user_pref("network.predictor.preresolve-min-confidence", 101);

// Запрещает сайтам установку соединений на критически важные порты, занятые I2P и Tor.
user_pref("network.security.ports.banned", "4444,9050,9051");

// Отключает Google Safebrowsing. Раньше можно было еще не отключать, пока они только отдавали базу
// хэшей малварных URL и браузер сверялся с локальной копией. Но сейчас Гугл заставляет посылать хэш
// каждого загружаемого пользователем файла (якобы для проверки на вирусы), что уже совершенно
// неприемлемо. Желающие могут установить себе подписку Malware Domains для uBlock Origin, которая
// включает в себя URL из Safebrowsing и не следит за пользователем.
// Обращения к Safebrowsing могли создать специальную куку PREF для домена google.com, которая
// _не удаляется_ через менеджер кук браузера из-за бага и содержит идентификатор пользователя.
// Поэтому, если Safebrowsing ранее был включен в этом профиле, после его отключения необходимо
// вручную удалить cookies.sqlite из профиля, или подчистить эту БД каким-либо SQLite-редактором.
// https://bugzilla.mozilla.org/show_bug.cgi?id=1008706
// https://bugzilla.mozilla.org/show_bug.cgi?id=1026538
// https://bugzilla.mozilla.org/show_bug.cgi?id=1186772
// https://blog.mozilla.org/security/2014/07/23/improving-malware-detection-in-firefox/
// https://support.mozilla.org/en-US/kb/how-stop-firefox-making-automatic-connections#w_anti-phishing-list-updating
user_pref("browser.safebrowsing.enabled", false);
// https://support.mozilla.org/en-US/kb/how-stop-firefox-making-automatic-connections#w_anti-malware-list-updating
user_pref("browser.safebrowsing.malware.enabled", false);
user_pref("browser.safebrowsing.downloads.enabled", false);
user_pref("browser.safebrowsing.downloads.remote.enabled", false);
user_pref("browser.safebrowsing.downloads.remote.url", "");
// https://support.mozilla.org/en-US/kb/how-stop-firefox-making-automatic-connections#w_anti-malware-list-updating
user_pref("browser.safebrowsing.appRepURL", "");
user_pref("browser.safebrowsing.gethashURL", "");
user_pref("browser.safebrowsing.malware.reportURL", "");
user_pref("browser.safebrowsing.reportPhishURL", "");
user_pref("browser.safebrowsing.updateURL", "");
user_pref("browser.safebrowsing.reportPhishMistakeURL", "");
user_pref("browser.safebrowsing.reportMalwareMistakeURL", "");
user_pref("browser.safebrowsing.provider.google.appRepURL", "");
user_pref("browser.safebrowsing.provider.google.gethashURL", "");
user_pref("browser.safebrowsing.provider.google.lists", "");
user_pref("browser.safebrowsing.provider.google.reportURL", "");
user_pref("browser.safebrowsing.provider.google.updateURL", "");
user_pref("browser.safebrowsing.downloads.remote.block_dangerous", false);
user_pref("browser.safebrowsing.downloads.remote.block_dangerous_host", false);
user_pref("browser.safebrowsing.downloads.remote.block_potentially_unwanted", false);
user_pref("browser.safebrowsing.downloads.remote.block_uncommon", false);
// https://bugzilla.mozilla.org/show_bug.cgi?id=1025965
user_pref("browser.safebrowsing.phishing.enabled", false);
user_pref("browser.safebrowsing.provider.google4.lists", "");
user_pref("browser.safebrowsing.provider.google4.updateURL", "");
user_pref("browser.safebrowsing.provider.google4.gethashURL", "");
user_pref("browser.safebrowsing.provider.google4.reportURL", "");
user_pref("browser.safebrowsing.provider.google.reportMalwareMistakeURL", "");
user_pref("browser.safebrowsing.provider.google.reportPhishMistakeURL", "");
user_pref("browser.safebrowsing.provider.google4.reportMalwareMistakeURL", "");
user_pref("browser.safebrowsing.provider.google4.reportPhishMistakeURL", "");

// Отключает мозилловский анти-трекинговый список, который дублирует функции uBlock с соответствующими
// подписками и является менее эффективным (т.к. основан на списке от Disconnect).
// https://support.mozilla.org/en-US/kb/tracking-protection-firefox
// https://wiki.mozilla.org/Polaris
// https://hg.mozilla.org/releases/mozilla-beta/file/00bcc10b3bdc/browser/base/content/browser-trackingprotection.js
user_pref("privacy.trackingprotection.enabled", false);
user_pref("privacy.trackingprotection.pbmode.enabled", false);
user_pref("browser.polaris.enabled", false);
user_pref("privacy.trackingprotection.introURL", "");
// https://hg.mozilla.org/releases/mozilla-release/file/970d0cf1c5d9/browser/components/preferences/in-content/privacy.js#l19
user_pref("privacy.trackingprotection.ui.enabled", false);
// https://hg.mozilla.org/releases/mozilla-beta/file/00bcc10b3bdc/browser/base/content/browser-trackingprotection.js#l6
//user_pref("privacy.trackingprotection.introCount", 1);
user_pref("browser.safebrowsing.provider.mozilla.lists", "");
user_pref("browser.safebrowsing.provider.mozilla.updateURL", "");
user_pref("browser.safebrowsing.provider.mozilla.gethashURL", "");

// Вообще не регистрировать таблицы Safebrowsing и Tracking Protection в URL Classifier, пусть даже
// в отключенном виде и с пустыми URL для обновления.
// https://hg.mozilla.org/releases/mozilla-release/file/6f3151d4ff03/toolkit/components/url-classifier/SafeBrowsing.jsm
// https://hg.mozilla.org/releases/mozilla-release/file/326bab27cc3c/toolkit/components/url-classifier/nsIUrlListManager.idl#l29
// https://hg.mozilla.org/releases/mozilla-release/file/76c0924aea88/toolkit/components/url-classifier/content/listmanager.js#l88
user_pref("urlclassifier.malwareTable", "");
user_pref("urlclassifier.phishTable", "");
user_pref("urlclassifier.downloadBlockTable", "");
user_pref("urlclassifier.downloadAllowTable", "");
user_pref("urlclassifier.trackingTable", "");
user_pref("urlclassifier.trackingWhitelistTable", "");
user_pref("urlclassifier.disallow_completions", "");

// Отключает белый список доменов для Flash. Флэш-контент будет разрешен везде.
// https://bugzilla.mozilla.org/show_bug.cgi?id=1307604
// https://hg.mozilla.org/releases/mozilla-release/file/175e28ba58fcd249fc2db68dcaa800da2ebc506d/toolkit/components/url-classifier/flash-block-lists.rst
// https://hg.mozilla.org/releases/mozilla-release/rev/81b9af9143f3
// https://hg.mozilla.org/releases/mozilla-release/rev/81b9af9143f3#l2.102
user_pref("plugins.flashBlock.enabled", false);
user_pref("urlclassifier.flashAllowTable", "");
user_pref("urlclassifier.flashAllowExceptTable", "");
user_pref("urlclassifier.flashTable", "");
user_pref("urlclassifier.flashExceptTable", "");
user_pref("urlclassifier.flashSubDocTable", "");
user_pref("urlclassifier.flashSubDocExceptTable", "");
user_pref("urlclassifier.flashInfobarTable", "");

// Отключает список сайтов, запрещенных в режиме ограниченного профиля / родительского контроля.
// https://bugzilla.mozilla.org/show_bug.cgi?id=1216723
// https://bugzilla.mozilla.org/show_bug.cgi?id=1222377
user_pref("browser.safebrowsing.forbiddenURIs.enabled", false);
user_pref("urlclassifier.forbiddenTable", "");

// Отключает <a ping>, которые отправляют запрос по отдельному указанному адресу (с целью трекинга)
// при нажатии на ссылку. -- http://kb.mozillazine.org/Browser.send_pings
// https://hg.mozilla.org/releases/mozilla-esr45/file/87a22e023b10fc3116f333e313934d38cd533ce0/docshell/base/nsDocShell.cpp#l294
// https://hg.mozilla.org/releases/mozilla-esr45/file/87a22e023b10fc3116f333e313934d38cd533ce0/docshell/base/nsDocShell.cpp#l635
user_pref("browser.send_pings", false);
user_pref("browser.send_pings.max_per_link", 0);
user_pref("browser.send_pings.require_same_host", true);
// Отключает sendBeacon() - API для отправки статистики перед выгрузкой страницы.
// https://developer.mozilla.org/en-US/docs/Web/API/navigator.sendBeacon
user_pref("beacon.enabled", false);

// Отключает добавление сайтов из Alexa Top 500 в список автодополнения адресной строки при запуске
// нового профиля с пустой историей.
// https://bugzilla.mozilla.org/show_bug.cgi?id=1340663
// https://bugzilla.mozilla.org/show_bug.cgi?id=1211726
// https://bugzilla.mozilla.org/show_bug.cgi?id=1336946
// https://hg.mozilla.org/releases/mozilla-release/rev/1bf558a9bf87
// https://hg.mozilla.org/releases/mozilla-release/rev/139038cf6a9c
user_pref("browser.urlbar.usepreloadedtopurls.enabled", false);

// Отключает новую версию new tab page, которая будет подгружаться с сервера Мозиллы. [Фича еще не
// готова и не включена по умолчанию.] Сделано это якобы для того, чтобы разработчики могли
// экспериментировать с функциональностью этой страницы чаще чем происходят релизы браузера.
// https://bugzilla.mozilla.org/show_bug.cgi?id=1176429
// https://bugzilla.mozilla.org/show_bug.cgi?id=1246202
// https://wiki.mozilla.org/TPE_SecEng/Content_Signing_for_Remote_New_Tab
// https://github.com/mozilla/remote-newtab
// https://hg.mozilla.org/releases/mozilla-release/file/b0310cb90fd0/browser/components/newtab/aboutNewTabService.js#l48
// https://hg.mozilla.org/releases/mozilla-release/file/b0310cb90fd0/browser/components/newtab/aboutNewTabService.js#l108
user_pref("browser.newtabpage.remote", false);
// https://hg.mozilla.org/releases/mozilla-release/file/b0310cb90fd0/browser/components/newtab/NewTabRemoteResources.jsm
// https://hg.mozilla.org/releases/mozilla-release/file/b0310cb90fd0/browser/components/newtab/aboutNewTabService.js#l160
user_pref("browser.newtabpage.remote.mode", "dev");
// https://hg.mozilla.org/releases/mozilla-release/file/c1de04f39fa956cfce83f6065b0e709369215ed5/browser/components/newtab/aboutNewTabService.js#l182
user_pref("browser.newtabpage.remote.content-signing-test", false);
// Remote New Tab переименована в Activity Stream в Firefox 54.
// https://hg.mozilla.org/releases/mozilla-release/rev/e393e6c239cd
user_pref("browser.newtabpage.activity-stream.enabled", false);

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

// Отключает телеметрию.
// https://support.mozilla.org/en-US/kb/firefox-health-report-understand-your-browser-perf
// https://support.mozilla.org/en-US/kb/how-stop-firefox-making-automatic-connections#w_diagnostics
user_pref("datareporting.healthreport.service.enabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
// https://hg.mozilla.org/releases/mozilla-beta/file/00bcc10b3bdc/services/datareporting/policy.jsm#l366
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled.v2", false);
// https://bugzilla.mozilla.org/show_bug.cgi?id=1324049
// https://hg.mozilla.org/releases/mozilla-release/rev/03358dc42d00
user_pref("datareporting.policy.firstRunURL", "");
user_pref("datareporting.healthreport.about.reportUrl", "");
user_pref("datareporting.healthreport.about.reportUrlUnified", "");
user_pref("datareporting.healthreport.documentServerURI", "");
// https://www.mozilla.org/en-US/privacy/firefox/#telemetry
// https://wiki.mozilla.org/Privacy/Reviews/Telemetry
// https://wiki.mozilla.org/Security/Reviews/Firefox6/ReviewNotes/telemetry
// https://wiki.mozilla.org/Telemetry/Testing#Browser_Prefs
// https://dxr.mozilla.org/mozilla-release/source/toolkit/components/telemetry/docs/internals/preferences.rst
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.server", "");
user_pref("toolkit.telemetry.archive.enabled", false);
// https://wiki.mozilla.org/Unified_Telemetry
user_pref("toolkit.telemetry.unified", false);
// Это должно быть true.
// https://hg.mozilla.org/releases/mozilla-beta/file/0f8e1375f717/toolkit/components/telemetry/TelemetryController.jsm#l669
user_pref("toolkit.telemetry.unifiedIsOptIn", true);
// https://hg.mozilla.org/releases/mozilla-beta/file/0f8e1375f717/browser/app/profile/firefox.js#l1904
// https://hg.mozilla.org/releases/mozilla-beta/file/0f8e1375f717/toolkit/components/telemetry/TelemetryController.jsm#l628
user_pref("toolkit.telemetry.optoutSample", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
// Отключает отправку информации о падениях браузера в Mozilla (about:crashes).
user_pref("breakpad.reportURL", "");
user_pref("dom.ipc.plugins.flash.subprocess.crashreporter.enabled", false);
user_pref("dom.ipc.plugins.reportCrashURL", false);
// about:tabcrashed
// https://bugzilla.mozilla.org/show_bug.cgi?id=1110511
// https://hg.mozilla.org/releases/mozilla-release/file/7eabe4d30cde/browser/modules/ContentCrashReporters.jsm#l141
// https://hg.mozilla.org/releases/mozilla-release/file/7eabe4d30cde/browser/base/content/aboutTabCrashed.js#l31
// https://hg.mozilla.org/releases/mozilla-release/file/7eabe4d30cde/browser/base/content/browser.js#l1159
user_pref("browser.tabs.crashReporting.sendReport", false);
user_pref("browser.tabs.crashReporting.includeURL", false);
user_pref("browser.tabs.crashReporting.emailMe", false);
user_pref("browser.tabs.crashReporting.email", "");
// https://bugzilla.mozilla.org/show_bug.cgi?id=1287178
// https://hg.mozilla.org/releases/mozilla-release/file/a67a1682be8f0327435aaa2f417154330eff0017/browser/modules/ContentCrashHandlers.jsm#l383
user_pref("browser.crashReports.unsubmittedCheck.enabled", false);
// https://hg.mozilla.org/releases/mozilla-release/rev/c94848691f8a
user_pref("browser.crashReports.unsubmittedCheck.autoSubmit", false);
// https://hg.mozilla.org/releases/mozilla-release/file/a67a1682be8f0327435aaa2f417154330eff0017/browser/modules/ContentCrashHandlers.jsm#l511
user_pref("browser.crashReports.unsubmittedCheck.chancesUntilSuppress", 0);

// Disable suggestion to rate how well Firefox runs and send a donation to Mozilla https://wiki.mozilla.org/Advocacy/heartbeat
user_pref("browser.selfsupport.url", "");
user_pref("browser.selfsupport.enabled", false);

// Отключает системный аддон Web Compat Reporter, добавляющий в гамбургер-меню кнопку для сообщений
// о проблемах с отображением сайтов. При нажатии кнопка делает скриншот открытой в текущей вкладке
// страницы и аплоадит его вместе с адресом страницы на сервер Мозиллы.
// Аддон включен по умолчанию пока только в Nightly, но, возможно, будет и в бете.
// https://bugzilla.mozilla.org/show_bug.cgi?id=1324062
// https://hg.mozilla.org/releases/mozilla-release/file/175e28ba58fcd249fc2db68dcaa800da2ebc506d/browser/extensions/webcompat-reporter/bootstrap.js#l30
user_pref("extensions.webcompat-reporter.enabled", false);
// https://hg.mozilla.org/releases/mozilla-release/file/175e28ba58fcd249fc2db68dcaa800da2ebc506d/browser/extensions/webcompat-reporter/content/WebCompatReporter.jsm#l28
user_pref("extensions.webcompat-reporter.newIssueEndpoint", "");

// Отключает установку дефолтных пермишнов (resource://app/defaults/permissions) в Permission Manager.
// Среди которых есть пермишн install для AMO, из-за чего браузер в AMO -> Themes (со включенным JS)
// скачивает и применяет темы по mouseover, без подтверждения установки.
// Еще в том списке есть пермишн remote-troubleshooting, позволяющий скриптам на сайтах, которым он задан
// (support.mozilla.org и input.mozilla.org), читать часть информации, перечисленной в about:support,
// когда пользователь заходит на эти сайты (со включенным JS). Причем пермишны remote-troubleshooting,
// в отличие от install, не видны через UI браузера (Page Info -> Permissions). Протестировать этот
// механизм и узнать, какая именно информация доступна, можно здесь[1], задав hg.mozilla.org пермишн
// remote-troubleshooting путем присвоения этой настройке строки[2] (без кавычек) и перезапуска браузера.
// Отключение установки пермишнов из дефолтного списка решает обе вышеописанные проблемы.
// [1]: https://hg.mozilla.org/releases/mozilla-esr38/raw-file/569b611715e0/browser/base/content/test/general/test_remoteTroubleshoot.html
// [2]: "data:text/plain,host%09remote-troubleshooting%091%09hg.mozilla.org"
// https://bugzilla.mozilla.org/show_bug.cgi?id=1079563
// https://bugzilla.mozilla.org/show_bug.cgi?id=1091944
// https://bugzilla.mozilla.org/show_bug.cgi?id=1091942
// https://hg.mozilla.org/releases/mozilla-esr38/file/f402bfa9a35e/browser/base/content/test/general/browser_remoteTroubleshoot.js
// https://hg.mozilla.org/releases/mozilla-esr38/file/f9441895096d/browser/components/nsBrowserGlue.js#l833
// https://hg.mozilla.org/releases/mozilla-esr38/file/56d740d0769f/toolkit/modules/WebChannel.jsm#l139
// https://hg.mozilla.org/releases/mozilla-esr38/file/a20c7910a82f/extensions/cookie/nsPermissionManager.cpp#l1888
user_pref("permissions.manager.defaultsUrl", "");

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


// Отключает эксперименты - фоновые тесты различных отключенных пока по умолчанию функций (вроде
// HTTP Pipelining) со сбором телеметрии.
// https://hg.mozilla.org/releases/mozilla-esr38/file/008aa6494f90/netwerk/protocol/http/nsHttpHandler.cpp#l1406
user_pref("network.allow-experiments", false);
// https://hg.mozilla.org/releases/mozilla-esr38/file/91100de4f2ad/toolkit/mozapps/extensions/internal/XPIProvider.jsm#l7742
user_pref("experiments.supported", false);
// https://hg.mozilla.org/releases/mozilla-esr38/file/8bc9656cad94/browser/experiments/ExperimentsService.js
// https://hg.mozilla.org/releases/mozilla-esr38/file/8bc9656cad94/browser/experiments/Experiments.jsm
user_pref("experiments.enabled", false);
user_pref("experiments.activeExperiment", false);
user_pref("experiments.manifest.uri", "");
// Отключает эксперимент по определению оптимального времени жизни кэша, назначающий каждому
// пользователю рандомно один из четырех возможных интервалов.
// https://bugzilla.mozilla.org/show_bug.cgi?id=986728
// https://bugzilla.mozilla.org/show_bug.cgi?id=1098422
// https://trac.torproject.org/projects/tor/ticket/13575
// https://wiki.mozilla.org/User:Jesse/NewFrecency
// https://hg.mozilla.org/releases/mozilla-esr45/file/8a94f762f0a35613d967357816141f212f1b8772/browser/app/profile/firefox.js#l1530
// https://hg.mozilla.org/releases/mozilla-esr45/file/8a94f762f0a35613d967357816141f212f1b8772/netwerk/cache2/CacheObserver.cpp#l194
user_pref("browser.cache.frecency_experiment", -1);
user_pref("network.allow-experiments", false);
user_pref("experiments.enabled", false);
user_pref("experiments.manifest.uri", "");

// Отключает список рекомендуемых тем в Customize -> Themes.
user_pref("lightweightThemes.recommendedThemes", "");

// Запрещает попапам отключать элементы окон браузера.
// http://kb.mozillazine.org/Dom.popup_maximum
user_pref("dom.popup_maximum", 5);
user_pref("dom.disable_open_during_load", true);
user_pref("dom.allow_scripts_to_close_windows", false);
// http://kb.mozillazine.org/JavaScript#JavaScript_settings_in_Firefox_23_and_above
user_pref("dom.disable_window_move_resize", true);
user_pref("dom.disable_window_flip", true);
user_pref("dom.disable_window_status_change", true);
// http://kb.mozillazine.org/Prevent_websites_from_disabling_new_window_features
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

// Отключает SSDP, нужный для обнаружения телевизоров и реализации функции Send Video To Device в
// Firefox для Android. Десктопный Firefox тоже почему-то посылал соответствующие мультикаст-запросы.
// https://bugzilla.mozilla.org/show_bug.cgi?id=1111967
// https://support.mozilla.org/en-US/kb/use-firefox-android-send-videos-chromecast
// https://trac.torproject.org/projects/tor/ticket/16222
// https://support.mozilla.org/en-US/kb/how-stop-firefox-making-automatic-connections#w_send-video-to-device
user_pref("browser.casting.enabled", false);

// Отключает посылку серии пустых UDP-пакетов шлюзу на порт 4886 перед началом соединения с сайтом,
// предназначенную для улучшения латентности при использовании Wi-Fi в режиме сбережения энергии
// (Power Save Polling mode). Включено по умолчанию пока (?) только в Firefox для Android.
// (Однако такие фичи могут случайно протекать и на десктоп - см. browser.casting.enabled.)
// https://bugzilla.mozilla.org/show_bug.cgi?id=888268
// https://bugzilla.mozilla.org/show_bug.cgi?id=1156249
// https://hg.mozilla.org/releases/mozilla-esr45/file/2786beb35a3825b68651e2bf22ce06b84ff31ee3/modules/libpref/init/all.js#l1219
// https://hg.mozilla.org/releases/mozilla-esr45/file/2786beb35a3825b68651e2bf22ce06b84ff31ee3/netwerk/base/Tickler.cpp#l159
user_pref("network.tickle-wifi.enabled", false);

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


// Отключает передачу полных URL PAC-скрипту (будут передаваться только имена хостов), что
// отчасти исправляет уязвимость при использовании WPAD, описанную в статьях ниже.
// https://geektimes.ru/post/279472/
// https://habrahabr.ru/company/mailru/blog/259521/
// https://bugzilla.mozilla.org/show_bug.cgi?id=1255474
// https://hg.mozilla.org/releases/mozilla-release/rev/5139b0dd7acc
user_pref("network.proxy.autoconfig_url.include_path", false);

// Запрещает работу WebRTC в режиме P2P, разрешая ее только через сервер третьей стороны, что
// предотвращает утечку IP-адресов всех сетевых интерфейсов компьютера (подробнее - см. prefs_2).
// https://wiki.mozilla.org/Media/WebRTC/Privacy
// https://www.html5rocks.com/en/tutorials/webrtc/infrastructure/
// https://en.wikipedia.org/wiki/Interactive_Connectivity_Establishment
// Это обязательно нужно с Firefox 51+, в связке с relay_only или default_address_only.
// https://tools.ietf.org/html/draft-ietf-rtcweb-ip-handling-01
// https://bugzilla.mozilla.org/show_bug.cgi?id=1297416
// https://bugzilla.mozilla.org/show_bug.cgi?id=1304600
user_pref("media.peerconnection.ice.no_host", true);
// Разрешает работу WebRTC только на дефолтном сетевом интерфейсе, вследствие чего не
// происходит раскрытия настоящего IP пользователя, использующего VPN.
// https://bugzilla.mozilla.org/show_bug.cgi?id=1189041
user_pref("media.peerconnection.ice.default_address_only", true);
// В качестве альтернативы default_address_only можно использовать relay_only, запрещающий
// режим P2P в принципе и разрешающий работу WebRTC только через TURN-сервер.
// user_pref("media.peerconnection.ice.relay_only", true);


// Отключает Pageshot - новый системный аддон для создания скриншотов, тесно интегрированный с
// онлайн-сервисом screenshots.firefox.com. Аддон посылает на свой сервер различную информацию
// (в т.ч. уникальный идентификатор пользователя) еще до создания скриншота, уже при выборе
// области. Информация посылается даже в случае сохранения скриншота на диск, а не на сервер.
// (Информация перестает посылаться при отключенном datareporting.healthreport.uploadEnabled.)
// https://wiki.mozilla.org/Firefox/Screenshots
// https://github.com/mozilla-services/screenshots
// https://bugzilla.mozilla.org/show_bug.cgi?id=1346825
// https://hg.mozilla.org/releases/mozilla-release/file/f3b670b8cc32a5b2356cedd923f729e0f495d050/browser/extensions/screenshots/bootstrap.js#l96
// https://hg.mozilla.org/releases/mozilla-release/file/f3b670b8cc32a5b2356cedd923f729e0f495d050/browser/extensions/screenshots/webextension/background/analytics.js
// https://hg.mozilla.org/releases/mozilla-release/file/f3b670b8cc32a5b2356cedd923f729e0f495d050/browser/extensions/screenshots/bootstrap.js#l136
user_pref("extensions.screenshots.disabled", true);
user_pref("extensions.screenshots.system-disabled", true);

// Отключает автоматическое снятие скриншотов страниц с сохранением их на диск. Эти скриншоты
// используются в качестве превью в New Tab Page Tiles и в Ctrl+Tab (browser.ctrlTab.previews).
// При включенных New Tab Page Tiles и дефолтном значении этой опции, происходит еще и автоматическая
// закачка самых часто посещамых пользователем сайтов для генерации их превью. Если Tiles выключить,
// превью все равно сохраняются, когда пользователь сам заходит на один из часто посещаемых сайтов.
// Скриншоты пишутся на диск, даже если кэш полностью отключен. Хранятся они в каталоге thumbnails,
// расположенном на уровень выше каталога кэша, указанного в about:cache.
// Включение этой настройки решает все вышеописанные проблемы.
// https://bugzilla.mozilla.org/show_bug.cgi?id=897811#c14
// https://hg.mozilla.org/releases/mozilla-esr38/file/0e97e6bdedd8/toolkit/components/thumbnails/PageThumbs.jsm#l510
// https://hg.mozilla.org/releases/mozilla-esr38/file/0e97e6bdedd8/toolkit/components/thumbnails/PageThumbs.jsm#l350
// https://hg.mozilla.org/releases/mozilla-esr38/file/d7ca3b75c842/browser/base/content/newtab/page.js#l214
// https://hg.mozilla.org/releases/mozilla-esr38/file/d7ca3b75c842/browser/base/content/newtab/sites.js#l143
// https://hg.mozilla.org/releases/mozilla-esr38/file/54cb0b2e118b/toolkit/components/thumbnails/BackgroundPageThumbs.jsm#l34
// https://hg.mozilla.org/releases/mozilla-esr38/file/0e97e6bdedd8/browser/base/content/browser-thumbnails.js#l87
// https://hg.mozilla.org/releases/mozilla-esr38/file/3ab8c6c88f1d/browser/base/content/browser-ctrlTab.js#l49
// https://support.mozilla.org/en-US/kb/how-stop-firefox-making-automatic-connections#w_tiles
user_pref("browser.pagethumbnails.capturing_disabled", true);

// Отключает New Tab Page Tiles - изкоробочную панель быстрого набора с часто посещаемыми сайтами,
// которая потребляет процессорное время и замедляет открытие новых пустых вкладок.
// https://support.mozilla.org/en-US/kb/about-tiles-new-tab
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.newtab.preload", false);

// Отключает Social API и новую кнопку для перепостов в соцсети.
user_pref("social.enabled", false);
user_pref("social.remote-install.enabled", false);
user_pref("social.toast-notifications.enabled", false);
user_pref("social.directories", "");
user_pref("social.whitelist", "");
user_pref("social.share.activationPanelEnabled", false);
user_pref("social.shareDirectory", "");

// Отключает Reading List, портированный с версии для Android.
// https://wiki.mozilla.org/CloudServices/Reading_List
user_pref("browser.readinglist.enabled", false);
// Отключает Reader View
// https://wiki.mozilla.org/QA/Reader_view
user_pref("reader.parse-on-load.enabled", false);
user_pref("reader.parse-on-load.force-enabled", false);
// https://hg.mozilla.org/releases/mozilla-beta/file/00bcc10b3bdc/modules/libpref/init/all.js#l4997
user_pref("reader.errors.includeURLs", false);
// При каждом изменении window.location значение сравнивается с этой настройкой, чтобы начать UI-тур
// по режиму чтения. Значение этого параметра используется как регэксп без проверки на пустую строку,
// поэтому обнулять его нельзя. Вместо этого используем регэксп, возвращающий для любой строки false.
// https://hg.mozilla.org/releases/mozilla-release/file/e5d6dc48f6de/browser/components/uitour/UITour.jsm#l348
// https://hg.mozilla.org/releases/mozilla-release/file/cebe7cad65a2/browser/base/content/browser.js#l4224
user_pref("browser.uitour.readerViewTrigger", ".^");
// Отключает функцию зачитывания текста при помощи синтезированной речи в Reader View.
// https://bugzilla.mozilla.org/show_bug.cgi?id=1166365
// https://wiki.mozilla.org/QA/Speak_the_article
// https://hg.mozilla.org/releases/mozilla-release/file/b0310cb90fd0/toolkit/components/reader/AboutReader.jsm#l106
user_pref("narrate.enabled", false);

// Отключает геолокацию с использованием GPS-устройств через gpsd.
// https://bugzilla.mozilla.org/show_bug.cgi?id=1250922
user_pref("geo.provider.use_gpsd", false);

// Отключает Gamepad API, которое может быть использовано для получения идентификаторов
// производителя и модели подключенных к компьютеру геймпадов.
// https://trac.torproject.org/projects/tor/ticket/13023
// https://developer.mozilla.org/en-US/docs/Web/Guide/API/Gamepad
// https://www.w3.org/TR/gamepad/#methods
user_pref("dom.gamepad.enabled", false);
user_pref("dom.gamepad.non_standard_events.enabled", false);
user_pref("dom.gamepad.test.enabled", false);
user_pref("dom.gamepad.extensions.enabled", false);

// Отключает поддержку устройств виртуальной реальности.
// https://developer.mozilla.org/en-US/Firefox/Releases/36#Interfaces.2FAPIs.2FDOM
user_pref("dom.vr.enabled", false);
user_pref("dom.vr.autoactivate.enabled", false);
user_pref("dom.vr.cardboard.enabled", false);
user_pref("dom.vr.oculus.enabled", false);
user_pref("dom.vr.oculus050.enabled", false);
user_pref("dom.vr.poseprediction.enabled", false);
user_pref("dom.vr.openvr.enabled", false);
// https://hg.mozilla.org/releases/mozilla-release/file/970d0cf1c5d9/modules/libpref/init/all.js#l4778
user_pref("dom.vr.add-test-devices", 0);
user_pref("dom.vr.osvr.enabled", false);
user_pref("dom.vr.puppet.enabled", false);
user_pref("dom.vr.test.enabled", false);
// Отключает API для телефонных звонков, использующийся в Firefox OS.
// https://wiki.mozilla.org/WebAPI/Security/WebTelephony
user_pref("dom.telephony.enabled", false);
// Отключает Presentation API, использующийся для взаимодействия веб-страниц с проектором.
// https://w3c.github.io/presentation-api/
// https://bugzilla.mozilla.org/show_bug.cgi?id=1080474
// https://bugzilla.mozilla.org/show_bug.cgi?id=1148149
// https://bugzilla.mozilla.org/show_bug.cgi?id=1158029
user_pref("dom.presentation.enabled", false);
// https://bugzilla.mozilla.org/show_bug.cgi?id=1278205
user_pref("dom.presentation.controller.enabled", false);
user_pref("dom.presentation.receiver.enabled", false);
user_pref("dom.presentation.tcp_server.debug", false);
user_pref("dom.presentation.discovery.legacy.enabled", false);
// Отключает обнаружение устройств для презентации в локальной сети.
// https://bugzilla.mozilla.org/show_bug.cgi?id=1080474
// https://bugzilla.mozilla.org/show_bug.cgi?id=1115480
// https://hg.mozilla.org/releases/mozilla-beta/file/00bcc10b3bdc/dom/presentation/provider/MulticastDNSDeviceProvider.cpp#l18
user_pref("dom.presentation.discovery.enabled", false);
user_pref("dom.presentation.discoverable", false);
// Отключает встроенный mDNS-клиент, нужный для Presentation API.
// https://bugzilla.mozilla.org/show_bug.cgi?id=1241368
// https://bugzilla.mozilla.org/show_bug.cgi?id=1239909
// https://bugzilla.mozilla.org/show_bug.cgi?id=1225736
// https://bugzilla.mozilla.org/show_bug.cgi?id=1225726
user_pref("network.mdns.use_js_fallback", false);

// Отключает Simple Push API - нестандартную альтернативу Push API от Mozilla. В данный момент
// используется только на Firefox OS, но возможно будет портировано и на десктопную версию.
// https://wiki.mozilla.org/Security/Reviews/SimplePush
user_pref("services.push.enabled", false);
user_pref("services.push.serverURL", "");

// Отключает SystemUpdate API, использующийся в Firefox OS.
// https://wiki.mozilla.org/WebAPI/SystemUpdateAPI
// https://bugzilla.mozilla.org/show_bug.cgi?id=1037329
user_pref("dom.system_update.enabled", false);
user_pref("dom.system_update.debug", false);

// Запрещает поддержку протокола WebRTC, текущая реализация которого позволяет незаметно для
// пользователя получить список IP-адресов в его локальной сети. А также узнать ваш реальный IP
// за прокси/Tor/VPN. Ломает Firefox Hello.
// https://bugzilla.mozilla.org/show_bug.cgi?id=959893
// https://habrahabr.ru/post/215071/
// https://support.mozilla.org/en-US/kb/how-stop-firefox-making-automatic-connections#w_webrtc
user_pref("media.peerconnection.enabled", false);
user_pref("media.peerconnection.identity.enabled", false);
user_pref("media.peerconnection.video.enabled", false);
user_pref("media.peerconnection.video.h264_enabled", false);
user_pref("media.peerconnection.video.vp9_enabled", false);
user_pref("media.peerconnection.simulcast", false);
user_pref("media.peerconnection.turn.disable", true);
// https://hg.mozilla.org/releases/mozilla-esr38/file/e7f06142f3b5/dom/media/PeerConnection.js#l330
// https://hg.mozilla.org/releases/mozilla-beta/file/b14997797205/dom/media/PeerConnection.js#l335
user_pref("media.peerconnection.default_iceservers", "[]");
user_pref("media.peerconnection.use_document_iceservers", false);
// Запрещает использование WebRTC на всех интерфейсах кроме loopback.
// https://bugzilla.mozilla.org/show_bug.cgi?id=1189167
// https://bugzilla.mozilla.org/show_bug.cgi?id=1189040
// https://hg.mozilla.org/releases/mozilla-beta/rev/955e74958483
user_pref("media.peerconnection.ice.force_interface", "lo");

// Отключает Firefox Hello.
// https://wiki.mozilla.org/Loop/Data_Collection
// https://support.mozilla.org/en-US/kb/how-stop-firefox-making-automatic-connections#w_firefox-hello
user_pref("loop.enabled", false);
user_pref("loop.textChat.enabled", false);
user_pref("loop.server", "");
user_pref("loop.debug.twoWayMediaTelemetry", false);
user_pref("loop.contextInConversations.enabled", false);
user_pref("loop.gettingStarted.url", "");
user_pref("loop.learnMoreUrl", "");
user_pref("loop.legal.ToS_url", "");
user_pref("loop.legal.privacy_url", "");
user_pref("loop.support_url", "");
// Отключает появляющееся раз в 6 месяцев окно с предложением оставить отзыв о работе Hello.
// https://hg.mozilla.org/releases/mozilla-beta/file/00bcc10b3bdc/browser/components/loop/content/js/conversationAppStore.js#l54
// https://hg.mozilla.org/releases/mozilla-beta/file/00bcc10b3bdc/browser/components/loop/content/js/conversation.js#l47
// 2015-11-04, 00:00 UTC
user_pref("loop.feedback.dateLastSeenSec", 1446595200);
// 20 лет
user_pref("loop.feedback.periodSec", 630720000);
user_pref("loop.feedback.formURL", "");
user_pref("loop.feedback.manualFormURL", "");
// https://hg.mozilla.org/releases/mozilla-release/file/5b66df4523cf/browser/components/loop/modules/LoopRooms.jsm#l198
user_pref("loop.linkClicker.url", "");
user_pref("loop.facebook.shareUrl", "");
user_pref("loop.facebook.appId", "");
user_pref("loop.facebook.enabled", false);
user_pref("loop.facebook.fallbackUrl", "");
user_pref("loop.conversationPopOut.enabled", false);
// Отключает отправку в Google Analytics доменов тех ссылок, которые были заданы в теме дискуссии
// при создании room в Hello ("context URL"[1]). Отправляются только домены из белого списка[2].
// https://bugzilla.mozilla.org/show_bug.cgi?id=1211542
// https://bugzilla.mozilla.org/show_bug.cgi?id=1261467
// https://hg.mozilla.org/releases/mozilla-release/file/970d0cf1c5d9/browser/extensions/loop/chrome/content/modules/LoopRooms.jsm#l975
// [1]: https://wiki.mozilla.org/Loop/Architecture/Context
// [2]: https://hg.mozilla.org/releases/mozilla-release/file/4f87a2517f36/browser/extensions/loop/chrome/content/modules/DomainWhitelist.jsm#l17
user_pref("loop.logDomains", false);
// https://hg.mozilla.org/releases/mozilla-release/file/b0310cb90fd0/browser/extensions/loop/bootstrap.js#l392
user_pref("loop.copy.showLimit", 0);
user_pref("loop.copy.shown", true);
// https://hg.mozilla.org/releases/mozilla-release/file/b0310cb90fd0/browser/extensions/loop/bootstrap.js#l1226
user_pref("loop.copy.throttler", "");
// https://hg.mozilla.org/releases/mozilla-release/file/b0310cb90fd0/browser/extensions/loop/bootstrap.js#l1285
user_pref("loop.copy.ticket", 255);

// Отключает FlyWeb - новый системный аддон, предназначенный для взаимодействия с IoT-устройствами.
// (В Firefox 49 присутствуют только некоторые части дополнения.)
// https://wiki.mozilla.org/FlyWeb
// https://www.ghacks.net/2016/07/26/firefox-flyweb/
// https://www.reddit.com/r/firefox/comments/4uwd1n/flyweb_we_dont_need_no_stinking_iot_apps/
// https://hg.mozilla.org/releases/mozilla-release/rev/576019c74103
// https://hg.mozilla.org/releases/mozilla-release/file/8dc18bf5abac/browser/extensions/flyweb/bootstrap.js#l36
user_pref("dom.flyweb.enabled", false);

// Отключает кнопку "Report Site Issue", появляющуюся при ошибках декодирования медии. Нажатие на
// эту кнопку отправляет информацию о глючном файле на webcompat.com.
// Пока только в Nightly: https://hg.mozilla.org/mozilla-central/rev/374eac537a5e
// https://bugzilla.mozilla.org/show_bug.cgi?id=1343442
// https://hg.mozilla.org/releases/mozilla-release/file/4502ca8f2f51835179d2462e290a798ae2f39656/browser/base/content/browser-media.js#l236
// https://hg.mozilla.org/releases/mozilla-release/file/4502ca8f2f51835179d2462e290a798ae2f39656/browser/base/content/browser-media.js#l339
user_pref("media.decoder-doctor.new-issue-endpoint", "");

// Отключает возможность отладки через сеть этого экземпляра Firefox другим и наоборот (а также
// самого себя через loopback-соединение Browser Toolbox). Включена по умолчанию на Developer Edition.
// https://hg.mozilla.org/releases/mozilla-release/file/3dcde73ca237dd579e1599f635f3cc994afc1346/modules/libpref/init/all.js#l875
user_pref("devtools.debugger.remote-enabled", false);
user_pref("devtools.chrome.enabled", false);
// Разрешает сетевую отладку только через loopback-интерфейс и только после подтверждения.
// https://hg.mozilla.org/releases/mozilla-release/file/3dcde73ca237dd579e1599f635f3cc994afc1346/modules/libpref/init/all.js#l886
user_pref("devtools.debugger.force-local", true);
user_pref("devtools.debugger.prompt-connection", true);

// Отключает обнаружение captive portal - подмены всех запрашиваемых пользователем страниц на
// страницы провайдера. Эта техника используется в местах публичного Wi-Fi и некоторыми операторами
// для аутентификации или показа пользователю какой-либо информации (например, о необходимости
// пополнить счет). Обнаружение происходит через периодическое скачивание файла с сервера Мозиллы.
// https://en.wikipedia.org/wiki/Captive_portal
// https://github.com/vtsatskin/FX-Captive-Portals-Design
// https://wiki.mozilla.org/Necko/CaptivePortal
// https://hg.mozilla.org/releases/mozilla-beta/file/00bcc10b3bdc/netwerk/base/nsIOService.cpp#l1246
user_pref("network.captive-portal-service.enabled", false);
// https://hg.mozilla.org/releases/mozilla-beta/file/00bcc10b3bdc/modules/libpref/init/all.js#l4684
// https://hg.mozilla.org/releases/mozilla-beta/file/00bcc10b3bdc/netwerk/base/CaptivePortalService.cpp#l143
// https://hg.mozilla.org/releases/mozilla-beta/file/00bcc10b3bdc/netwerk/base/CaptivePortalService.cpp#l76
user_pref("network.captive-portal-service.minInterval", 0);
// https://hg.mozilla.org/releases/mozilla-beta/file/380817d573cd/toolkit/components/captivedetect/captivedetect.js#l199
// https://hg.mozilla.org/releases/mozilla-beta/file/380817d573cd/toolkit/components/captivedetect/captivedetect.js#l301
// https://hg.mozilla.org/releases/mozilla-beta/file/380817d573cd/toolkit/components/captivedetect/captivedetect.js#l345
user_pref("captivedetect.canonicalURL", "");
user_pref("captivedetect.maxRetryCount", 0);

// Отключает Service Worker API, позволяющее сайтам запускать скрипты, которые могут заниматься
// различной сомнительной самодеятельностью (примеры по ссылкам ниже) в фоновом режиме, даже
// если у пользователя не открыто ни одной вкладки этого сайта.
// Посмотреть и удалить установленные сайтами Service Workers можно через about:serviceworkers
// https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API#Other_use_case_ideas
// https://github.com/slightlyoff/ServiceWorker
// https://serviceworke.rs/
user_pref("dom.serviceWorkers.enabled", false);
user_pref("dom.serviceWorkers.interception.enabled", false);
user_pref("dom.serviceWorkers.interception.opaque.enabled", false);
user_pref("dom.serviceWorkers.openWindow.enabled", false);
// https://hg.mozilla.org/releases/mozilla-release/file/7eabe4d30cde/modules/libpref/init/all.js#l163
// https://hg.mozilla.org/releases/mozilla-release/file/7eabe4d30cde/dom/workers/ServiceWorkerManager.cpp#l2593
user_pref("dom.serviceWorkers.testUpdateOverOneDay", false);
user_pref("dom.webnotifications.serviceworker.enabled", false);

// Отключает [пока еще находящийся в разработке] Device Storage API, который позволит
// веб-страницам получать доступ к ФС и самопроизвольно читать файлы пользователя или писать в них.
// https://hacks.mozilla.org/2012/07/why-no-filesystem-api-in-firefox/
// https://wiki.mozilla.org/WebAPI/DeviceStorageAPI
// https://hg.mozilla.org/releases/mozilla-release/file/5b66df4523cf/modules/libpref/init/all.js#l4342
user_pref("device.storage.enabled", false);

// Отключает File Handle API который используется совместно с Indexed DB или Device Storage и
// предоставляет доступ к более низкоуровневым файловым операциям.
// https://hacks.mozilla.org/2012/07/why-no-filesystem-api-in-firefox/
// https://wiki.mozilla.org/WebAPI/FileHandleAPI
user_pref("dom.fileHandle.enabled", false);

// Отключает Storage API - еще один способ для сайтов хранить свои данные на ПК пользователя.
// Включено пока только в Nightly: https://bugzilla.mozilla.org/show_bug.cgi?id=1304966
// https://developer.mozilla.org/en-US/docs/Web/API/Storage_API
// https://storage.spec.whatwg.org/
// https://bugzilla.mozilla.org/show_bug.cgi?id=1254428
// https://hg.mozilla.org/releases/mozilla-release/file/a67a1682be8f0327435aaa2f417154330eff0017/dom/quota/StorageManager.cpp#l340
// https://hg.mozilla.org/releases/mozilla-release/file/a67a1682be8f0327435aaa2f417154330eff0017/dom/workers/WorkerPrefs.h#l36
user_pref("dom.storageManager.enabled", false);
// https://hg.mozilla.org/releases/mozilla-release/rev/e2e6505f3fc0
user_pref("browser.storageManager.enabled", false);

// Запрещает расширение WebGL, позволяющее узнать модель видеокарты пользователя и ее драйвер.
// https://www.mail-archive.com/dev-platform@lists.mozilla.org/msg14121.html
// https://bugzilla.mozilla.org/show_bug.cgi?id=1171228
// https://hg.mozilla.org/releases/mozilla-beta/file/8cf5636886f0/dom/canvas/WebGLContextState.cpp#l195
// https://hg.mozilla.org/releases/mozilla-beta/file/8cf5636886f0/dom/canvas/WebGLContextExtensions.cpp#l99
// Переменовано в Firefox 42:
// https://hg.mozilla.org/releases/mozilla-beta/file/00bcc10b3bdc/dom/canvas/WebGLContextExtensions.cpp#l99
user_pref("webgl.enable-debug-renderer-info", false);


// Отключает автоматическое обновление браузера. Проверки на наличие новых версий при этом все еще
// будут происходить, но обновление начнется только после подтверждения пользователем.
// https://developer.mozilla.org/en-US/Firefox/Enterprise_deployment
// https://support.mozilla.org/en-US/kb/how-stop-firefox-making-automatic-connections#w_auto-update-checking
// https://hg.mozilla.org/releases/mozilla-esr52/file/2ebcec6798551c83e5a3566c862a040750fa128a/browser/app/profile/firefox.js#l116
user_pref("app.update.auto", false);
// "If set to true, the Update Service will present no UI for any event."
user_pref("app.update.silent", false);

