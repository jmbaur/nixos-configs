{ slack }: slack.overrideAttrs (old: {
  postInstall = ''
    substituteInPlace $out/share/applications/slack.desktop \
      --replace "$out/bin/slack" "$out/bin/slack --enable-features=WebRTCPipeWireCapturer"
  '';
})