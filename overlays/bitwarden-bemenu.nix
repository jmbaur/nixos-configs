{ bemenu
, bitwarden-cli
, pinentry-bemenu
, wl-clipboard
, writeShellApplication
}:
writeShellApplication {
  name = "bitwarden-bemenu";
  runtimeInputs = [ bemenu bitwarden-cli pinentry-bemenu wl-clipboard ];
  text = builtins.readFile ./bitwarden-bemenu.sh;
}
