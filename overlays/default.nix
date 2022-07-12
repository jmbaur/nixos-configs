final: prev: {
  bitwarden-bemenu = prev.callPackage ./bitwarden-bemenu.nix { };
  fdroidcl = prev.callPackage ./fdroidcl.nix { };
  j = prev.callPackage ./j.nix { };
  mkWebApp = prev.callPackage ./mkWebApp.nix { };
  mirror-to-x = prev.callPackage ./mirror-to-x.nix { };
  v4l-show = prev.callPackage ./v4l-show.nix { };
  zf = prev.callPackage ./zf.nix { };

  discord-webapp = final.mkWebApp "discord" "https://discord.com/app";
  outlook-webapp = final.mkWebApp "outlook" "https://outlook.com";
  slack-webapp = final.mkWebApp "slack" "https://app.slack.com/client";
  spotify-webapp = final.mkWebApp "spotify" "https://open.spotify.com";
  teams-webapp = final.mkWebApp "teams" "https://teams.microsoft.com";
}
