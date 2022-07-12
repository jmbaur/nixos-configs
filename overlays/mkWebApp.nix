{ writeShellScriptBin
, lib
, google-chrome
, enableWayland ? true
, enablePipewire ? true
}:
let
  commandLineArgs = "--enable-features=SystemNotifications"
    + lib.optionalString enablePipewire ",WebRTCPipeWireCapturer"
    + lib.optionalString enableWayland " --ozone-platform-hint=auto";
  chrome = google-chrome.override { inherit commandLineArgs; };
in
name: url: writeShellScriptBin name ''
  ${chrome}/bin/google-chrome-stable --app=${url}
''
