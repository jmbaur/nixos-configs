{ writeShellScriptBin
, google-chrome
, commandLineArgs ? "--enable-features=UseOzonePlatform,WebRTCPipeWireCapturer,SystemNotifications --ozone-platform=wayland"
}:
let
  chrome = google-chrome.override { inherit commandLineArgs; };
in
name: url: writeShellScriptBin name ''
  ${chrome}/bin/google-chrome-stable --app=${url}
''
